#include <algorithm>
#include <SFML-utils/map/Map.hpp>

namespace sfutils
{
    namespace map
    {
        //////////////////////// LAYER /////////////////////////////////////////
        template<typename CONTENT>
        Layer<CONTENT>::Layer(const std::string& type,int z,bool isStatic,bool isVisible) : VLayer(type,z,isStatic,isVisible)
        {
        }

        template<typename CONTENT>
        Layer<CONTENT>::~Layer()
        {
        }

        template<typename CONTENT>
        CONTENT* Layer<CONTENT>::add(const CONTENT& content,bool resort)
        {
            _content.emplace_back(content);
            CONTENT* res = &_content.back();
            if(resort)
                sort();
            return res;
        }

        template<typename CONTENT>
        CONTENT* Layer<CONTENT>::add(CONTENT&& content,bool resort)
        {
            _content.emplace_back(std::move(content));
            CONTENT* res = &_content.back();
            if(resort)
                sort();
            return res;
        }

        template<typename CONTENT>
        void Layer<CONTENT>::remove(void* data, bool del)
        {
            _content.remove_if([data](const CONTENT& c){
                return (&c == data);
            });
        }

        template<typename CONTENT>
        std::list<CONTENT*> Layer<CONTENT>::getByCoords(const sf::Vector2i& coords,const Map& map)
        {
            std::list<CONTENT*> res;
            const auto end = _content.end();
            for(auto it = _content.begin();it != end;++it)
            {
                auto pos = it->getPosition();
                sf::Vector2i c = map.getGeometry().mapPixelToCoords(sf::Vector2f(pos.x,pos.y));
                if(c == coords)
                    res.emplace_back(&(*it));
            }
            return res;
        }

        template<typename CONTENT>
        bool Layer<CONTENT>::remove(const CONTENT* content_ptr,bool resort)
        {
            auto it = std::find_if(_content.begin(),_content.end(),[content_ptr](const CONTENT& content)->bool{
                                    return &content == content_ptr;
                                });
            if(it != _content.end())
            {
                _content.erase(it);
                if(resort)
                    sort();
                return true;
            }
            return false;
        }

        template<typename CONTENT>
        void Layer<CONTENT>::sort()
        {
            _content.sort([](const CONTENT& a,const CONTENT& b)->bool{
                      auto pos_a = a.getPosition();
                      auto pos_b = b.getPosition();
                      return (pos_a.y < pos_b.y) or (pos_a.y == pos_b.y and pos_a.x < pos_b.x);
                    });
            _lastViewport = sf::FloatRect();
        }

        template<typename CONTENT>
        void Layer<CONTENT>::draw(sf::RenderTarget& target,const sf::RenderStates& states,const sf::FloatRect& viewport)
        {
            if(_isStatic)
            {
                if(_lastViewport != viewport)
                {
                    sf::Vector2u size(viewport.width+0.5,viewport.height+0.5);
                    if(_renderTexture.getSize() != size)
                    {
                        _renderTexture.create(size.x,size.y);
                        _sprite.setTexture(_renderTexture.getTexture(),true);
                    }

                    _renderTexture.setView(sf::View(viewport));

                    _renderTexture.clear(sf::Color::Transparent);
                    auto end = _content.end();
                    for(auto it = _content.begin();it != end;++it)
                    {
                        CONTENT& content = *it;
                        auto pos = content.getPosition();
                        if(viewport.contains(pos.x,pos.y))
                        {
                            _renderTexture.draw(content);
                        }
                    }
                    _renderTexture.display();
                    _lastViewport = viewport;
                    _sprite.setPosition(viewport.left,viewport.top);
                }
                target.draw(_sprite,states);
            }
            else
            {
                auto end = _content.end();
                for(auto it = _content.begin();it != end;++it)
                {
                    const CONTENT& content = *it;
                    auto pos = content.getPosition();
                    if(viewport.contains(pos.x,pos.y))
                    {
                        target.draw(content,states);
                    }
                }
            }
        }

