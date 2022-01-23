
attribute vec2 positionAttrib;
attribute vec2 uv0;
varying vec2 uv;

uniform vec2 joystickPositionUniform;
uniform vec2 positionUniform;
uniform vec2 screenDimensionsUniform;
uniform vec4 rotationUniform;

void main()
{
    vec2 buttonAbsolutePosition = joystickPositionUniform + positionUniform;
    
    vec3 vector = vec3(positionAttrib.x + buttonAbsolutePosition.x,
                       positionAttrib.y + buttonAbsolutePosition.y,
                       0.0);
    
    vector.xy -= buttonAbsolutePosition;
    
    vec3 quatVector1 = cross(rotationUniform.xyz, vector);
    vec3 quatVector2 = cross(rotationUniform.xyz, quatVector1);
    
    quatVector1 *= 2.0 * rotationUniform.w;
    quatVector2 *= 2.0;
    
    vec3 rotatedVector = vector + quatVector1 + quatVector2;
    rotatedVector.xy -= -buttonAbsolutePosition;
    
    gl_Position = vec4(rotatedVector.x * (2.0 / screenDimensionsUniform.x),
                       rotatedVector.y * (2.0 / screenDimensionsUniform.y),
                       0.0,
                       1.0);
    uv = uv0;
}