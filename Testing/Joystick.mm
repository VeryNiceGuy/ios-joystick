
#import "Joystick.h"
#import <math.h>
#import <GLKit/GLKit.h>

Button::Button():_width(0),
                _height(0),
                _position{0},
                _rotation{0},
                _tapped(false){}

Button::~Button(){}

void Button::setWidth(GLfloat width)
{
    _width = width;
}

void Button::setHeight(GLfloat height)
{
    _height = height;
}

GLfloat Button::getWidth()const
{
    return _width;
}

GLfloat Button::getHeight()const
{
    return _height;
}

Vector2& Button::getPosition()
{
    return _position;
}

Quaternion& Button::getRotation()
{
    return _rotation;
}

bool Button::isTapped()const
{
    return _tapped;
}

void Button::setTapped(bool tapped)
{
    _tapped = tapped;
}

void Button::tap(GLfloat x, GLfloat y)
{
    if(x >= _position._x + -(_width / 2.0f) &&
       x <= _position._x + (_width / 2.0f) &&
       y >= _position._y + -(_height / 2.0f) &&
       y <= _position._y + (_height / 2.0f))
        _tapped = true;
}

Joystick::Joystick(GLfloat x,
                   GLfloat y,
                   GLfloat screenWidth,
                   GLfloat screenHeight,
                   GLuint atlasTexture,
                   GLfloat atlasTextureWidth,
                   GLfloat atlasTextureHeight,
                   GLuint shaderProgram,
                   JoystickPoint& joystickPoint): _position{x, y},
                                                _buttonWidth(80),
                                                _buttonHeight(80),
                                                _screenWidth(screenWidth),
                                                _screenHeight(screenHeight),
                                                _shaderProgram(shaderProgram),
                                                _atlasTexture(atlasTexture),
                                                _joystickPoint(&joystickPoint),
                                                _joystickPositionUniformLocation(0),
                                                _joystickPointPositionUniformLocation(0),
                                                _uvOffsetUniformLocation(0),
                                                _rotationUniformLocation(0)
{
    TextureRegion region;
    
    CreateTextureRegion(0,
                        0,
                        atlasTextureWidth/2,
                        atlasTextureHeight,
                        atlasTextureWidth,
                        atlasTextureHeight,
                        region);
    
    const GLfloat halfButtonWidth = _buttonWidth / 2.0f;
    const GLfloat halfButtonHeight = _buttonHeight / 2.0f;
    
    Vector2 vertices[8] = {{-halfButtonWidth, -halfButtonHeight}, region._BottomLeft,
                            {-halfButtonWidth, halfButtonHeight}, region._TopLeft,
                            {halfButtonWidth, -halfButtonHeight}, region._BottomRight,
                            {halfButtonWidth, halfButtonHeight}, region._TopRight};
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(vertices),
                 vertices,
                 GL_STATIC_DRAW);
    
    _up.setWidth(_buttonWidth);
    _up.setHeight(_buttonHeight);
    
    _left.setWidth(_buttonWidth);
    _left.setHeight(_buttonHeight);
    
    _right.setWidth(_buttonWidth);
    _right.setHeight(_buttonHeight);
    
    _down.setWidth(_buttonWidth);
    _down.setHeight(_buttonHeight);
    
    Vector2& upPosition = _up.getPosition();
    Vector2& leftPosition = _left.getPosition();
    Vector2& rightPosition = _right.getPosition();
    Vector2& downPosition = _down.getPosition();
    
    upPosition._x = 0.0f;
    upPosition._y = _buttonHeight;
    
    leftPosition._x = -_buttonWidth;
    leftPosition._y = 0.0f;
    
    rightPosition._x = _buttonWidth;
    rightPosition._y = 0.0f;
    
    downPosition._x = 0.0f;
    downPosition._y = -_buttonHeight;
    
    Quaternion& upRotation = _up.getRotation();
    Quaternion& leftRotation = _left.getRotation();
    Quaternion& rightRotation = _right.getRotation();
    Quaternion& downRotation = _down.getRotation();
    
    upRotation._x = 0.0f;
    upRotation._y = 0.0f;
    upRotation._z = sinf(0.5f * 0.0f * RADIANS_IN_DEGREE);
    upRotation._w = cosf(0.5f * 0.0f * RADIANS_IN_DEGREE);
    
    leftRotation._x = 0.0f;
    leftRotation._y = 0.0f;
    leftRotation._z = sinf(0.5f * 90.0f * RADIANS_IN_DEGREE);
    leftRotation._w = cosf(0.5f * 90.0f * RADIANS_IN_DEGREE);
    
    rightRotation._x = 0.0f;
    rightRotation._y = 0.0f;
    rightRotation._z = sinf(0.5f * -90.0f * RADIANS_IN_DEGREE);
    rightRotation._w = cosf(0.5f * -90.0f * RADIANS_IN_DEGREE);
    
    downRotation._x = 0.0f;
    downRotation._y = 0.0f;
    downRotation._z = sinf(0.5f * 180.0f * RADIANS_IN_DEGREE);
    downRotation._w = cosf(0.5f * 180.0f * RADIANS_IN_DEGREE);
    
    _joystickPositionUniformLocation = glGetUniformLocation(_shaderProgram, "joystickPositionUniform");
    _joystickPointPositionUniformLocation = glGetUniformLocation(_shaderProgram, "positionUniform");
    _screenDimensionsUniformLocation = glGetUniformLocation(_shaderProgram, "screenDimensionsUniform");
    _uvOffsetUniformLocation = glGetUniformLocation(_shaderProgram, "uvOffsetUniform");
    _rotationUniformLocation = glGetUniformLocation(_shaderProgram, "rotationUniform");
}

