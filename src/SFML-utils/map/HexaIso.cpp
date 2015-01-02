#include <SFML-utils/map/HexaIso.hpp>
#include <cmath>

namespace sfutils
{
    namespace geometry
    {
        sf::ConvexShape HexaIso::_shape;
        HexaIso::__Initiatiser HexaIso::__initiatiser__;

        const float PI = 3.14159265;

        constexpr float sin_75 = sin(75*PI/180);
        constexpr float sin_15 = sin(15*PI/180);
        constexpr float sin_45 = sin(45*PI/180);

        constexpr float height = sin_15+sin_45+sin_75;
        constexpr float delta_x = sin_45-sin_15;
        constexpr float delta_y = sin_75+sin_45;

        const sf::ConvexShape& HexaIso::getShape()
        {
            return _shape;
        }

        sf::Vector2f HexaIso::mapCoordsToPixel(int X,int Y)
        {
            return sf::Vector2f(Y*delta_x + X*delta_y,
                                Y*delta_y/2 + X*delta_x/2);
        }

        sf::Vector2i HexaIso::mapPixelToCoords(int X,int Y)
        {
            const int a = X + height/2;
            const int b = Y + height/4;
            const float x =(2*b*delta_x - a*delta_y)/(delta_x*delta_x - delta_y*delta_y);
            const float y= (2*b-x*delta_x)/delta_y;

            return sf::Vector2i((x<0)?x-1:x,(y<0)?y-1:y);
        }

        sf::IntRect HexaIso::getTextureRect(int x,int y,float scale)
        {
            sf::Vector2f pos = mapCoordsToPixel(x,y);
            sf::IntRect res(pos.x * scale,
                          pos.y * scale,
                          height * scale,
                          height/2 * scale);
            return res;
        }

        void HexaIso::init()
        {
            _shape.setPointCount(6);
            _shape.setPoint(0,sf::Vector2f(0,(sin_15+sin_75)/2));
            _shape.setPoint(1,sf::Vector2f(sin_15,sin_15/2));
            _shape.setPoint(2,sf::Vector2f(sin_15+sin_75,0));
            _shape.setPoint(3,sf::Vector2f(sin_15+sin_75+sin_45,sin_45/2));
            _shape.setPoint(4,sf::Vector2f(sin_75+sin_45,(sin_75+sin_45)/2));
            _shape.setPoint(5,sf::Vector2f(sin_45,(sin_15+sin_75+sin_45)/2));

            _shape.setOrigin(height/2,height/4);
        }
        
    }
}