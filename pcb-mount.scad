include <BOSL2/std.scad>;
include <BOSL2/screws.scad>;


// ========================================
// Global Configuration Parameters
// ========================================

// General settings
print_pcb = false;           // Render PCB visualization
pcb_thickness = 1.6;        // Standard PCB thickness (mm)

// Clip mount configuration
clip_tolerance = 0.2;       // Clearance for PCB in clip mounts (mm)
clip_cylinder_radius = 1.25; // Radius of clip retaining cylinder (mm)
clip_wall_thickness = 2;    // Thickness of clip walls (mm)
clip_standoff_from_edge = 1; // Distance from clip edge to PCB (mm)

// Rendering quality
sphere_fn = 45;             // $fn value for spheres
cylinder_fn = 20;           // $fn value for cylinders (lower quality)

// PCB Configuration Data Structure
// Each PCB config is a vector: [width, length], [hole_distance_x, hole_distance_y], hole_diameter, use_2_mount]
// use_2_mount: optional boolean, defaults to false if not specified
PCB_CONFIGS = [
  ["70x50",          [[50, 70],     [46,66],                        2,    false ]],
  ["relay",          [[25.5, 51],   [20,45.26],                     2,    false ]],
  ["beefcake_relay", [[30.5, 62.3], [25.50, 50.76],                 3.25, false ]],
  // DC-DC Converter LM2596
  ["lm2596",         [[20.8, 43.7], [20.8-(2.76*2), 43.7-(6.77*2)], 3.25, true]],
  ["wasatch8",       [[100, 100],   [100-(3.5*2),   100-(3.5*2)],   3.5,  false]],
  ["EARU-ssr",       [[45, 60],     [0, 47],                        5,    true]]
];

// Helper functions to extract PCB configuration values
function pcb_config(pcb_name) =
  let(pcb_config = search([pcb_name], PCB_CONFIGS)[0])
  pcb_config != [] ? PCB_CONFIGS[pcb_config][1] : undef;

function get_pcb_size(pcb_name) = pcb_config(pcb_name)[0];
function get_pcb_hole_distance(pcb_name) = pcb_config(pcb_name)[1];
function get_pcb_hole_diameter(pcb_name) = pcb_config(pcb_name)[2];

module pcb_clip_mount(pcb_type, pcb_height=7, mount_size, mount_elevation=0) {
   //2_mount: put the mounting sheres only on two of the mounting posts
   //y_mount: if 2_mount put the mounting spheres on the y axis posts
   2_mount=false;
   y_mount=false;
   width=pcb_size.x+clip_tolerance;
   length=pcb_size.y+clip_tolerance;
   
   pcb_clip_height=pcb_height+pcb_thickness+overlap+clip_tolerance;
   down(overlap) color("lightblue") translate([width/2,(length - hole_distance.y)/2, mount_elevation])
    for (y = [-1, 1]) {
     for(x = [0, -1]) {
       translate([width * x, (hole_distance.y/2 * y) - (length - hole_distance.y)/2] ) 
         zrot(180*x) {
           cuboid([mount_size.x, mount_size.y, pcb_height+overlap], anchor=BOTTOM+RIGHT)
             attach(TOP)
             // really convoluded logic here to get diagonal mounts
             if (!2_mount || ( y_mount && (x == -1 ) ) )
                    sphere(r=hole_diameter/2, anchor=CENTER, $fn=sphere_fn);
              translate([clip_standoff_from_edge, 0]) {
             cuboid([clip_wall_thickness, mount_size.y, pcb_clip_height], anchor=BOTTOM);
             up(pcb_clip_height+tolerance) fwd(mount_size.y/2)
               cylinder(h=mount_size.y, r=clip_cylinder_radius, $fn=sphere_fn, orient=BACK );
           } // translate
       } // zrot
     } // for x
    } // for y

  if(print_pcb) color("lightgreen", .5) 
    //translate([-pcb_size.x/2, 2,  pcb_height])
    //translate([-pcb_size.x/2, -pcb_size.y/2+wall_width,  pcb_height])
    translate([0, 0,  pcb_height])
    cuboid([pcb_size.x, pcb_size.y, pcb_thickness], anchor=BOTTOM);
}

//module pcb_screw_mount(pcb_size, relay_hole_distance, hole_diameter, pcb_height=4, pcb_mount_width=7) {
module pcb_screw_mount(pcb_height=7, mount_size, mount_elevation=0) {
  if(print_pcb) color("lightgreen", .2) up (wall_width + pcb_height)
    cuboid(pcb_size, anchor=BOTTOM);

  translate([0, hole_distance.y / 2, wall_width + pcb_height - mount_size.z]) {
    standoff_x = pcb_size.x - hole_distance.x+overlap;
    for(y = [0, -1]) {
      for(x = [1, -1]) {
        translate([(hole_distance.x / 2 )* x, hole_distance.y * y]) 
          diff() 
	    cuboid(mount_size, anchor=BOTTOM)
	      attach(TOP) 
<<<<<<< Updated upstream
	        screw_hole("M2.5x.35", length=5, $fn=100, thread=false, counterbore=0, anchor=TOP);
=======
	        screw_hole("M2.5x.35", length=6, $fn=100, thread=true, counterbore=0, anchor=TOP);

>>>>>>> Stashed changes
      }
    }
  }
}

module ssr_mount() {

}
