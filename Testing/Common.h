
#pragma once
#import <OpenGLES/ES2/glext.h>

const GLfloat PI = 3.14159265359f;
const GLfloat RADIANS_IN_DEGREE = PI / 180.0f;

#define BUFFER_OFFSET(i) ((char *)0 + (i))

enum VertexAttributes
{
    VertexAttribPosition,
    VertexAttribUV
};

struct Vector2
{
    GLfloat _x;
    GLfloat _y;
};

struct Quaternion
{
    GLfloat _x;
    GLfloat _y;
    GLfloat _z;
    GLfloat _w;
};

struct TextureRegion
{
    Vector2 _BottomLeft;
    Vector2 _TopLeft;
    Vector2 _BottomRight;
    Vector2 _TopRight;
};

void CreateTextureRegion(GLfloat x,
                         GLfloat y,
                         GLfloat width,
                         GLfloat height,
                         GLfloat textureWidth,
                         GLfloat textureHeight,
                         TextureRegion& region);