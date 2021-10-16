///scr_set_shader_shaded();

shader_set(sh_shaded);

var daytime = true;

//Light direction rotates to better visualize the effect
/*light_direction[0] = lengthdir_x(1, current_time * 0.04);
light_direction[1] = lengthdir_y(1, current_time * 0.04);
light_direction[2] = -1;*/

var light_intensity = 1;

//Nighttime colors
highlight_color[0] = 0.2314;
highlight_color[1] = 0.3569;
highlight_color[2] = 0.549;

shadow_color[0] = 0.2431;
shadow_color[1] = 0.3059;
shadow_color[2] = 0.3098;


//Daytime colors
if (daytime){
    highlight_color[0] = 0.9608;
    highlight_color[1] = 0.902;
    highlight_color[2] = 0.8627;
    
    shadow_color[0] = 0.6157;
    shadow_color[1] = 0.5569;
    shadow_color[2] = 0.5255;
}

shader_set_uniform_f_array(shader_get_uniform(sh_shaded, "lightDirection"), light_direction);
shader_set_uniform_f(shader_get_uniform(sh_shaded, "lightIntensity"), light_intensity);
shader_set_uniform_f_array(shader_get_uniform(sh_shaded, "highlightColour"), highlight_color);
shader_set_uniform_f_array(shader_get_uniform(sh_shaded, "shadowColour"), shadow_color);
shader_set_uniform_f_array(shader_get_uniform(sh_shaded, "lightViewProjMat"), lightViewProjMat);
if (surface_exists(shadow_map)){
    texture_set_stage(shader_get_sampler_index(sh_shaded, "shadowMap"), surface_get_texture(shadow_map));
}else{
    show_debug_message("Shadow map does not exist!");
}
texture_set_stage(shader_get_sampler_index(sh_shaded, "toonTexture"), background_get_texture(tex_toon_simple));

shader_set_uniform_f(shader_get_uniform(sh_shaded, "uCameraNear"), 0.1);
shader_set_uniform_f(shader_get_uniform(sh_shaded, "uCameraFar"), 400);