Joystick::~Joystick()
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteProgram(_shaderProgram);
}

void Joystick::isButtonTapped(GLfloat x, GLfloat y)
{
    GLfloat px = x - (_screenWidth / 2.0f);
    GLfloat py = (y - (_screenHeight / 2.0f)) * -1;
    
    GLfloat rx = px - _position._x;
    GLfloat ry = py - _position._y;
    
    _up.tap(rx, ry);
    _left.tap(rx, ry);
    
    _right.tap(rx, ry);
    _down.tap(rx, ry);
};

void Joystick::tappingEnded()
{
    if(_up.isTapped())
        _up.setTapped(false);
    
    else if(_left.isTapped())
        _left.setTapped(false);
    
    else if(_right.isTapped())
        _right.setTapped(false);
    
    else if(_down.isTapped())
        _down.setTapped(false);
}

void Joystick::tapInterval()
{
    const GLfloat acceleration = 1.0f;
    
    if(_up.isTapped())
        _joystickPoint->setVerticalAcceleration(_joystickPoint->getVerticalAcceleration() + acceleration);
    
    else if(_down.isTapped())
        _joystickPoint->setVerticalAcceleration(_joystickPoint->getVerticalAcceleration() - acceleration);
    
    else if(_left.isTapped())
        _joystickPoint->setHorizontalAcceleration(_joystickPoint->getHorizontalAcceleration() - acceleration);
    
    else if(_right.isTapped())
        _joystickPoint->setHorizontalAcceleration(_joystickPoint->getHorizontalAcceleration() + acceleration);
}

void Joystick::draw()
{
    glFrontFace(GL_CW);
    glUseProgram(_shaderProgram);
    
    glBindTexture(GL_TEXTURE_2D, _atlasTexture);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glEnableVertexAttribArray(VertexAttribPosition);
    glVertexAttribPointer(VertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(VertexAttribUV);
    glVertexAttribPointer(VertexAttribUV, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(8));
    
    glUniform2f(_screenDimensionsUniformLocation,
                _screenWidth,
                _screenHeight);
    
    glUniform2fv(_joystickPositionUniformLocation, 1, &_position._x);
    
    glUniform2fv(_joystickPointPositionUniformLocation, 1, &_up.getPosition()._x);
    drawButton(_up);
   
    glUniform2fv(_joystickPointPositionUniformLocation, 1, &_left.getPosition()._x);
    drawButton(_left);
    
    glUniform2fv(_joystickPointPositionUniformLocation, 1, &_right.getPosition()._x);
    drawButton(_right);
    
    glUniform2fv(_joystickPointPositionUniformLocation, 1, &_down.getPosition()._x);
    drawButton(_down);
    
    glDisableVertexAttribArray(VertexAttribPosition);
    glDisableVertexAttribArray(VertexAttribUV);
}

void Joystick::drawButton(Button& button)
{
    if(button.isTapped())
        glUniform2f(_uvOffsetUniformLocation, 0.5f, 0.0f);
    else
        glUniform2f(_uvOffsetUniformLocation, 0.0f, 0.0f);
    
    glUniform4fv(_rotationUniformLocation, 1, &button.getRotation()._x);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


























