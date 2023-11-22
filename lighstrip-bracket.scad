include <my-general-libraries.scad>;

/*
diff("holes") cube([4.6,30,20], center=true)
attach(RIGHT, overlap=2.0)  {
  tag("holes") jst_connector(3);
  back(5) yrot(180) linear_extrude(3) 
    text("3", size=4, anchor=FRONT);
}

*/

strip_dimensions=[12,4,1.5];
tab_length = 6;
bracket_length = strip_dimensions.x+tab_length*2+strip_dimensions.z*2;


for (y = [0:strip_dimensions.y+2:200]) translate([0, y, 0]) 
//    for (x = [0:bracket_length+2:(bracket_length+2)*4]) translate([x, 0, 0]) 
      xrot(90) diff("blanks") { 
	translate([0,.1,.1]) cube([bracket_length, 6, strip_dimensions.y+strip_dimensions.z]);
	tag("blanks") {
	  translate([tab_length+strip_dimensions.z,0,0]) cube([strip_dimensions.x, 6.2, strip_dimensions.y]);

	  translate([-.1,0,strip_dimensions.z]) cube([tab_length, 6.2, strip_dimensions.y+.2]);
	  translate([tab_length/2,strip_dimensions.y/2+1,0]) cylinder(r=1, h=strip_dimensions.z*2+.1, $fn=20);

	  translate([tab_length+strip_dimensions.z+strip_dimensions.x+strip_dimensions.z,0,0]) {
	    translate([0,0,strip_dimensions.z]) cube([tab_length+.1, 6.2, strip_dimensions.y+.2]);
	    translate([tab_length/2,strip_dimensions.y/2+1,0]) cylinder(r=1, h=strip_dimensions.z*2+.1, $fn=20);
	  }

	}
      }

