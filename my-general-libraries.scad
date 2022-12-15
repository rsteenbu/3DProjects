include <BOSL2/std.scad>;

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


