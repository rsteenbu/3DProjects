include <BOSL2/std.scad>;
include <pcb-mount.scad>;

wall_width = 1;
overlap = .1;

size = [60, 80, 55];
print_pcb = false;           // Render PCB visualization

cuboid([size.x, size.y, wall_width], anchor=BOTTOM);
//pcb_screw_mount("70x50", pcb_height=4.0);
//pcb_clip_mount("70x50", pcb_height=5);
ssr_mount("EARU-ssr");
