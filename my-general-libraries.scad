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


