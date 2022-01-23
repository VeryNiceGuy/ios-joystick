
#pragma once
#import "JoystickPoint.h"
#import <OpenGLES/ES2/glext.h>
#import "Common.h"

class Button
{
    public:
    
        Button();
        ~Button();
    
        void setWidth(GLfloat width);
        void setHeight(GLfloat height);
    
        GLfloat getWidth()const;
        GLfloat getHeight()const;
    
        Vector2& getPosition();
        Quaternion& getRotation();
    
        void setTapped(bool tapped);
        bool isTapped()const;
        void tap(GLfloat x, GLfloat y);
    
    private:

        GLfloat _width;
        GLfloat _height;
        Vector2 _position;
        Quaternion _rotation;
        bool _tapped;
};

class Joystick
{
    public:
    
        Joystick(GLfloat x,
                 GLfloat y,
                 GLfloat screenWidth,
                 GLfloat screenHeight,
                 GLuint atlasTexture,
                 GLfloat atlasTextureWidth,
                 GLfloat atlasTextureHeight,
                 GLuint shaderProgram,
                 JoystickPoint &joystickPoint);
    
        ~Joystick();
    
        void isButtonTapped(GLfloat x, GLfloat y);
        void tappingEnded();
        void tapInterval();
        void draw();
    
    private:
    
        void drawButton(Button& button);
    
        GLuint _vertexBuffer;
        GLuint _shaderProgram;
    
        GLuint _atlasTexture;
        GLfloat _atlasTextureWidth;
        GLfloat _atlasTextureHeight;
    
        Vector2 _position;
    
        GLfloat _buttonWidth;
        GLfloat _buttonHeight;
    
        GLfloat _screenWidth;
        GLfloat _screenHeight;
    
        Button _up;
        Button _left;
        Button _right;
        Button _down;
    
        JoystickPoint* _joystickPoint;
    
        GLuint _joystickPositionUniformLocation;
        GLuint _joystickPointPositionUniformLocation;
        GLuint _screenDimensionsUniformLocation;
    
        GLuint _uvOffsetUniformLocation;
        GLuint _rotationUniformLocation;
};
