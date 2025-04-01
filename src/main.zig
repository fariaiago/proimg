const std = @import("std");
const rl = @import("raylib");
const zclay = @import("zclay");

pub fn main() !void
{
	rl.initWindow(600, 400, "Título");
	defer rl.closeWindow();

	while (!rl.windowShouldClose())
	{
		rl.beginDrawing();
		defer rl.endDrawing();
		rl.clearBackground(.ray_white);
	}
}