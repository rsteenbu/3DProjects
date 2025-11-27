include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_pcb = true;

pcb_thickness = 1.6;
wall_width = 3;
overlap = 1;

mount_type="clip";  // screw or clip
//pcb_clip_size=[1.5,4.5];
pcb_mount_size=[7,9];

clip_tolerance = .2;
clip_cylinder_radius = 1.25;

// PCB Configuration Data Structure
// Each PCB config is a vector: [width, height, hole_diameter, hole_distance_x, hole_distance_y, use_2_mount]
// use_2_mount: optional boolean, defaults to false if not specified

PCB_CONFIGS = [
  // 70x50 PCB
  ["70x50", [
    50 + clip_tolerance,  // width
    70 + clip_tolerance,  // height
    2,                    // hole_diameter
    46,                   // hole_distance_x
    66,                   // hole_distance_y
    false                 // use_2_mount
  ]],

  // Relay PCB
  ["relay", [
    25.5,                 // width
    51,                   // height
    2,                    // hole_diameter
    20,                   // hole_distance_x
    45.26,                // hole_distance_y
    false                 // use_2_mount
  ]],

  // Beefcake Relay
  ["beefcake_relay", [
    30.5,                 // width
    62.3,                 // height
    3.25,                 // hole_diameter
    25.50,                // hole_distance_x
    50.76,                // hole_distance_y
    false                 // use_2_mount
  ]],

  // DC-DC Converter LM2596
  ["lm2596", [
    20.8,                 // width
    43.7,                 // height
    3.25,                 // hole_diameter
    20.8-(2.76*2),        // hole_distance_x
    43.7-(6.77*2),        // hole_distance_y
    true                  // use_2_mount
  ]],

  // Wasatch Eight
  ["wasatch8", [
    100,                  // width
    100,                  // height
    3.5,                  // hole_diameter
    100-(3.5*2),          // hole_distance_x
    100-(3.5*2),          // hole_distance_y
    false                 // use_2_mount
  ]]
];

// Helper functions to extract PCB configuration values
function pcb_config(name) =
  let(config = search([name], PCB_CONFIGS)[0])
  config != [] ? PCB_CONFIGS[config][1] : undef;

function get_pcb_width(name) = pcb_config(name)[0];
function get_pcb_height(name) = pcb_config(name)[1];
function get_pcb_hole_diameter(name) = pcb_config(name)[2];
function get_pcb_hole_distance_x(name) = pcb_config(name)[3];
function get_pcb_hole_distance_y(name) = pcb_config(name)[4];
function get_pcb_use_2_mount(name) = pcb_config(name)[5];

function get_pcb_size(name) = [get_pcb_width(name), get_pcb_height(name), pcb_thickness];
function get_pcb_hole_distance(name) = [get_pcb_hole_distance_x(name), get_pcb_hole_distance_y(name)];

// Legacy variable support (for backward compatibility)

plate_size = [120, 120, wall_width];

module ssr_mount(relay_mount_size=[2,13.5,9], ssr_relay_size=[45,62,23], overlap=1) {
  notch_size = [7.9,2.5,2.9+overlap];
  for(y = [1, -1]) {
    translate([0, (ssr_relay_size.y/2 - relay_mount_size.y/2) * y, 0]) {
      for(x = [1, -1]) {
      	translate([(ssr_relay_size.x/2 - relay_mount_size.x/2) * x, 0, 0])  
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
    translate([0, (ssr_relay_size.y/2 - relay_mount_size.y/2) * y, 0]) {
      for(x = [1, -1]) {
      	translate([(ssr_relay_size.x/2 - relay_mount_size.x/2) * x, 0, 0])  
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

module 70x50_pcb_screw_mount(pcb_height=7, pcb_mount_width=9) {
  pcb_screw_mount(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
}

//module pcb_clip_mount(pcb_size, hole_distance, hole_diameter, pcb_height=4, mount_size=[7,8]) {
module pcb_clip_mount(pcb_height=4, mount_size=[7,8]) {
   //2_mount: put the mounting sheres only on two of the mounting posts
   //y_mount: if 2_mount put the mounting spheres on the y axis posts
   2_mount=false;
   y_mount=false;
   echo("hole_distance: ", hole_distance);
   echo("pcb_size: ", pcb_size);
   pcb_clip_height=pcb_height+pcb_thickness+overlap+clip_tolerance;
   down(overlap) color("lightblue") translate([pcb_size.x/2,(pcb_size.y - hole_distance.y)/2])
    for (y = [-1, 1]) {
     for(x = [0, -1]) {
       translate([pcb_size.x * x, (hole_distance.y/2 * y) - (pcb_size.y - hole_distance.y)/2] ) 
         zrot(180*x) {
           cuboid([mount_size.x, mount_size.y, pcb_height+overlap], anchor=BOTTOM+RIGHT)
             attach(TOP)  
             // really convoluded logic here to get diagonal mounts
             if (!2_mount || ( y_mount && (x == -1 ) ) )
                    sphere(r=hole_diameter/2, anchor=CENTER, $fn=45);
              translate([1, 0]) {
             cuboid([2, mount_size.y, pcb_clip_height], anchor=BOTTOM);
             up(pcb_clip_height+tolerance) fwd(mount_size.y/2) 
               cylinder(h=mount_size.y, r=clip_cylinder_radius, $fn=45, orient=BACK );
           } // translate
       } // zrot
     } // for x
     } // for y

  if(print_pcb) color("lightgreen", .2) 
    //translate([-pcb_size.x/2, 2,  pcb_height])
    //translate([-pcb_size.x/2, -pcb_size.y/2+wall_width,  pcb_height])
    translate([0, 0,  pcb_height])
    cuboid([pcb_size.x, pcb_size.y, pcb_height], anchor=BOTTOM);
}

module pcb_screw_mount(pcb_size, relay_hole_distance, hole_diameter, pcb_height=4, pcb_mount_width=7) {
  if(print_pcb) color("lightgreen") up (wall_width + pcb_height)
    cuboid(pcb_size, anchor=BOTTOM);

  translate([0, relay_hole_distance.y / 2, 0]) {
    standoff_x = pcb_size.x - relay_hole_distance.x+overlap;
    for(y = [0, -1]) {
      for(x = [1, -1]) {
        translate([(relay_hole_distance.x / 2 )* x, relay_hole_distance.y * y]) 
          cuboid([pcb_mount_size.x, pcb_mount_size.y, pcb_height+overlap], anchor=BOTTOM);
      }
    }
  }
}
