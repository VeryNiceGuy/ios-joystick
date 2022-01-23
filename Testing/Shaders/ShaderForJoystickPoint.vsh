
attribute vec2 positionAttrib;
uniform vec2 positionUniform;
uniform vec2 scaleUniform;
uniform vec2 screenDimensionsUniform;

void main()
{
    gl_Position = vec4((positionAttrib.x * scaleUniform.x + positionUniform.x) * (2.0 / screenDimensionsUniform[0]),
                       (positionAttrib.y * scaleUniform.y + positionUniform.y) * (2.0 / screenDimensionsUniform[1]),
                       0.0,
                       1.0);
}