include <my-general-libraries.scad>;
include <BOSL2/std.scad>;

/*
diff("holes") cube([4.6,30,20], center=true)
attach(RIGHT, overlap=2.0)  {
  tag("holes") jst_connector(3);
  back(5) yrot(180) linear_extrude(3) 
    text("3", size=4, anchor=FRONT);
}

*/

strip_dimensions=[12,7,3.8];
strip_thickness=1.5;
tab_length = 7;
bracket_length = strip_dimensions.x+tab_length*2+strip_thickness*2;
screw_hole_diameter = 2.9;

max_print_size = 200;


for (y = [0:strip_dimensions.z+2:max_print_size]) translate([0, y, 0]) 
//    for (x = [0:bracket_length+2:(bracket_length+2)*4]) translate([x, 0, 0]) 
      xrot(90) diff("blanks") { 
	translate([0,.1,.1]) cube([bracket_length, strip_dimensions.y, strip_dimensions.z+strip_thickness]);
	tag("blanks") {
	  translate([tab_length+strip_thickness,0,0]) cube([strip_dimensions.x, strip_dimensions.y + .2, strip_dimensions.z]);

	  translate([-.1,0,strip_thickness]) 
	    cube([tab_length, strip_dimensions.y + .2, strip_dimensions.z+.2]);
	  translate([tab_length/2,strip_dimensions.y/2,0]) {
	    cylinder(r=screw_hole_diameter/2, h=strip_thickness*2+.1, $fn=20);
	    translate([0,0,3.2]) sphere(r=3, $fn=20);
	  }

	  translate([tab_length+strip_thickness+strip_dimensions.x+strip_thickness,0,0]) {
	    translate([0,0,strip_thickness]) cube([tab_length+.1, strip_dimensions.y + .2, strip_dimensions.z+.2]);
	    translate([tab_length/2,strip_dimensions.y/2,0]) { 
	      cylinder(r=screw_hole_diameter/2, h=strip_thickness*2+.1, $fn=20);
	      translate([0,0,3.2]) sphere(r=3, $fn=20);
	    }
	  }

	}
      }

