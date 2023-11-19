include <BOSL2/std.scad>;

/*
cuboid([10, 60, 2], anchor=BOTTOM);
diff("hole") 
  cuboid([4, 60, 30], anchor=BOTTOM)
  attach(LEFT, overlap=6) 
  tag("hole") c14_plug_v2([27,19,7]);
*/

module c14_plug_v2(size) {
  cuboid(size, rounding=3,
      edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT],
      $fn=24,
      anchor=BOTTOM
      );
  for(x = [1, -1]) {
    translate([(size.x/2 + 7) * x, 0, 0]) cylinder(h=size.z, r=2, $fn=24, anchor=BOTTOM);
  }

}
module prismoidal(size, anchor=CENTER) {
    scale=0.5;
    attachable(anchor, 0, UP, size=size, size2=[size.x, size.y] * scale) {
        hull() {
	  up(size.z/2-0.005) linear_extrude(height=0.01, center=true)
	    square([size.x*scale,size.y], center=true);
	  down(size.z/2-0.005) linear_extrude(height=0.01, center=true)
	    square([size.x,size.y], center=true);
	}
        children();
    }
}

//  cube([4.6,30,20], center=true)
//    attach(RIGHT, overlap=2.0) tag("holes") jst_hole();
module jst_connector(pins=3) {
  
  union() {
    // depression
    translate([0,0,1.5]) {
      if (pins == 3) cube([17,10,3.0], center=true);
      if (pins == 4) cube([20,10,3.0], center=true);
    }
    // jst hole
    translate([0,0,-2.5]) { 
      if (pins == 3) cube([12,5,6], center=true);
      if (pins == 4) cube([15,5,6], center=true);
    }
    // top notch
    translate([0,3.0,-2.5]) cube([3.1,2.0,6], center=true);
  }

}