        /////////////////////// LAYER PTR ////////////////////////////
        //
        template<typename CONTENT>
        Layer<CONTENT*>::Layer(const std::string& type,int z,bool isStatic,bool isVisible) : VLayer(type,z,isStatic,isVisible)
        {
            _autofree = false;
        }

        template<typename CONTENT>
        Layer<CONTENT*>::~Layer()
        {
            if(_autofree)
            {
                auto end = _content.end();
                for(auto it = _content.begin();it != end;++it)
                {
                    delete *it;
                }
            }
        }

        template<typename CONTENT>
        CONTENT* Layer<CONTENT*>::add(CONTENT* content,bool resort)
        {
            _content.emplace_back(content);
            if(resort)
                sort();
            return content;
        }

        template<typename CONTENT>
        void Layer<CONTENT*>::remove(void* data,bool del)
        {
            _content.remove_if([data,del](CONTENT* c){
                bool res = (c == data);
                if(res and del)
                {
                    delete reinterpret_cast<CONTENT*>(data);
                }
                return res;
            });
        }

        template<typename CONTENT>
        std::list<CONTENT*> Layer<CONTENT*>::getByCoords(const sf::Vector2i& coords,const Map& map)
        {
            std::list<CONTENT*> res;
            const auto end = _content.end();
            for(auto it = _content.begin();it != end;++it)
            {
                auto pos = (*it)->getPosition();
                sf::Vector2i c = map.getGeometry().mapPixelToCoords(sf::Vector2f(pos.x,pos.y));
                if(c == coords)
                    res.emplace_back(*it);
            }
            return res;
        }

        template<typename CONTENT>
        bool Layer<CONTENT*>::remove(const CONTENT* content_ptr,bool resort)
        {
            auto it = std::find(_content.begin(),_content.end(),content_ptr);
            if(it != _content.end())
            {
                _content.erase(it);
                if(resort)
                    sort();
                return true;
            }
            return false;
        }

        template<typename CONTENT>
        void Layer<CONTENT*>::sort()
        {
            _content.sort([](const CONTENT* a,const CONTENT* b)->bool{
                      auto pos_a = a->getPosition();
                      auto pos_b = b->getPosition();
                      return (pos_a.y < pos_b.y) or (pos_a.y == pos_b.y and pos_a.x < pos_b.x);
                    });
            _lastViewport = sf::FloatRect();
        }

        template<typename CONTENT>
        void Layer<CONTENT*>::setAutofree(bool autofree)
        {
            _autofree = autofree;
        }

        template<typename CONTENT>
        void Layer<CONTENT*>::draw(sf::RenderTarget& target,const sf::RenderStates& states,const sf::FloatRect& viewport)
        {
            if(_isStatic)
            {
                if(_lastViewport != viewport)
                {
                    sf::Vector2u size(viewport.width+0.5,viewport.height+0.5);
                    if(_renderTexture.getSize() != size)
                    {
                        _renderTexture.create(size.x,size.y);
                        _sprite.setTexture(_renderTexture.getTexture(),true);
                    }

                    _renderTexture.setView(sf::View(viewport));

                    _renderTexture.clear(sf::Color::Transparent);
                    auto end = _content.end();
                    for(auto it = _content.begin();it != end;++it)
                    {
                        CONTENT& content = *(*it);
                        auto pos = content.getPosition();
                        if(viewport.contains(pos.x,pos.y))
                        {
                            _renderTexture.draw(content);
                        }
                    }
                    _renderTexture.display();
                    _lastViewport = viewport;
                    _sprite.setPosition(viewport.left,viewport.top);
                }
                target.draw(_sprite,states);
            }
            else
            {
                auto end = _content.end();
                for(auto it = _content.begin();it != end;++it)
                {
                    const CONTENT& content = *(*it);
                    auto pos = content.getPosition();
                    if(viewport.contains(pos.x,pos.y))
                        target.draw(content,states);
                }
            }
        }
    }
}
