include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_pcb = false;

pcb_thickness = 1.6;
wall_width = 3;
overlap = 1;

mount_type="clip";  // scre or clip
//pcb_clip_size=[1.5,4.5];
pcb_mount_size=[2,8];



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

// wasatch eight
wasatch8_pcb_size = [100,100];
wasatch8_hole_diameter = 3.5;
wasatch8_hole_distance=[wasatch8_pcb_size.x-(3.5*2),wasatch8_pcb_size.y-(3.5*2)];

plate_size = [120, 120, wall_width];


// mounting plate
//diff("center") {
//cuboid([plate_size.x, plate_size.y, wall_width], anchor=BOTTOM) 
//  attach(TOP, overlap=overlap) pcb_mounts(wasatch8_pcb_size, wasatch8_hole_distance, wasatch8_hole_diameter);
  //attach(TOP, overlap=overlap) pcb_mounts(lm2596_pcb_size, lm2596_hole_distance, lm2596_hole_diameter, lm2596_2_mount);
  //attach(TOP, overlap=overlap) pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
//tag("center") down(.5) cuboid([plate_size.x-20, plate_size.y-20, wall_width+1], anchor=BOTTOM);
//}

module ssr_mount(relay_mount_size=[2,13.5,9], ssr_relay_size=[45,62,23], overlap=1) {
  notch_size = [7.9,2.5,2.9+overlap];
  for(y = [1, -1]) {
    move([0, (ssr_relay_size.y/2 - relay_mount_size.y/2) * y, 0]) {
      for(x = [1, -1]) {
	move([(ssr_relay_size.x/2 - relay_mount_size.x/2) * x, 0, 0])  
	  cuboid(relay_mount_size, anchor=BOTTOM);
      }

      diff("nuthole") 
      cuboid([relay_mount_size.y, relay_mount_size.y, relay_mount_size.z], anchor=BOTTOM)
	attach(TOP, overlap=overlap) {
	  //screw("M4", l=8+overlap, thread="coarse", tolerance="6g", anchor=BOTTOM);
	  tag("nuthole") {
	    up(2) cylinder(h=9, r=2.5, $fn=20, anchor=TOP);
            translate([0,5.5,-5]) cuboid([7.9,20,3.1], anchor=BOTTOM);
	  }
	  back((relay_mount_size.y/2 - notch_size.y/2) * y) cuboid(notch_size, anchor=BOTTOM);
	}
    }
  }
}

module ssr_mount_v1(relay_mount_size=[2,13.5,5], ssr_relay_size=[45,62,23], overlap=1) {
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


module 70x50_pcb_mount(pcb_height=7, pcb_mount_width=9) {
//arduino PCB stuff
  70x50_pcb_size = [50 + clip_tolerance, 70 + clip_tolerance]; 
  70x50_hole_diameter = 2;
  70x50_hole_distance=[46,66];

  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter, false, pcb_height, pcb_mount_width);
}

module pcb_mounts(pcb_size, relay_hole_distance, hole_diameter, 2_mount=false, pcb_height=4, pcb_mount_width=7) {
  if(print_pcb) 
    color("lightgreen") up (wall_width + pcb_height) cuboid(pcb_size, anchor=BOTTOM);
  translate([0, relay_hole_distance.y / 2, 0]) {
    down(overlap) pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance, 2_mount, true, pcb_height, pcb_mount_width);
    fwd(relay_hole_distance.y) down(overlap) pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance, 2_mount, false, pcb_height, pcb_mount_width);
  }
}

module pcb_clips(pcb_size, relay_hole_distance, hole_diameter, clip_tolerance, 2_mount, y_mount, pcb_height=4, pcb_mount_width=7) {
    //clip_cylinder_radius = 1;
    clip_cylinder_radius = 1.25;
    standoff_x = pcb_size.x - relay_hole_distance.x+overlap;
    for(x = [1, -1]) {
      // standoff 
      move([(relay_hole_distance.x / 2 )* x, 0]) 
	cuboid([standoff_x, pcb_mount_width, pcb_height+overlap], anchor=BOTTOM) 
	attach(TOP)  
	// really convoluded logic here to get diagonal mounts
	if (!2_mount || ( (x == -1 && !y_mount) || (x == 1 && y_mount) ) ) 
	  sphere(r=hole_diameter/2, anchor=CENTER, $fn=45);

      //clip
      pcb_clip_height=pcb_height+pcb_thickness+overlap+clip_tolerance;
      move([(pcb_size.x  / 2 + pcb_mount_size.x/2) * x , 0])  {
	cuboid([pcb_mount_size.x, pcb_mount_width, pcb_clip_height], anchor=BOTTOM);
	up(pcb_clip_height+tolerance) fwd(pcb_mount_width/2) cylinder(h=pcb_mount_width, r=clip_cylinder_radius, $fn=45, orient=BACK);
      }
    }
}
