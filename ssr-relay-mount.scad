include <BOSL2/std.scad>;
include <BOSL2/threading.scad>;
include <BOSL2/screws.scad>;
include <BOSL2/metric_screws.scad>;

overlap=1;
relay_mount_size = [2, 13.5, 4+overlap];
ssr_relay_size = [45,62,23];
wall_width = 2;



cuboid([60, 80, wall_width], anchor=BOTTOM)
  attach(TOP, overlap=overlap) relay_mount();


//cuboid([2, ssr_relay_size.y, 8], anchor=BOTTOM);

//move([0, ssr_relay_size.y/2 - 5/2, 0]) cuboid([2, 5, 20], anchor=BOTTOM);

/*

left (55) { 
  //threaded_nut(7, id=5, h=5, pitch=.5, $fn=45, anchor=BOTTOM)
  nut("M4", "hex", 5, 6, tolerance="7G", anchor=BOTTOM)
    attach(TOP, overlap=.5) cylinder(r=3.00, h=20, anchor=BOTTOM)
    attach(TOP, overlap=1.0) { 
      cuboid([2,8,2]);
      cuboid([8,2,2]);
    }
}
*/

//screw_mount();

left (45) { 
  //nut([spec], [shape], [thickness], [nutwidth], [thread=], [tolerance=], [hole_oversize=], [bevel=], [$slop=], [anchor=], [spin=], [orient=]) [ATTACHMENTS];
    //fwd(x) nut("M4", "hex", 3, 6, tolerance="7G");
    //fwd(x) nut("M4", "hex", 3, 6, tolerance="4H");
    //fwd(0) nut("M4", "hex", "thin", 6, thread="fine", $slop=-0.05, tolerance="4H");
    //fwd(20) nut("M4", "hex", "thin", 6, thread="fine", $slop=-0.1, tolerance="4H");
    //fwd(x) nut("M4", "hex", "normal", 6, thread="fine", $slop=-0.07, tolerance="4H");
  for (x = [0, 10]) {
    diff("slot")
    fwd(x) nut("M4", "hex", "normal", 6, thread="coarse", $slop=-0.08, tolerance="6H", anchor=BOTTOM) 
      tag("slot") attach(TOP, overlap=.4) cuboid([1,7,1]);
  }
}

module screw_mount() {
      cuboid([relay_mount_size.y, relay_mount_size.y, 1], anchor=BOTTOM)
	attach(TOP, overlap=overlap) 
	  //screw("M4", l=8+overlap, tolerance="8g", anchor=BOTTOM);
	  screw("M4", l=8+overlap, thread="coarse", tolerance="6g", anchor=BOTTOM);

}

module relay_mount() {
  notch_size = [7.9,2.5,2.9+overlap];
  for(y = [1, -1]) {
    move([0, (ssr_relay_size.y/2 - relay_mount_size.y/2) * y, 0]) {
      for(x = [1, -1]) {
	move([(ssr_relay_size.x/2 - relay_mount_size.x/2) * x, 0, 0])  
	  cuboid(relay_mount_size, anchor=BOTTOM);
      }

      cuboid([relay_mount_size.y, relay_mount_size.y, relay_mount_size.z], anchor=BOTTOM)
	attach(TOP, overlap=overlap) {
	  screw("M4", l=8+overlap, thread="coarse", tolerance="6g", anchor=BOTTOM);
	  back((relay_mount_size.y/2 - notch_size.y/2) * y) cuboid(notch_size, anchor=BOTTOM);
	}
    }
  }
}

