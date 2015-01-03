#ifndef SFUTILS_ES_ENTITY_HPP
#define SFUTILS_ES_ENTITY_HPP

#include <cstdint>
#include <bitset>
#include <SFML-utils/es/defines.hpp>

namespace sfutils
{
    namespace es
    {

        class EntityManager;
        template<typename T> class Component;
        class Entity
        {
            public:
                Entity(Entity&&) = default;
                Entity& operator=(Entity&&) = default;

                Entity(EntityManager* manager,std::uint32_t id);
                ~Entity();

                bool operator==(const Entity& other)const;
                bool operator!=(const Entity& other)const;

                void remove();

                template<typename COMPONENT_TYPE,typename ... Args>
                void add(Args&& ... args);

                template<typename COMPONENT_TYPE>
                void remove();

                void reset();
                
            private:
                friend class EntityManager;

                std::uint32_t _id;    
                EntityManager* _manager;

                std::bitset<MAX_COMPONENTS> _components_mask;

                
        };
    }
}
#include <SFML-utils/es/Entity.tpl>
#endif
