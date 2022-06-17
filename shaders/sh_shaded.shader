/* EXTENDED TOON SHADER
    taking shadow map into account
*/

attribute vec3 in_Position;                     // (x,y,z)
attribute vec3 in_Normal;                       // (x,y,z)     
attribute vec4 in_Colour;                       // (r,g,b,a)
attribute vec2 in_TextureCoord;                 // (u,v)

varying vec4 v_vPosition;
varying vec4 v_vViewPos;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vViewNormal;
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
    v_vViewPos = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;
    
    //World space position
    v_vPosition = gm_Matrices[MATRIX_WORLD] * object_space_pos;
    
    linearizedDepth = gl_Position.z / uCameraFar;
    
    //Transform object space normal to world space
    vec3 world_space_normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz);
    v_vViewNormal = normalize((gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Normal, 0.0)).xyz);
    
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
varying vec4 v_vViewPos;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vViewNormal;
varying float v_vLighting;
varying float linearizedDepth;

//Toon
uniform sampler2D toonTexture;
uniform vec3 highlightColour;

//Shadow
uniform vec3 shadowColour;
uniform mat4 lightViewProjMat;
uniform sampler2D shadowMap;
uniform vec2 shadowMapSize;

//Screen Space Reflections
uniform vec2 screenSize;
uniform sampler2D metallic;
uniform sampler2D roughness;
uniform sampler2D screen;
uniform mat4 projection;

//Retrieve floating point depth value from shadow map
float unpackDepth(vec4 col){
    if (col.a < 1.0){
        return 999999999.0;
    }
    return col.x + col.y / 255.0 + col.z / 255.0 / 255.0;
}

vec3 packDepth(float f) {
    return vec3( floor( f * 255.0 ) / 255.0, fract( f * 255.0 ), fract( f * 255.0 * 255.0 ) );
}

float getLightingKoeff(float d_sampled, float d_own){
    return d_sampled < d_own ? 0.1 : 1.0;
}

void main()
{

    //Before sampling toon lighting, check if in shadow
    
    //Transfrom world space fragment position into light projection space and rescale to get texture coordinates
    vec2 shadowMapPosition = ((lightViewProjMat * v_vPosition).xy + vec2(1.0)) * 0.5;
    shadowMapPosition.y = 1.0 - shadowMapPosition.y;
    
    int ks = 3;
    float lighting = 0.0;
    for(int i = -ks; i <= ks; i++){
        for(int j = -ks; j <= ks; j++){
            vec2 offset = vec2(float(i) / shadowMapSize.x, float(j) / shadowMapSize.y);
            //vec2 offset = vec2(0.0);
            lighting += getLightingKoeff(unpackDepth(texture2D(shadowMap, shadowMapPosition + offset)), linearizedDepth);
        }
    }
    
    lighting /= float((2*ks + 1) * (2*ks + 1));
    lighting = min(v_vLighting, lighting);
    
    
    /*
    vec2 shadowMapPositionReal = (shadowMapPosition * shadowMapSize) - vec2(0.5);
    vec2 weights = vec2(fract(shadowMapPositionReal.x), fract(shadowMapPositionReal.y));
    
    vec2 samplePos00 = vec2(max(0.0, floor(shadowMapPositionReal.x) / shadowMapSize.x), max(0.0, floor(shadowMapPositionReal.y) / shadowMapSize.y));
    vec2 samplePos01 = vec2(max(0.0, floor(shadowMapPositionReal.x) / shadowMapSize.x), min(1.0, floor(shadowMapPositionReal.y + 1.0) / shadowMapSize.y));
    vec2 samplePos10 = vec2(min(1.0, floor(shadowMapPositionReal.x + 1.0) / shadowMapSize.x), max(0.0, floor(shadowMapPositionReal.y) / shadowMapSize.y));
    vec2 samplePos11 = vec2(min(1.0, floor(shadowMapPositionReal.x + 1.0) / shadowMapSize.x), min(1.0, floor(shadowMapPositionReal.y + 1.0) / shadowMapSize.y));
    
    //Bilinear interpolation
    float lighting0 = (1.0 - weights.y) * getLightingKoeff(unpackDepth(texture2D(shadowMap, samplePos00)), linearizedDepth)
     + weights.y * getLightingKoeff(unpackDepth(texture2D(shadowMap, samplePos01)), linearizedDepth);
    float lighting1 = (1.0 - weights.y) * getLightingKoeff(unpackDepth(texture2D(shadowMap, samplePos10)), linearizedDepth)
     + weights.y * getLightingKoeff(unpackDepth(texture2D(shadowMap, samplePos11)), linearizedDepth);
    float lighting = min((1.0 - weights.x) * lighting0 + weights.x * lighting1, v_vLighting);
    */
    
    
    
    //Sample toon texture using lighting coefficient
    float toonLighting = texture2D(toonTexture, vec2(lighting, 0.5)).r;
    
    //Interpolating between highlight and shadow colours to determine final fragment colour.
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord) * mix(vec4(shadowColour, 1.0), vec4(highlightColour, 1.0), toonLighting);
}

