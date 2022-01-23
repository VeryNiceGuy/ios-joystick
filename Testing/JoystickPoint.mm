
#include "JoystickPoint.h"
#include <math.h>

JoystickPoint::JoystickPoint(GLfloat screenWidth,
                             GLfloat screenHeight,
                             GLuint shaderProgram): _vertexBuffer(0),
                                                    _shaderProgram(shaderProgram),
                                                    _screenDimensionsUniformLocation(0),
                                                    _positionUniformLocation(0),
                                                    _scaleUniformLocation(0),
                                                    _position{0},
                                                    _radius(40),
                                                    _screenWidth(screenWidth),
                                                    _screenHeight(screenHeight),
                                                    _horizontalAcceleration(0),
                                                    _verticalAcceleration(0)
{
    _positionUniformLocation = glGetUniformLocation(_shaderProgram, "positionUniform");
    _scaleUniformLocation = glGetUniformLocation(_shaderProgram, "scaleUniform");
    _screenDimensionsUniformLocation = glGetUniformLocation(_shaderProgram, "screenDimensionsUniform");
    
    Vector2 circlePoints[361] = {0};
    Vector2* begin = &circlePoints[1];
    
    for(unsigned short i = 0; i < 360; ++i)
    {
        begin[i]._x = cosf(static_cast<GLfloat>(i) * RADIANS_IN_DEGREE);
        begin[i]._y = sinf(static_cast<GLfloat>(i) * RADIANS_IN_DEGREE);
    }
    
    circlePoints[360]._x = begin[0]._x;
    circlePoints[360]._y = begin[0]._y;
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(circlePoints),
                 circlePoints,
                 GL_STATIC_DRAW);
}

JoystickPoint::~JoystickPoint()
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteProgram(_shaderProgram);
}

void JoystickPoint::draw()
{
    glFrontFace(GL_CCW);
    glUseProgram(_shaderProgram);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glEnableVertexAttribArray(VertexAttribPosition);
    glVertexAttribPointer(VertexAttribPosition,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          8,
                          0);
    
    _position._x += _horizontalAcceleration;
    _position._y += _verticalAcceleration;
    
    if((_position._x + _radius) > _screenWidth / 2.0f)
        _position._x = _screenWidth / 2.0f - _radius;
    
    if((_position._x - _radius) < -(_screenWidth / 2.0f))
        _position._x = -(_screenWidth / 2.0f) + _radius;
    
    if((_position._y + _radius) > _screenHeight / 2.0f)
        _position._y = _screenHeight / 2.0f - _radius;
    
    if((_position._y - _radius) < -(_screenHeight / 2.0f))
        _position._y = -(_screenHeight / 2.0f) + _radius;
    
    glUniform2f(_screenDimensionsUniformLocation,
                _screenWidth,
                _screenHeight);
    
    glUniform2f(_positionUniformLocation,
                _position._x,
                _position._y);
    
    glUniform2f(_scaleUniformLocation,
                _radius,
                _radius);
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 361);
    glDisableVertexAttribArray(VertexAttribPosition);
}

Vector2& JoystickPoint::getPosition()
{
    return _position;
}

GLfloat JoystickPoint::getRadius() const
{
    return _radius;
};

void JoystickPoint::setRadius(GLfloat radius)
{
    _radius = radius;
};

void JoystickPoint::setHorizontalAcceleration(GLfloat acceleration)
{
    _horizontalAcceleration = acceleration;
}

GLfloat JoystickPoint::getHorizontalAcceleration()const
{
    return _horizontalAcceleration;
}

void JoystickPoint::setVerticalAcceleration(GLfloat acceleration)
{
    _verticalAcceleration = acceleration;
}

GLfloat JoystickPoint::getVerticalAcceleration()const
{
    return _verticalAcceleration;
}
