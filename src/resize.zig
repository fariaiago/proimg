const std = @import("std");
const rl = @import("raylib");

pub fn nearest_neighbor_reduce(image: *rl.Image) !rl.Texture {
	var new = rl.genImageColor(@divFloor(image.width, 2), @divFloor(image.height, 2), .white);
	
	var new_colors = try rl.loadImageColors(new);
	const old_colors = try rl.loadImageColors(image.*);
	defer rl.unloadImageColors(old_colors);
	
	const old_width : usize = @intCast(image.width);
	const new_width : usize = @intCast(new.width);
	const new_height : usize = @intCast(new.height);
	for (0..new_width) |i| {
		for (0..new_height) |j| {
			new_colors[j * new_width + i].r = old_colors[j * old_width * 2 + i * 2].r;
			new_colors[j * new_width + i].g = old_colors[j * old_width * 2 + i * 2].g;
			new_colors[j * new_width + i].b = old_colors[j * old_width * 2 + i * 2].b;
			new_colors[j * new_width + i].a = old_colors[j * old_width * 2 + i * 2].a;
		}
	}
	new.data = new_colors.ptr;
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

			new_colors[j * new_width * 2 + i * 2 + 1].r = old_colors[j * old_width + i].r;
			new_colors[j * new_width * 2 + i * 2 + 1].g = old_colors[j * old_width + i].g;
			new_colors[j * new_width * 2 + i * 2 + 1].b = old_colors[j * old_width + i].b;
			new_colors[j * new_width * 2 + i * 2 + 1].a = old_colors[j * old_width + i].a;

			
			new_colors[j * new_width * 2 + i * 2 + new_width].r = old_colors[j * old_width + i].r;
			new_colors[j * new_width * 2 + i * 2 + new_width].g = old_colors[j * old_width + i].g;
			new_colors[j * new_width * 2 + i * 2 + new_width].b = old_colors[j * old_width + i].b;
			new_colors[j * new_width * 2 + i * 2 + new_width].a = old_colors[j * old_width + i].a;

			new_colors[j * new_width * 2 + i * 2 + new_width + 1].r = old_colors[j * old_width + i].r;
			new_colors[j * new_width * 2 + i * 2 + new_width + 1].g = old_colors[j * old_width + i].g;
			new_colors[j * new_width * 2 + i * 2 + new_width + 1].b = old_colors[j * old_width + i].b;
			new_colors[j * new_width * 2 + i * 2 + new_width + 1].a = old_colors[j * old_width + i].a;
		}
	}
	new.data = new_colors.ptr;
	new.format = .uncompressed_r8g8b8a8;

	return rl.loadTextureFromImage(new);
}

pub fn bilinear_reduce(image: *rl.Image) !rl.Texture {
	var new = rl.genImageColor(@divFloor(image.width, 2), @divFloor(image.height, 2), .white);
	
	var new_colors = try rl.loadImageColors(new);
	const old_colors = try rl.loadImageColors(image.*);
	defer rl.unloadImageColors(old_colors);
	
	const old_width : usize = @intCast(image.width);
	const new_width : usize = @intCast(new.width);
	const new_height : usize = @intCast(new.height);
	for (0..new_width) |i| {
		for (0..new_height) |j| {
			new_colors[j * new_width + i].r = @intCast((@as(usize, @intCast(old_colors[j * old_width * 2 + i * 2].r))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + 1].r))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width].r))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width + 1].r))) / 4);

			new_colors[j * new_width + i].g = @intCast((@as(usize, @intCast(old_colors[j * old_width * 2 + i * 2].g))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + 1].g))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width].g))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width + 1].g))) / 4);

			new_colors[j * new_width + i].b = @intCast((@as(usize, @intCast(old_colors[j * old_width * 2 + i * 2].b))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + 1].b))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width].b))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width + 1].b))) / 4);

			new_colors[j * new_width + i].a = @intCast((@as(usize, @intCast(old_colors[j * old_width * 2 + i * 2].a))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + 1].a))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width].a))
				+ @as(usize, @intCast(old_colors[j * old_width * 2 + i * 2 + old_width + 1].a))) / 4);
		}
	}
	new.data = new_colors.ptr;
	new.format = .uncompressed_r8g8b8a8;

	return rl.loadTextureFromImage(new);
}

pub fn bilinear_expand(image: *rl.Image) !rl.Texture {
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

			if (i + 1 < old_width) {
				new_colors[j * new_width * 2 + i * 2 + 1].r = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].r))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].r))) / 2);
				new_colors[j * new_width * 2 + i * 2 + 1].g = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].g))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].g))) / 2);
				new_colors[j * new_width * 2 + i * 2 + 1].b = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].b))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].b))) / 2);
				new_colors[j * new_width * 2 + i * 2 + 1].a = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].a))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].a))) / 2);
			} else {
				new_colors[j * new_width * 2 + i * 2 + 1].r = old_colors[j * old_width + i].r;
				new_colors[j * new_width * 2 + i * 2 + 1].g = old_colors[j * old_width + i].g;
				new_colors[j * new_width * 2 + i * 2 + 1].b = old_colors[j * old_width + i].b;
				new_colors[j * new_width * 2 + i * 2 + 1].a = old_colors[j * old_width + i].a;
			}

			if (j + 1 < old_height) {
				new_colors[j * new_width * 2 + i * 2 + new_width].r = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].r))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].r))) / 2);
				new_colors[j * new_width * 2 + i * 2 + new_width].g = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].g))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].g))) / 2);
				new_colors[j * new_width * 2 + i * 2 + new_width].b = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].b))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].b))) / 2);
				new_colors[j * new_width * 2 + i * 2 + new_width].a = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].a))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].a))) / 2);
			} else {
				new_colors[j * new_width * 2 + i * 2 + new_width].r = old_colors[j * old_width + i].r;
				new_colors[j * new_width * 2 + i * 2 + new_width].g = old_colors[j * old_width + i].g;
				new_colors[j * new_width * 2 + i * 2 + new_width].b = old_colors[j * old_width + i].b;
				new_colors[j * new_width * 2 + i * 2 + new_width].a = old_colors[j * old_width + i].a;
			}

			if (i + 1 < old_width and j + 1 < old_height) {
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].r = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].r))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].r))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].r))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width + 1].r))) / 4);
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].g = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].g))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].g))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].g))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width + 1].g))) / 4);
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].b = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].b))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].b))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].b))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width + 1].b))) / 4);
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].a = @intCast((@as(usize, @intCast(old_colors[j * old_width + i].a))
					+ @as(usize, @intCast(old_colors[j * old_width + i + 1].a))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width].a))
					+ @as(usize, @intCast(old_colors[j * old_width + i + old_width + 1].a))) / 4);
			} else {
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].r = old_colors[j * old_width + i].r;
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].g = old_colors[j * old_width + i].g;
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].b = old_colors[j * old_width + i].b;
				new_colors[j * new_width * 2 + i * 2 + new_width + 1].a = old_colors[j * old_width + i].a;
			}
		}
	}
	new.data = new_colors.ptr;
	new.format = .uncompressed_r8g8b8a8;

	return rl.loadTextureFromImage(new);
}