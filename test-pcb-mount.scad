include <BOSL2/std.scad>;
include <pcb-mount.scad>;

wall_width = 3;
overlap = 1;
tolerance = .15;

size = [82, 120, 55];
pcb_size = get_pcb_size("70x50");
hole_distance = get_pcb_hole_distance("70x50");

cuboid([size.x, size.y, wall_width], anchor=BOTTOM) 
attach([TOP], overlap=overlap) {
  translate([0, ((size.x - wall_width*4)/2 - pcb_size.x/2) , 0])
    pcb_screw_mount(pcb_height=7.0, mount_size=[7,7,10]);
}
