const std = @import("std");
const rl = @import("raylib");

pub fn nearest_neighbor_small(image: *rl.Image) !rl.Texture {
	var new = rl.genImageColor(@divFloor(image.width, 2), @divFloor(image.height, 2), .white);
	
	var colors = try rl.loadImageColors(new);
	const bytes_per_pixel : usize = @intCast(rl.getPixelDataSize(1, 1, image.format));
	const len : usize = @intCast(image.width * image.height * rl.getPixelDataSize(1, 1, image.format));
	const old_data = @as([*]u8, @ptrCast(image.data))[0..len];

	const old_width : usize = @intCast(image.width);
	const new_width : usize = @intCast(new.width);
	const new_height : usize = @intCast(new.height);
	for (0..new_width) |i| {
		for (0..new_height) |j| {
			colors[j * new_width + i].r = old_data[j * old_width * bytes_per_pixel * 2 + i * 2 * bytes_per_pixel];
			colors[j * new_width + i].g = old_data[j * old_width * bytes_per_pixel * 2 + (i + 1) * 2 * bytes_per_pixel];
			colors[j * new_width + i].b = old_data[j * old_width * bytes_per_pixel * 2 + (i + 2) * 2 * bytes_per_pixel];
			colors[j * new_width + i].a = 255;
		}
	}
	new.data = colors.ptr;
	new.format = .uncompressed_r8g8b8a8;

	return rl.loadTextureFromImage(new);
}

pub fn nearest_neighbor_expand(image: *rl.Image) !rl.Texture {
	var new = rl.genImageColor(image.width * 2, image.height * 2, .white);
	
	var new_colors = try rl.loadImageColors(new);
	const old_colors = try rl.loadImageColors(image.*);
	defer rl.unloadImageColors(old_colors);
	
	const old_width : usize = @intCast(image.width);
	const old_height : usize = @intCast(image.height);
	const new_width : usize = @intCast(new.width);
	
	for (0..old_width) |i| {
		for (0..old_height) |j| {
			new_colors[j * new_width * 2 + i * 2].r = old_colors[j * old_width + i].r;
			new_colors[j * new_width * 2 + i * 2].g = old_colors[j * old_width + i].g;
			new_colors[j * new_width * 2 + i * 2].b = old_colors[j * old_width + i].b;
			new_colors[j * new_width * 2 + i * 2].a = old_colors[j * old_width + i].a;

			new_colors[j * new_width * 2 + (i + 1) * 2].r = old_colors[j * old_width + i].r;
			new_colors[j * new_width * 2 + (i + 1) * 2].g = old_colors[j * old_width + i].g;
			new_colors[j * new_width * 2 + (i + 1) * 2].b = old_colors[j * old_width + i].b;
			new_colors[j * new_width * 2 + (i + 1) * 2].a = old_colors[j * old_width + i].a;

			if (j + 1 < old_height) {
				new_colors[(j + 1) * new_width * 2 + i * 2].r = old_colors[j * old_width + i].r;
				new_colors[(j + 1) * new_width * 2 + i * 2].g = old_colors[j * old_width + i].g;
				new_colors[(j + 1) * new_width * 2 + i * 2].b = old_colors[j * old_width + i].b;
				new_colors[(j + 1) * new_width * 2 + i * 2].a = old_colors[j * old_width + i].a;

				new_colors[(j + 1) * new_width * 2 + (i + 1) * 2].r = old_colors[j * old_width + i].r;
				new_colors[(j + 1) * new_width * 2 + (i + 1) * 2].g = old_colors[j * old_width + i].g;
				new_colors[(j + 1) * new_width * 2 + (i + 1) * 2].b = old_colors[j * old_width + i].b;
				new_colors[(j + 1) * new_width * 2 + (i + 1) * 2].a = old_colors[j * old_width + i].a;
			}
		}
	}
	new.data = new_colors.ptr;
	new.format = .uncompressed_r8g8b8a8;

	return rl.loadTextureFromImage(new);
}