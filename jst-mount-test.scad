include <my-general-libraries.scad>;

ydistribute(40) {
    diff("holes") cube([4.6,30,20], center=true)
      attach(RIGHT, overlap=2.0)  {
	tag("holes") jst_connector(3);
	back(5) yrot(180) linear_extrude(3) 
	  text("3", size=4, anchor=FRONT);
      }

    diff("holes") cube([4.6,30,20], center=true)
      attach(RIGHT, overlap=2.0)  {
	tag("holes") jst_connector(4);
	back(5) yrot(180) linear_extrude(3) 
	  text("4", size=4, anchor=FRONT);
      }
}

