include <BOSL2/std.scad>;
include <pcb-mount.scad>;

wall_width = 1;
overlap = 1;
tolerance = .15;

size = [20, 20, 55];
pcb_size = get_pcb_size("70x50");
hole_distance = get_pcb_hole_distance("70x50");

cuboid([size.x, size.y, wall_width], anchor=BOTTOM)
attach([TOP], overlap=overlap) {
//    pcb_screw_mount(pcb_height=9.0, mount_size=[5,5,7]);
  diff()
    cuboid([5,5,7], anchor=BOTTOM)
    attach(TOP) screw_hole("M2.5x.35", length=5, $fn=100, thread=false, counterbore=0, anchor=TOP);
}
