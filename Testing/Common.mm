
#import "Common.h"

void CreateTextureRegion(GLfloat x,
                         GLfloat y,
                         GLfloat width,
                         GLfloat height,
                         GLfloat textureWidth,
                         GLfloat textureHeight,
                         TextureRegion& region)
{
    GLfloat u1 = x / textureWidth;
    GLfloat v1 = y / textureHeight;
    GLfloat u2 = u1 + width / textureWidth ;
    GLfloat v2 = v1 + height / textureHeight;
    
    region._BottomLeft._x = u1;
    region._BottomLeft._y = v2;
    
    region._TopLeft._x = u1;
    region._TopLeft._y = v1;
    
    region._BottomRight._x = u2;
    region._BottomRight._y = v2;
    
    region._TopRight._x = u2;
    region._TopRight._y = v1;
}