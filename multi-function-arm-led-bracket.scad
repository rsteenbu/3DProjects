
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

wall_width = 2;
tolerance = .15;
overlap = 1;


//relay PCB stuff
led_screw_placement = [16, 68];
arm_screw_placement = [30, 30]; 

diff("screws") {
  cuboid([50, 85, 6], chamfer=1, anchor=BOTTOM);
  tag("screws") {
    for(x = [1, -1]) {
      for(y = [1, -1]) {
	move([led_screw_placement.x/2 * x, led_screw_placement.y/2 * y, 0]) { 
	  up(3.0) cylinder(4, r=4.1, $fn=44);
	  down(.5) cylinder(5, r=2.1, $fn=44);
	}
	move([arm_screw_placement.x/2 * x, arm_screw_placement.y/2 * y, 0]) { 
	  down(.5) cylinder(3.5, r=5.1, $fn=44);
	  up(2) cylinder(5, r=2.6, $fn=44);
	}
      }
    }
  }
}

