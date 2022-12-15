
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_psu = false;;

wall_width = 3;
plate_size = [75, 75, 2];
tolerance = .15;
overlap = 1;

psu_size = [63.1, 51.3, 28.5];
screw_height = 16;
screw_distance = 39.25;
mount_height = 4;
pcb_thickness = 1.6;
top_anchor_overhang = 2;

//cuboid(plate_size, anchor=BOTTOM) attach(TOP, overlap=overlap) 5v_psu_mount(psu_size, anchor=BOTTOM);

module 5v_psu_mount() {
  diff("screwholes") {
    // lengthwise base mounts
    back(psu_size.y / 2 + wall_width / 2 + tolerance) {
      down(overlap) cuboid([psu_size.x + tolerance*2, wall_width, mount_height+overlap], anchor=BOTTOM);
      right(psu_size.x / 2 - 12) { 
	// top anchor brackets
	//cuboid([8, wall_width, psu_size.z+overlap], anchor=BOTTOM);
	up(psu_size.z+tolerance) fwd((top_anchor_overhang)/2) cuboid([8, wall_width+top_anchor_overhang,  wall_width], anchor=BOTTOM);
      }
    }
    fwd(psu_size.y / 2 + wall_width / 2 + tolerance) {
      down(overlap) cuboid([psu_size.x + tolerance*2, wall_width, mount_height+overlap], anchor=BOTTOM);

      // screw hole mount posts
      right(psu_size.x / 2 - 12) {
	cuboid([8, wall_width, screw_height+4], anchor=BOTTOM) 
	  tag("screwholes") attach([FRONT], overlap=-overlap) 
	  fwd((screw_height+4)/2 + overlap) back(screw_height + overlap) 
	  cylinder(r=1.5+tolerance, h=wall_width+2*overlap, $fn=45, anchor=TOP);
	left(screw_distance) { 
	  cuboid([8, wall_width, screw_height+4], anchor=BOTTOM)
	    tag("screwholes") attach([FRONT], overlap=-overlap)
	    fwd((screw_height+4)/2 + overlap) back(screw_height + overlap)
	    cylinder(r=1.5+tolerance, h=wall_width+2*overlap, $fn=45, anchor=TOP);
	  if (print_psu) color("lightgreen") fwd(1.8) cuboid([.1, .1, screw_height], anchor=BOTTOM);
	}
      }
    }

    // back base mount
    right(psu_size.x / 2 + wall_width / 2 + tolerance) {
      down(overlap) cuboid([wall_width, psu_size.y+wall_width*2+tolerance*2, mount_height+overlap], anchor=BOTTOM)
        if (print_psu) attach([LEFT]) {
	  color("red") right(psu_size.y/2 + wall_width + .5) back(screw_height - mount_height/2) up(tolerance) cuboid([8,.1,12], anchor=BOTTOM);
	  color("lightblue") right(psu_size.y/2 + wall_width + .4) back(screw_height - mount_height/2) up(tolerance) cuboid([.1,.1,12+screw_distance], anchor=BOTTOM);
	}
    }

    if (print_psu) {
      color("lightgreen") cuboid(psu_size, anchor=BOTTOM);
    }
  }
}
