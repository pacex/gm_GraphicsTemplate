
attribute vec3 in_Position;                     // (x,y,z)
attribute vec3 in_Normal;                       // (x,y,z)     
attribute vec4 in_Colour;                       // (r,g,b,a)
attribute vec2 in_TextureCoord;                 // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying float v_vLighting;

uniform vec3 lightDirection;
uniform float lightIntensity;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    //Transform object space normal to world space
    //In general normal have to be transformed with the inverted and transposed world matrix. But as long as scaling factors
    //are equal in each dimension, this should work fine.
    vec3 world_space_normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz);
    
    //Normalize light direction
    vec3 light_direction = normalize(lightDirection);
    
    //Compute vertex lighting
    v_vLighting = clamp(dot(world_space_normal, -light_direction) * lightIntensity, 0.1, 1.0);
    
    v_vColour = in_Colour;
    v_vNormal = in_Normal;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying float v_vLighting;

uniform sampler2D toonTexture;
uniform vec3 highlightColour;
uniform vec3 shadowColour;

void main()
{
    //Toon texture is sampled in fragment shader, because GameMaker seems to be unable to sample textures in the vertex stage.
    float toonLighting = texture2D(toonTexture, vec2(v_vLighting, 0.5)).r;
    
    //Interpolating between highlight and shadow colours to determine final fragment colour.
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord) * mix(vec4(shadowColour, 1.0), vec4(highlightColour, 1.0), toonLighting);
}

