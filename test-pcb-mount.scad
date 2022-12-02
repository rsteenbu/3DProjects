
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

wall_width = 2;
plate_size = [45, 62, wall_width];
tolerance = .15;
overlap = .5;
print_pcb = false;

mount_type="70x50_breadboard";  // relay or 70x50_breadboard
pcb_height = 4;

//arduino PCB stuff
70x50_pcb_size = [70, 50, 1.5]; 
pcb_hole_diameter = 2;
70x50_PCB_HO = 2;   // PCB Hole Offset
pcb_clip_size=[4,1.5,pcb_height+70x50_pcb_size.z+overlap+pcb_hole_diameter/2];

//relay PCB stuff
relay_pcb_size = [25.5, 51, 1.6];
relay_PCB_HO=2.75;

if(print_pcb) 
  color("lightgreen") up (wall_width + pcb_height) cuboid(70x50_pcb_size, anchor=BOTTOM);

cuboid([plate_size.x, plate_size.y, wall_width], anchor=BOTTOM);

//arduino_pcb();
pcb_mount(relay_pcb_size, relay_PCB_HO, "relay");

module pcb_mount(pcb_size, HO, mount_type) {
  for(x = [1, -1]) {
    for(y = [1, -1]) {
      move([((pcb_size.x / 2) - HO) * x, ((pcb_size.y / 2) - HO + tolerance) * y, wall_width - overlap]) {
	if (mount_type == "relay")
	  cylinder(h=pcb_height+overlap, r=4, $fn=45)
	    attach(TOP, overlap=overlap) screw("M3", length=5+overlap, anchor=BOTTOM, $fn=45);
	if (mount_type == "70x50_breadboard") {
	  back((HO+pcb_clip_size.y/2) * y) 
	  {
	    //clip
	    cuboid(pcb_clip_size, anchor=BOTTOM);
	    up(pcb_clip_size.z-tolerance) right(pcb_clip_size.x/2) fwd(pcb_clip_size.y*.17*y) cylinder(h=pcb_clip_size.x, r=1, $fn=45, orient=LEFT);
	  }

	  //standoff
	  cylinder(h=pcb_height+overlap, r=3, $fn=45)
	    attach(TOP) sphere(r=pcb_hole_diameter / 2, anchor=CENTER, $fn=45);
	}
      }
    }
  }
}
