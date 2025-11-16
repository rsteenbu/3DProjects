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

// led strip width, bracket width, led strip height
strip_dimensions=[12,7,3.8];
bracket_thickness=1.5;
bracket_tab_length = 7;
bracket_length = strip_dimensions.x+bracket_tab_length*2+bracket_thickness*2;
screw_hole_diameter = 2.9;


xrot(90) diff("blanks") { 
  translate([0,.1,.1]) 
    cube([bracket_length, strip_dimensions.y, strip_dimensions.z+bracket_thickness]);
  tag("blanks") {
    translate([bracket_tab_length+bracket_thickness,0,0]) 
      cube([strip_dimensions.x, strip_dimensions.y + .2, strip_dimensions.z]);

    translate([-.1,0,bracket_thickness]) 
      cube([bracket_tab_length, strip_dimensions.y + .2, strip_dimensions.z+.2]);
    translate([bracket_tab_length/2,strip_dimensions.y/2,0]) {
      cylinder(r=screw_hole_diameter/2, h=bracket_thickness*2+.1, $fn=20);
      translate([0,0,3.2]) sphere(r=3, $fn=20);
    }

    translate([bracket_tab_length+bracket_thickness+strip_dimensions.x+bracket_thickness,0,0]) {
      translate([0,0,bracket_thickness]) 
        cube([bracket_tab_length+.1, strip_dimensions.y + .2, strip_dimensions.z+.2]);
      translate([bracket_tab_length/2,strip_dimensions.y/2,0]) { 
	cylinder(r=screw_hole_diameter/2, h=bracket_thickness*2+.1, $fn=20);
	translate([0,0,3.2]) sphere(r=3, $fn=20);
      }
    }

  }
}

