const std = @import("std");
const rl = @import("raylib");

pub fn nearest_neighbor(image: *rl.Image) !rl.Texture {
	const new = rl.genImageColor(@divTrunc(image.width, 2), @divTrunc(image.height, 2) , .white);
	switch (image.format) {
		.uncompressed_r8g8b8a8 => {
			const old_data : [*]rl.Color = @ptrCast(image.data);
			const new_data : [*]rl.Color = @ptrCast(new.data);
			const len : usize = @intCast(new.width * new.height);
			for (0..len) |i| {
				new_data[i].r = old_data[i * 2].r;
				new_data[i].g = old_data[i * 2].g;
				new_data[i].b = old_data[i * 2].b;
			}
		},
		else => {},
	}
	return new.toTexture();
}