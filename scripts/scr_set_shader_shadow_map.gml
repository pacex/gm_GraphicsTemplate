///scr_set_shader_shadow_map();

shader_set(sh_shadow_map);

shader_set_uniform_f(shader_get_uniform(sh_shadow_map, "uCameraNear"), 0.1);
shader_set_uniform_f(shader_get_uniform(sh_shadow_map, "uCameraFar"), 400);
