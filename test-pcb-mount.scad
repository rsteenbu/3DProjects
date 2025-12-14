include <BOSL2/std.scad>;
include <pcb-mount.scad>;

wall_width = 1;
overlap = .1;

size = [60, 80, 55];
pcb_size = get_pcb_size("70x50");
hole_distance = get_pcb_hole_distance("70x50");

cuboid([size.x, size.y, wall_width], anchor=BOTTOM);
pcb_screw_mount(pcb_height=4.0, hole_diameter=2.5, mount_size=[5,5,4.5]);
