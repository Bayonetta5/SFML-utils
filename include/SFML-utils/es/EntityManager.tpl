#include <SFML-utils/es/Component.hpp>
#include <SFML-utils/es/Entity.hpp>
#include <cassert>

namespace sfutils
{
    namespace es
    {
        template<typename COMPONENT,typename ... Args>
        void EntityManager::addComponent(std::uint32_t id,Args&& ... args)
        {
            checkComponent<COMPONENT>();
            Family family = COMPONENT::family();

            assert(not _entities_components_mask[id].test(family));

            auto pool = static_cast<utils::memory::Pool<COMPONENT>*>(_components_entities[family]);
            pool->emplace(id,std::forward<Args>(args)...);

            pool->at(id)._owner_id = id;
            pool->at(id)._manager = this;

            _entities_components_mask.at(id).set(family);
        }
        
        template<typename COMPONENT>
        void EntityManager::removeComponent(std::uint32_t id)
        {
            checkComponent<COMPONENT>();
            Family family = COMPONENT::family();

            assert(_entities_components_mask[id].test(family));

            static_cast<utils::memory::Pool<COMPONENT>*>(_components_entities[family])->erase(id);

            _entities_components_mask[id].reset(family);
        }

        template<typename COMPONENT>
        inline bool EntityManager::hasComponent(std::uint32_t id)const
        {
            //checkComponent<COMPONENT>();
            Family family = COMPONENT::family();
            return _entities_components_mask.at(id).test(family);
        }

        template<typename COMPONENT>
        inline ComponentHandle<COMPONENT> EntityManager::getComponent(std::uint32_t id)
        {
            if(hasComponent<COMPONENT>(id))
                return ComponentHandle<COMPONENT>(this,id);
            return ComponentHandle<COMPONENT>();
        }

        template<typename ... COMPONENT>
        inline std::tuple<ComponentHandle<COMPONENT>...> EntityManager::getComponents(std::uint32_t id)
        {
            return std::make_tuple(getComponent<COMPONENT>(id)...);
        }

        template<typename COMPONENT>
        inline COMPONENT* EntityManager::getComponentPtr(std::uint32_t id)
        {
            Family family = COMPONENT::family();
            return &static_cast<utils::memory::Pool<COMPONENT>*>(_components_entities[family])->at(id);
        }

        template<typename COMPONENT>
        inline void getMask(std::bitset<MAX_COMPONENTS>& mask)
        {
            mask.set(COMPONENT::family());
        }

        template<typename C1, typename C2, typename ... COMPONENT>
        inline void getMask(std::bitset<MAX_COMPONENTS>& mask)
        {
            mask.set(C1::family());
            getMask<C2,COMPONENT...>(mask);
        }

        template<typename ... COMPONENT>
        EntityManager::View<COMPONENT ...> EntityManager::getByComponents(ComponentHandle<COMPONENT>& ... components)
        {
            std::bitset<MAX_COMPONENTS> mask;
            getMask<COMPONENT ...>(mask);
            return View<COMPONENT...>(*this,mask,components ...);
        }


        template<typename COMPONENT>
        inline void EntityManager::checkComponent()
        {
            Family family = COMPONENT::family();
            //resize
            if( _components_entities.size() <= family)
                _components_entities.resize(family+1,nullptr);
            //check Pool validity
            if(_components_entities[family] == nullptr)
            {
                auto pool = new utils::memory::Pool<COMPONENT>;
                pool->resize(_entities_allocated.size());
                _components_entities[family] = pool;
            }
        }

        /////////////////////// VIEW ///////////////////

        template<typename ... COMPONENT>
        EntityManager::View<COMPONENT...>::View(EntityManager& manager,const std::bitset<MAX_COMPONENTS>& mask,ComponentHandle<COMPONENT>& ... components) : _manager(manager), _mask(mask), _handles(std::tuple<ComponentHandle<COMPONENT>&...>(components ...))
        {
            unpack_manager<0,COMPONENT ...>();
        }

        template<typename ... COMPONENT>
        inline typename EntityManager::View<COMPONENT ...>::iterator EntityManager::View<COMPONENT ...>::begin()
        {
            auto begin = _manager._entities_index.begin();
            auto end = _manager._entities_index.end();

            while(begin != end)
            {
                std::uint32_t index = *begin;    
                if((_manager._entities_components_mask[index] & _mask) == _mask)
                {
                    unpack_id<0,COMPONENT...>(index);
                    break;
                }
                ++begin;
            }

            return iterator(*this,begin,end);
        }

        template<typename ... COMPONENT>
        inline typename EntityManager::View<COMPONENT ...>::iterator EntityManager::View<COMPONENT ...>::end()
        {
            return iterator(*this,_manager._entities_index.end(),_manager._entities_index.end());
        }

        template<typename ... COMPONENT>
        template<int N,typename C>
        inline void EntityManager::View<COMPONENT...>::unpack_id(std::uint32_t id)
        {
            std::get<N>(_handles)._entity_id = id;
        }

        template<typename ... COMPONENT>
        template<int N,typename C0,typename C1,typename ... Cx>
        inline void EntityManager::View<COMPONENT...>::unpack_id(std::uint32_t id)
        {
            unpack_id<N,C0>(id);
            unpack_id<N+1,C1,Cx ...>(id);
        }

        template<typename ... COMPONENT>
        template<int N,typename C>
        inline void EntityManager::View<COMPONENT...>::unpack_manager()
        {
            std::get<N>(_handles)._manager = &_manager;
        }

        template<typename ... COMPONENT>
        template<int N,typename C0,typename C1,typename ... Cx>
        inline void EntityManager::View<COMPONENT...>::unpack_manager()
        {
            unpack_manager<N,C0>();
            unpack_manager<N+1,C1,Cx ...>();
        }

        ////////////////// VIEW ITERATOR /////////////////////////

        template<typename ... COMPONENT>
        EntityManager::View<COMPONENT ...>::iterator::iterator(View& view,EntityManager::container::iterator it,EntityManager::container::iterator it_end) : _view(view), _it(it), _it_end(it_end)
        {
        }

        template<typename ... COMPONENT>
        typename EntityManager::View<COMPONENT...>::iterator& EntityManager::View<COMPONENT ...>::iterator::operator++()
        {
            ++_it;
            while(_it != _it_end)
            {
                std::uint32_t index = *_it;    
                if((_view._manager._entities_components_mask[index] & _view._mask) == _view._mask)
                {
                    _view.unpack_id<0,COMPONENT...>(index);
                    break;
                }
                ++_it;
            }
            return *this;
        }

        template<typename ... COMPONENT>
        inline Entity* EntityManager::View<COMPONENT ...>::iterator::operator*()const
        {
            if(_it == _it_end)
                return nullptr;
            return &_view._manager._entities_allocated[*_it];
        }

        template<typename ... COMPONENT>
        inline Entity* EntityManager::View<COMPONENT ...>::iterator::operator->()const
        {
            if(_it == _it_end)
                return nullptr;
            return &_view._manager._entities_allocated[*_it];
        }

        template<typename ... COMPONENT>
        bool EntityManager::View<COMPONENT ...>::iterator::operator==(const EntityManager::View<COMPONENT...>::iterator& other)
        {
            return _it == other._it and _view._mask == other._view._mask and &(_view._manager) == &(other._view._manager);
        }

        template<typename ... COMPONENT>
        bool EntityManager::View<COMPONENT...>::iterator::operator!=(const EntityManager::View<COMPONENT...>::iterator& other)
        {
            return _it != other._it or _view._mask != other._view._mask or &(_view._manager) != &(other._view._manager);
        }

    }
}
