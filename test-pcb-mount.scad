
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

wall_width = 2;
plate_size = [35, 62, wall_width];
tolerance = .15;
overlap = .5;
print_pcb = false;

mount_type="clip";  // scre or clip
pcb_height = 10;

//arduino PCB stuff
70x50_pcb_size = [70, 50, 1.5]; 
70x50_PCB_HO = 2;   // PCB Hole Offset
70x50_hole_diameter = 2;

//relay PCB stuff
relay_pcb_size = [25.5, 51, 1.6];
relay_PCB_HO=2.75;  //center of mounting hole from l and w sides
relay_hole_diameter = 2;

esp32_pcb_size = [28.5, 50.6, 1.6];
esp32_PCB_HO=2.5;  //center of mounting hole from l and w sides
esp32_pcb_height = 9;
esp32_hole_diameter = 3;

// mounting plate
cuboid([plate_size.x, plate_size.y, wall_width], anchor=BOTTOM);

//pcb_mount(relay_pcb_size, relay_PCB_HO, "screw");
pcb_mount(esp32_pcb_size, esp32_PCB_HO, esp32_pcb_height, esp32_hole_diameter, "clip");

module pcb_mount(pcb_size, HO, pcb_height=4, hole_diameter, mount_type) {
  if(print_pcb) 
    color("lightgreen") up (wall_width + pcb_height) cuboid(pcb_size, anchor=BOTTOM);

  for(x = [1, -1]) {
    for(y = [1, -1]) {
      move([((pcb_size.x / 2) - HO) * x, ((pcb_size.y / 2) - HO + tolerance) * y, wall_width - overlap]) {
	if (mount_type == "screw")
	  cylinder(h=pcb_height+overlap, r=4, $fn=45)
	    attach(TOP, overlap=overlap) screw("M3", length=5+overlap, anchor=BOTTOM, $fn=45);
	if (mount_type == "clip") {
          pcb_clip_size=[4,1.5,pcb_height+pcb_size.z+overlap+hole_diameter/2];
	  back((HO+pcb_clip_size.y/2) * y) 
	  {
	    //clip
	    cuboid(pcb_clip_size, anchor=BOTTOM);
	    up(pcb_clip_size.z-tolerance) right(pcb_clip_size.x/2) fwd(pcb_clip_size.y*.17*y) cylinder(h=pcb_clip_size.x, r=1, $fn=45, orient=LEFT);
	  }

	  //standoff
	  //cuboid([4,5.2,pcb_height+overlap], anchor=BOTTOM)
	  cuboid([4,4.5,pcb_height+overlap], anchor=BOTTOM) 
	    attach(TOP) sphere(r=hole_diameter / 2, anchor=CENTER, $fn=45);
	}
      }
    }
  }
}
