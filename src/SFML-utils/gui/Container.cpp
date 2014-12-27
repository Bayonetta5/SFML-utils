#include <SFML-utils/gui/Container.hpp>

#include <SFML-utils/gui/Layout.hpp>

namespace sfutils
{
    namespace gui
    {
        Container::Container(Widget* parent) : Widget(parent), _layout(nullptr)
        {
        }

        Container::~Container()
        {
            if(_layout != nullptr and _layout->_parent == this)
            {
                _layout->_parent = nullptr;
                delete _layout;
            }
        }

        void Container::setLayout(Layout* layout)
        {
            if(_layout != nullptr and _layout->_parent == this)
            {
                _layout->_parent = nullptr;
                delete _layout;
            }

            if((_layout = layout) != nullptr)
            {
                _layout->_parent = this;
                _layout->updateShape();
            }
        }

        Layout* Container::getLayout()const
        {
            return _layout;
        }

        sf::Vector2f Container::getSize()const
        {
            sf::Vector2f res(0,0);
            if(_layout)
                res = _layout->getSize();
            return res;
        }
        
        void Container::draw(sf::RenderTarget& target, sf::RenderStates states) const
        {
            if(_is_visible and _layout)
                target.draw(*_layout,states);
        }

        bool Container::processEvent(const sf::Event& event,const sf::Vector2f& parent_pos)
        {
            bool res = false;
            if(_is_visible and _layout)
                res = _layout->processEvent(event,parent_pos);
            return res;
        }

        void Container::processEvents(const sf::Vector2f& parent_pos)
        {
            if(_is_visible and _layout)
                _layout->processEvents(parent_pos);
        }
    }
}
