const std = @import("std");
const rl = @import("raylib");
const clay = @import("zclay");
const rclay = @import("raylib_render_clay.zig");

const Imagem = struct {
	path: []const u8,
	texture: rl.Texture,
};

pub fn main() !void
{
	var gpa = std.heap.DebugAllocator(.{}).init;
	const allocator = gpa.allocator();

	var images = std.MultiArrayList(Imagem){};
	defer images.deinit(allocator);

	const min_memory_size: u32 = clay.minMemorySize();
	const memory = try allocator.alloc(u8, min_memory_size);
	defer allocator.free(memory);
	const arena: clay.Arena = clay.createArenaWithCapacityAndMemory(memory);
	_ = clay.initialize(arena, .{ .w = 1080, .h = 720 }, .{});
	clay.setMeasureTextFunction(void, {}, rclay.measureText);

	rl.setConfigFlags(.{.window_resizable = true});
	rl.initWindow(1080, 720, "Título");
	defer rl.closeWindow();
	
	while (!rl.windowShouldClose())
	{
		if (rl.isKeyPressed(.d))
		{
			clay.setDebugModeEnabled(!clay.isDebugModeEnabled());
		}

		const mousePos = rl.getMousePosition();
		const wheel = rl.getMouseWheelMoveV();
		clay.setLayoutDimensions(.{ .w = @floatFromInt(rl.getScreenWidth()), .h = @floatFromInt(rl.getScreenHeight())});
		clay.setPointerState(.{ .x = mousePos.x, .y = mousePos.y}, rl.isMouseButtonDown(.left));
		clay.updateScrollContainers(true, .{ .x = wheel.x, .y = wheel.y}, rl.getFrameTime());

		rl.beginDrawing();
		defer rl.endDrawing();
		
		//rl.clearBackground(.gray);
		
		if (rl.isFileDropped())
		{
			images.clearAndFree(allocator);
			const droppedFiles = rl.loadDroppedFiles();
			for (0..droppedFiles.count) |i|
			{
				if (rl.loadTexture(std.mem.span(droppedFiles.paths[i]))) |tx|
				{
					try images.append(allocator, .{
						.path = try allocator.dupeZ(u8, std.mem.span(droppedFiles.paths[i])),
						.texture = tx
					});
				}
				else |err| switch (err) {else => {}}
				
			}
			rl.unloadDroppedFiles(droppedFiles);
		}
		clay.beginLayout();
		clay.UI()(.{
			.id = .ID("OuterContainer"),
			.layout = .{
				.sizing = .grow,
				.direction = .top_to_bottom,
			},
			.background_color = rclay.RaylibColorToclayColor(.ray_white) ,
		})({
			clay.UI()(.{
				.id = .ID("Header"),
				.layout = .{
					.sizing = .{ .h = .fixed(50), .w = .grow },
					.child_alignment = .{ .y = .center },
					.padding = .{ .left = 32, .right = 32 },
					.child_gap = 24,
				},
			})({
				clay.UI()(.{
					.layout = .{ .padding = .{ .left = 32, .right = 32, .top = 6, .bottom = 6 } },
					.border = .{ .width = .all(2), .color = rclay.RaylibColorToclayColor(.red) },
					.corner_radius = .all(10),
					.background_color = if (clay.hovered()) rclay.RaylibColorToclayColor(.white) else rclay.RaylibColorToclayColor(.ray_white),
				})({
					clay.text(
						"Github",
						.{ .font_id = 8, .font_size = 24, .color = .{ 61, 26, 5, 255 } },
					);
				});
			});
			clay.UI()(.{
				.id = .ID("ScrollContainerr"),
				.scroll = .{ .vertical = true, .horizontal = true },
				.layout = .{ .sizing = .grow, .direction = .top_to_bottom },
				.background_color = rclay.RaylibColorToclayColor(.ray_white),
				.border = .{ .width = .{ .between_children = 2 }, .color = rclay.RaylibColorToclayColor(.red) },
			})({
				for (images.items(.texture), 0..) |image, i|
				{
					//std.debug.print("{?}\n", .{&image});
					clay.UI()(.{
						.id = .ID(images.items(.path)[i]),
						.layout = .{ .sizing = .grow },
						.image = .{
							.image_data = &image,
							.source_dimensions = .{.w = @floatFromInt(image.width), .h = @floatFromInt(image.height)}},
					})({});
				}
			});
		});
		var commands = clay.endLayout();
		try rclay.clayRaylibRender(&commands, allocator);
	}
}