#ifndef SFUTILS_ES_ENTITY_HPP
#define SFUTILS_ES_ENTITY_HPP

#include <cstdint>
#include <tuple>
#include <SFML-utils/es/defines.hpp>

namespace sfutils
{
    namespace es
    {

        template<typename ENTITY> class EntityManager;
        template<typename COMPONENT,typename ENTITY> class Component;
        template<typename COMPONENT,typename ENTITY> class ComponentHandle;
        
        template<typename ENTITY>
        class Entity
        {
            public:
                Entity(Entity&&) = default;
                Entity& operator=(Entity&&) = default;

                Entity(EntityManager<ENTITY>* manager,std::uint32_t id);
                ~Entity();

                std::uint32_t id()const;

                bool operator==(const Entity& other)const;
                bool operator!=(const Entity& other)const;

                void remove();
                void reset();

                template<typename COMPONENT,typename ... Args>
                void add(Args&& ... args);

                template<typename COMPONENT>
                void remove();

                template<typename COMPONENT>
                bool has();

                template<typename COMPONENT>
                ComponentHandle<COMPONENT,ENTITY> component();

                template<typename ... COMPONENT>
                std::tuple<ComponentHandle<COMPONENT,ENTITY>...> components();

            private:
                std::uint32_t _id;    
                EntityManager<ENTITY>* _manager;
        };

        #define ES_INIT_ENTITY(ENTITY) __ES_INIT_VCOMPONENT__(ENTITY);__ES_INIT_VSYSTEM__(ENTITY);
    }
}
#include <SFML-utils/es/Entity.tpl>
#endif
