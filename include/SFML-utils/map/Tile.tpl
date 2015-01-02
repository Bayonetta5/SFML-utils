
namespace sfutils
{
    namespace map
    {
        template<typename GEOMETRY>
        sf::Vector2i Tile<GEOMETRY>::mapPixelToCoords(int x,int y)
        {
            return GEOMETRY::mapPixelToCoords(x,y);
        }

        template<typename GEOMETRY>
        sf::Vector2i Tile<GEOMETRY>::mapPixelToCoords(const sf::Vector2i& pos)
        {
            return GEOMETRY::mapPixelToCoords(pos.x,pos.y);
        }

        template<typename GEOMETRY>
        sf::Vector2f Tile<GEOMETRY>::mapCoordsToPixel(int x,int y)
        {
            return GEOMETRY::mapCoordsToPixel(x,y);
        }

        template<typename GEOMETRY>
        sf::Vector2f Tile<GEOMETRY>::mapCoordsToPixel(const sf::Vector2i& pos)
        {
            return GEOMETRY::mapCoordsToPixel(pos.x,pos.y);
        }

        template<typename GEOMETRY>
        Tile<GEOMETRY>::Tile(int pos_x,int pos_y,float scale)
        {
            _shape = GEOMETRY::getShape();

            _shape.setOutlineColor(sf::Color(255,255,255,25));
            _shape.setOutlineThickness(2.f/scale);

            _shape.setScale(scale,scale);

            setPosition(pos_x,pos_y);
        }

        template<typename GEOMETRY>
        template< typename ...Args>
        void Tile<GEOMETRY>::setFillColor(Args&& ... args)
        {
            _shape.setFillColor(std::forward<Args&>(args)...);
        }

        template<typename GEOMETRY>
        template< typename ...Args>
        void Tile<GEOMETRY>::setPosition(Args&& ... args)
        {
            sf::Vector2f pos = mapCoordsToPixel(args...) * _shape.getScale().x;
            _shape.setPosition(pos);
        }

        template<typename GEOMETRY>
        template< typename ...Args>
        sf::Vector2f Tile<GEOMETRY>::getPosition(Args&& ... args)const
        {
            return _shape.getPosition(args...);
        }

        template<typename GEOMETRY>
        void Tile<GEOMETRY>::setTexture(const sf::Texture *texture,bool resetRect)
        {
            _shape.setTexture(texture,resetRect);
        }

        template<typename GEOMETRY>
        void Tile<GEOMETRY>::setTextureRect(const sf::IntRect& rect)
        {
            _shape.setTextureRect(rect);
        }

        template<typename GEOMETRY>
        sf::FloatRect Tile<GEOMETRY>::getGlobalBounds()const
        {
            return _shape.getGlobalBounds();
        }

        template<typename GEOMETRY>
        sf::FloatRect Tile<GEOMETRY>::getLocalBounds()const
        {
            return _shape.getLocalBounds();
        }

        template<typename GEOMETRY>
        void Tile<GEOMETRY>::draw(sf::RenderTarget& target, sf::RenderStates states) const
        {
            target.draw(_shape,states);
        }
    }
}