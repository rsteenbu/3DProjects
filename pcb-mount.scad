
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_pcb = false;

pcb_thickness = 1.6;
wall_width = 2;
plate_size = [40, 70, wall_width];
tolerance = .15;
//overlap = .5;

mount_type="clip";  // scre or clip
pcb_height = 4;
pcb_clip_size=[1.5,4.5];

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

// mounting plate
//cuboid([plate_size.x, plate_size.y, wall_width], anchor=BOTTOM);

//pcb_mount(relay_pcb_size, relay_PCB_HO, "screw");
//  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
//  cuboid([plate_size.x, plate_size.y, wall_width], anchor=BOTTOM);
//  pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter);

module pcb_mounts(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance=0) {
  if(print_pcb) 
    color("lightgreen") up (wall_width + pcb_height) cuboid(pcb_size, anchor=BOTTOM);
  back(((relay_hole_distance.y / 2) + tolerance)) { 
    down(overlap) pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance);
    fwd(relay_hole_distance.y) down(overlap) pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance);
  }
}

module pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance) {
    clip_cylinder_radius = 1;
    standoff_x = pcb_size.x - relay_hole_distance.x+overlap;
    for(x = [1, -1]) {
	  // standoff 
	  move([(relay_hole_distance.x / 2 )* x, 0]) 
	    cuboid([standoff_x, 4.5, pcb_height+overlap], anchor=BOTTOM) 
	    attach(TOP)  sphere(r=hole_diameter/2, anchor=CENTER, $fn=45);

	  //clip
	  pcb_clip_height=pcb_height+pcb_thickness+overlap+clip_tolerance;
	  move([(pcb_size.x  / 2 + pcb_clip_size.x/2 )* x, 0])  {
	    cuboid([pcb_clip_size.x, pcb_clip_size.y, pcb_clip_height], anchor=BOTTOM);
	    up(pcb_clip_height+tolerance) fwd(pcb_clip_size.y/2) cylinder(h=pcb_clip_size.y, r=clip_cylinder_radius, $fn=45, orient=BACK);
	  }
    }
}
