///scr_set_shader_cube_map()
shader_set(sh_cube_map);

texture_set_stage(shader_get_sampler_index(sh_cube_map, "cubeMap0"), surface_get_texture(cube_map[0]));
texture_set_stage(shader_get_sampler_index(sh_cube_map, "cubeMap1"), surface_get_texture(cube_map[1]));
texture_set_stage(shader_get_sampler_index(sh_cube_map, "cubeMap2"), surface_get_texture(cube_map[2]));
texture_set_stage(shader_get_sampler_index(sh_cube_map, "cubeMap3"), surface_get_texture(cube_map[3]));
texture_set_stage(shader_get_sampler_index(sh_cube_map, "cubeMap4"), surface_get_texture(cube_map[4]));
texture_set_stage(shader_get_sampler_index(sh_cube_map, "cubeMap5"), surface_get_texture(cube_map[5]));

shader_set_uniform_matrix_array(shader_get_uniform(sh_cube_map, "invView"), MATRIX_INV_VIEW);
