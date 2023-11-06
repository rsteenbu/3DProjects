
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_pcb = false;

pcb_thickness = 1.6;
wall_width = 2;
plate_size = [40, 55, wall_width];
tolerance = .15;
overlap = 1;

mount_type="clip";  // scre or clip
pcb_height = 4;
//pcb_clip_size=[1.5,4.5];
pcb_clip_size=[2.0,4.5];

//arduino PCB stuff
70x50_pcb_size = [50, 70]; 
70x50_hole_diameter = 2;
70x50_hole_distance=[46,66];

//relay PCB stuff
relay_pcb_size = [25.5, 51];
relay_hole_diameter = 2;
relay_hole_distance=[20,45.26];

beefcake_relay_pcb_size = [30.5, 62.3];
beefcake_relay_hole_diameter = 3.25;
beefcake_relay_hole_distance=[25.50,50.76];
clip_tolerance = .2;

//DC-DC Converter LM2596
lm2596_pcb_size = [20.8,43.7];
lm2596_hole_diameter = 3.25;
lm2596_hole_distance=[lm2596_pcb_size.x-(2.76*2),lm2596_pcb_size.y-(6.77*2)];
lm2596_2_mount = true;



// mounting plate
//diff("center") {
cuboid([plate_size.x, plate_size.y, wall_width], anchor=BOTTOM) 
  attach(TOP, overlap=overlap) pcb_mounts(lm2596_pcb_size, lm2596_hole_distance, lm2596_hole_diameter, lm2596_2_mount);
  //attach(TOP, overlap=overlap) pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
//tag("center") down(.5) cuboid([plate_size.x-20, plate_size.y-20, wall_width+1], anchor=BOTTOM);
//}



module pcb_mounts(pcb_size, relay_hole_distance, hole_diameter, 2_mount=false) {
  if(print_pcb) 
    color("lightgreen") up (wall_width + pcb_height) cuboid(pcb_size, anchor=BOTTOM);
  back(((relay_hole_distance.y / 2) + tolerance)) { 
    down(overlap) pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance, 2_mount, true);
    fwd(relay_hole_distance.y) down(overlap) pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance, 2_mount, false);
  }
}

module pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance, 2_mount, y_mount) {
    //clip_cylinder_radius = 1;
    clip_cylinder_radius = 1.25;
    standoff_x = pcb_size.x - relay_hole_distance.x+overlap;
    for(x = [1, -1]) {
      // standoff 
      move([(relay_hole_distance.x / 2 )* x, 0]) 
	cuboid([standoff_x, 4.5, pcb_height+overlap], anchor=BOTTOM) 
	attach(TOP)  
	// really convoluded logic here to get diagonal mounts
	if (!2_mount || ( (x == -1 && !y_mount) || (x == 1 && y_mount) ) ) 
	  sphere(r=hole_diameter/2, anchor=CENTER, $fn=45);

      //clip
      pcb_clip_height=pcb_height+pcb_thickness+overlap+clip_tolerance;
      move([(pcb_size.x  / 2 + pcb_clip_size.x/2 )* x, 0])  {
	cuboid([pcb_clip_size.x, pcb_clip_size.y, pcb_clip_height], anchor=BOTTOM);
	up(pcb_clip_height+tolerance) fwd(pcb_clip_size.y/2) cylinder(h=pcb_clip_size.y, r=clip_cylinder_radius, $fn=45, orient=BACK);
      }
    }
}
