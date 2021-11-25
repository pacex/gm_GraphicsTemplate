//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vViewNorm;
varying vec4 v_vColour;
varying vec4 v_vViewPos;
varying vec4 v_vNormal;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vViewNorm = gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Normal, 0.0);
    v_vTexcoord = in_TextureCoord;
    v_vViewPos = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;
    v_vNormal = gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0);
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~varying vec2 v_vTexcoord;
varying vec4 v_vViewNorm;
varying vec4 v_vColour;
varying vec4 v_vViewPos;
varying vec4 v_vNormal;

uniform sampler2D cubeMap0;
uniform sampler2D cubeMap1;
uniform sampler2D cubeMap2;
uniform sampler2D cubeMap3;
uniform sampler2D cubeMap4;
uniform sampler2D cubeMap5;

uniform mat4 invView;

int argmax3 (vec3 v){
    return v.y > v.x ? ( v.z > v.y ? 2 : 1 ) : ( v.z > v.x ? 2 : 0 );
}

vec4 getCubeMapColor(vec3 dir){
    vec3 absDir = abs(dir);
    vec3 dirOnCube;
    vec2 uv;
    
    int samplerIndex;
    
    int maxInd = argmax3(absDir);
    if (maxInd == 0){ //x
        dirOnCube = dir / dir.x;
        uv = vec2(dirOnCube.y, -sign(dir.x) * dirOnCube.z);
        samplerIndex = dir.x < 0.0 ? 1 : 0;
    }else if (maxInd == 1){ //y
        dirOnCube = dir / dir.y;
        uv = vec2(sign(dir.y) * dirOnCube.x, -sign(dir.y) * dirOnCube.z);
        samplerIndex = dir.y < 0.0 ? 3 : 2;
    }else{ //z
        dirOnCube = dir / dir.z;
        uv = vec2(-dirOnCube.x, sign(dir.z) * dirOnCube.y);
        samplerIndex = dir.z < 0.0 ? 5 : 4;
    }
    
    uv = (uv + vec2(1.0)) * 0.5;
    
    if (samplerIndex == 0){
        return texture2D(cubeMap0, uv);
    }else if (samplerIndex == 1){
        return texture2D(cubeMap1, uv);
    }else if (samplerIndex == 2){
        return texture2D(cubeMap2, uv);
    }else if (samplerIndex == 3){
        return texture2D(cubeMap3, uv);
    }else if (samplerIndex == 4){
        return texture2D(cubeMap4, uv);
    }else {
        return texture2D(cubeMap5, uv);
    }
}

void main()
{
    vec3 d = v_vViewPos.xyz;
    vec3 n = normalize(v_vViewNorm.xyz);
    vec3 view_r = d - 2.0 * dot(d, n) * n;
    vec4 world_r = invView * vec4(view_r.xyz, 0.0);
    gl_FragColor = mix(getCubeMapColor(world_r.xyz), texture2D(gm_BaseTexture, v_vTexcoord), 0.7);
}

