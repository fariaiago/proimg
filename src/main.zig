const std = @import("std");
const rl = @import("raylib");
const clay = @import("zclay");
const rs = @import("resize.zig");
const rgui = @import("raygui");

const Imagem = struct {
    path: []const u8,
    og: rl.Texture,
	nn_small: rl.Texture,
	nn_expand: rl.Texture,
};

var camera = rl.Camera2D{
	.offset = .{ .x = 540, .y = 360},
	.target = .{ .x = 0, .y = 0},
	.rotation = 0,
	.zoom = 1,
};

pub fn main() !void {
	var gpa = std.heap.DebugAllocator(.{}).init;
	const allocator = gpa.allocator();

	var images = std.MultiArrayList(Imagem){};
	defer images.deinit(allocator);

	rl.setConfigFlags(.{ .window_resizable = true });
	rl.initWindow(1080, 720, "Título");
	defer rl.closeWindow();

	while (!rl.windowShouldClose()) {
		if (rl.isFileDropped()) {
			images.clearAndFree(allocator);
			const droppedFiles = rl.loadDroppedFiles();
			for (0..droppedFiles.count) |i| {
				if (rl.loadTexture(std.mem.span(droppedFiles.paths[i]))) |tx| {
					var imgToScale = try rl.loadImage(std.mem.span(droppedFiles.paths[i]));
					try images.append(allocator, .{
						.path = try allocator.dupeZ(u8, std.mem.span(droppedFiles.paths[i])),
						.og = tx,
						.nn_small = try rs.nearest_neighbor_small(&imgToScale),
						.nn_expand = try rs.nearest_neighbor_expand(&imgToScale),
					});
				} else |err| switch (err) {
					else => {},
				}
			}
			rl.unloadDroppedFiles(droppedFiles);
		}

		if (rl.isKeyPressed(.equal)) {
			camera.zoom *= 1.5;
		}
		else if (rl.isKeyPressed(.minus)) {
			camera.zoom /= 1.5;
		}

		if (rl.isMouseButtonDown(.left)) {
			camera.target.x -= rl.getMouseDelta().x;
			camera.target.y -= rl.getMouseDelta().y;
		}

		camera.target.x += rl.getMouseWheelMoveV().x * 20000 * rl.getFrameTime() * (1 / camera.zoom);
		camera.target.y -= rl.getMouseWheelMoveV().y * 20000 * rl.getFrameTime() * (1 / camera.zoom);

		rl.beginDrawing();
		rl.beginMode2D(camera);
		defer rl.endMode2D();
		defer rl.endDrawing();

		rl.clearBackground(.gray);

		var yOffset: i32 = 0;
		const slice = images.slice();
		for (slice.items(.og), slice.items(.nn_expand)) |tx, scaled| {
			rl.drawTexture(tx, 0 - tx.width, yOffset, .white);
			rl.drawTexture(scaled, 0, yOffset, .white);
			yOffset += if (tx.height > scaled.height) tx.height else scaled.height;
		}
	}
}
