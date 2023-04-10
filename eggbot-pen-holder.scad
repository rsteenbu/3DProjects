include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

overlap=-1;

/*
left(20) diff("screwhole")
  cuboid([6, 6, 6], anchor=BOTTOM)
        attach(TOP, overlap=overlap)
          //screw("M4", l=8+overlap, tolerance="8g", anchor=BOTTOM);
	  tag ("screwhole") {
            screw("#6-32", l=8, tolerance="1B", anchor=TOP);
	  }
*/

xdistribute(30) {
//PenHolder(5.24);
PenHolder(6.24);
}


module PenHolder(pen_hole_radius=5.24) {
  1st_hole_xpos=-6;
  hole_spacing=6.5;
  diff("inside_space") {
    cuboid([20.25, 51.83, 6.10], anchor=BOTTOM);
    tag("inside_space") {
      move([0, 15.7, -.5]) cylinder(r=pen_hole_radius,h=7);
      move([0, 15.7 - pen_hole_radius, -.5]) cylinder(r=2,h=7);
      move([-6, 1st_hole_xpos, -.5]) cuboid([5,2.2,7], anchor=BOTTOM);
      move([-6, 1st_hole_xpos + hole_spacing -.5]) cuboid([5,2.2,7], anchor=BOTTOM);
      move([-6, 1st_hole_xpos + 2*hole_spacing, -.5]) cuboid([5,2.2,7], anchor=BOTTOM);
      move([5.325, -22.4, -.5], $fn=15) cylinder(r=1, h=7);
      move([-5.325, -22.4, -.5], $fn=15) cylinder(r=1, h=7);

      move([0, 23, 3.05]) xrot(90) screw("#6-32", l=8, tolerance="1B");

    }
  }
}
