
precision mediump float;
varying vec2 uv;
uniform sampler2D baseMap;
uniform vec2 uvOffsetUniform;

void main()
{
    vec2 uvWithOffset = uv + uvOffsetUniform;
    gl_FragColor = texture2D(baseMap, uvWithOffset);
}
