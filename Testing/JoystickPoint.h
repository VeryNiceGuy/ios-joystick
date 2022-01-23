
#pragma once
#import <OpenGLES/ES2/glext.h>
#import "Common.h"

class JoystickPoint
{
    public:
    
        JoystickPoint(GLfloat screenWidth,
                      GLfloat screenHeight,
                      GLuint shaderProgram);
    
        ~JoystickPoint();
    
        void draw();
    
        Vector2& getPosition();
    
        GLfloat getRadius() const;
        void setRadius(GLfloat radius);
    
        void setHorizontalAcceleration(GLfloat acceleration);
        GLfloat getHorizontalAcceleration()const;
    
        void setVerticalAcceleration(GLfloat acceleration);
        GLfloat getVerticalAcceleration()const;
    
    private:
    
        GLuint _vertexBuffer;
        GLuint _shaderProgram;
    
        GLint _screenDimensionsUniformLocation;
        GLint _positionUniformLocation;
        GLint _scaleUniformLocation;
    
        Vector2 _position;
        GLfloat _radius;
    
        GLfloat _screenWidth;
        GLfloat _screenHeight;
    
        GLfloat _horizontalAcceleration;
        GLfloat _verticalAcceleration;
};