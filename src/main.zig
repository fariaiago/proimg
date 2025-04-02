const std = @import("std");
const rl = @import("raylib");
const clay = @import("zclay");
const rclay = @import("raylib_render_clay.zig");

pub fn main() !void
{
	var gpa = std.heap.DebugAllocator(.{}).init;
	const allocator = gpa.allocator();
	rl.initWindow(600, 400, "Título");
	defer rl.closeWindow();

	const min_memory_size: u32 = clay.minMemorySize();
	const memory = try allocator.alloc(u8, min_memory_size);
	defer allocator.free(memory);
	const arena: clay.Arena = clay.createArenaWithCapacityAndMemory(memory);
	_ = clay.initialize(arena, .{ .h = 400, .w = 600 }, .{});
	// clay.setMeasureTextFunction(void, {}, renderer.measureText);

	while (!rl.windowShouldClose())
	{
		rl.beginDrawing();
		defer rl.endDrawing();
		clay.beginLayout();
		clay.UI()(.{ // function call for creating a scope
			.id = .ID("SideBar"),
			.layout = .{
				.direction = .top_to_bottom,
				.sizing = .{ .w = .fixed(300), .h = .grow },
				.padding = .all(16),
				.child_alignment = .{ .x = .center, .y = .top },
				.child_gap = 16,
			},
			.background_color = .{0.5, 0.5, 0.5, 1},
		})({
		// Child elements here
		});
		rl.clearBackground(.ray_white);
		var layout = clay.endLayout();
		try rclay.clayRaylibRender(&layout, allocator);
	}
}