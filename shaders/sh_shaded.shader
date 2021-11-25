/* EXTENDED TOON SHADER
    taking shadow map into account
*/

attribute vec3 in_Position;                     // (x,y,z)
attribute vec3 in_Normal;                       // (x,y,z)     
attribute vec4 in_Colour;                       // (r,g,b,a)
attribute vec2 in_TextureCoord;                 // (u,v)

varying vec4 v_vPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying float v_vLighting;
varying float linearizedDepth;

uniform vec3 lightDirection;
uniform float lightIntensity;

uniform float uCameraFar;
uniform float uCameraNear;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    //World space position
    v_vPosition = gm_Matrices[MATRIX_WORLD] * object_space_pos;
    
    linearizedDepth = gl_Position.z / uCameraFar;
    
    //Transform object space normal to world space
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
varying vec4 v_vPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying float v_vLighting;
varying float linearizedDepth;

uniform sampler2D toonTexture;
uniform vec3 highlightColour;
uniform vec3 shadowColour;
uniform mat4 lightViewProjMat;
uniform sampler2D shadowMap;

//Retrieve floating point depth value from shadow map
float unpackDepth(vec3 col){
    return col.x + col.y / 255.0 + col.z / 255.0 / 255.0;
}

void main()
{
    
    float lighting = v_vLighting;

    //Before sampling toon lighting, check if in shadow
    
    //Transfrom world space fragment position into light projection space and rescale to get texture coordinates
    vec2 shadowMapPosition = ((lightViewProjMat * v_vPosition).xy + vec2(1.0)) * 0.5;
    shadowMapPosition.y = 1.0 - shadowMapPosition.y;
    
    //Read shadow map and unpack depth value from color vector
    vec4 shadowMapCol = texture2D(shadowMap, shadowMapPosition);
    float shadowMapDepth = unpackDepth(shadowMapCol.rgb);
    
    //Compare real depth value to depth read from shadow map to determine if fragment is in shadow
    if (shadowMapCol.a >= 1.0 && shadowMapDepth < linearizedDepth){
        //If so, set lighting coefficient to low value
        lighting = 0.1;
    }

    //Sample toon texture using lighting coefficient
    float toonLighting = texture2D(toonTexture, vec2(lighting, 0.5)).r;
    
    //Interpolating between highlight and shadow colours to determine final fragment colour.
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord) * mix(vec4(shadowColour, 1.0), vec4(highlightColour, 1.0), toonLighting);
}

