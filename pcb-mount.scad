include <BOSL2/std.scad>;
include <BOSL2/screws.scad>;


// ========================================
// Global Configuration Parameters
// ========================================

// General settings
print_pcb = false;           // Render PCB visualization

// Clip mount configuration
clip_tolerance = 0.1;       // Clearance for PCB in clip mounts (mm)
clip_cylinder_radius = 1.25; // Radius of clip retaining cylinder (mm)
clip_wall_thickness = 2;    // Thickness of clip walls (mm)
clip_standoff_from_edge = 1; // Distance from clip edge to PCB (mm)

// Rendering quality
sphere_fn = 45;             // $fn value for spheres
cylinder_fn = 20;           // $fn value for cylinders (lower quality)

// PCB Configuration Data Structure
// Each PCB config is a vector: pcb_size, [hole_distance_x, hole_distance_y], mount_size, hole_diameter, hole_depth use_2_mount]
// use_2_mount: optional boolean, defaults to false if not specified
PCB_CONFIGS = [
  ["70x50",          [[50, 70, 1.6],  [46,66],      [5,5,4.5], 1.94, 5, false]],
  ["relay",          [[25.5, 51],   [20,45.26],     [5,5,4.5], 2,    5, false]],
  ["beefcake_relay", [[30.5, 62.3], [25.50, 50.76], [5,5,4.5], 3.25, 5, false]],
  // DC-DC Converter LM2596
  ["lm2596",         [[20.8, 43.7], [15.28, 30.16], [5,5,4.5], 3.25, 5, true]],
  ["wasatch8",       [[100, 100],   [93, 93],       [5,5,4.5], 3.5,  5, false]],
  ["EARU-ssr",       [[45, 60],     [45, 49],       [10,10,8], 3.3,  7.5, true]]
];

// Helper functions to extract PCB configuration values
function pcb_config(pcb_name) =
  let(pcb_config = search([pcb_name], PCB_CONFIGS)[0])
  pcb_config != [] ? PCB_CONFIGS[pcb_config][1] : undef;

function get_pcb_size(pcb_name)          = pcb_config(pcb_name)[0];
function get_pcb_hole_distance(pcb_name) = pcb_config(pcb_name)[1];
function get_pcb_mount_size(pcb_name)    = pcb_config(pcb_name)[2];
function get_pcb_hole_diameter(pcb_name) = pcb_config(pcb_name)[3];
function get_pcb_hole_depth(pcb_name)    = pcb_config(pcb_name)[4];
function get_pcb_2_mount(pcb_name)       = pcb_config(pcb_name)[5];

module pcb_clip_mount(name, pcb_height=7, pcb_height=4) {
  pcb_size = get_pcb_size(name);
  hole_depth = get_pcb_hole_depth(name);
  hole_distance = get_pcb_hole_distance(name);
  hole_diameter = get_pcb_hole_diameter(name);
  mount_size = get_pcb_mount_size(name);
  2_mount = get_pcb_2_mount(name);
  //y_mount: if 2_mount put the mounting spheres on the y axis posts
  y_mount=false;
  width=pcb_size.x+clip_tolerance;
  length=pcb_size.y+clip_tolerance;
  
  pcb_clip_height = pcb_height + pcb_size.z + overlap + clip_tolerance;
  down(0) color("lightblue") translate([width/2, (length - hole_distance.y)/2, pcb_height - mount_size.z])
    for (y = [-1, 1]) {
      for(x = [0, -1]) {
        translate([width * x, (hole_distance.y/2 * y) - (length - hole_distance.y)/2] ) 
          zrot(180*x) {
            cuboid([mount_size.x, mount_size.y, mount_size.z], anchor=BOTTOM+RIGHT)
              attach(TOP)
              // really convoluded logic here to get diagonal mounts
                if (!2_mount || ( y_mount && (x == -1 ) ) )
                  sphere(r=hole_diameter/2, anchor=CENTER, $fn=sphere_fn);
                translate([clip_standoff_from_edge, 0]) {
                  cuboid([clip_wall_thickness, mount_size.y, pcb_clip_height], anchor=BOTTOM);
                  up(pcb_clip_height+clip_tolerance) fwd(mount_size.y/2)
                    cylinder(h=mount_size.y, r=clip_cylinder_radius, $fn=sphere_fn, orient=BACK );
                } // translate
          } // zrot
      } // for x
    } // for y

  if(print_pcb) color("lightgreen", .5) 
    translate([0, 0, pcb_height]) cuboid(pcb_size, anchor=BOTTOM);
}

module pcb_screw_mount(name, pcb_height=7) {
  pcb_size = get_pcb_size(name);
  hole_depth = get_pcb_hole_depth(name);
  hole_distance = get_pcb_hole_distance(name);
  hole_diameter = get_pcb_hole_diameter(name);
  mount_size = get_pcb_mount_size(name);

  if(print_pcb) color("lightgreen", .2) up (wall_width + pcb_height)
    cuboid(pcb_size, anchor=BOTTOM);

  echo (wall_width,  pcb_height,  mount_size.z);
  translate([0, hole_distance.y / 2, wall_width + pcb_height - mount_size.z]) {
    //standoff_x = pcb_size.x - hole_distance.x+overlap;
    for(y = [0, -1]) {
      for(x = [1, -1]) {
        translate([(hole_distance.x / 2 )* x, hole_distance.y * y]) 
          diff("hole") 
	    cuboid(mount_size, anchor=BOTTOM)
              tag("hole") up(overlap) attach(TOP) cylinder(hole_depth,d=hole_diameter, $fn=cylinder_fn,  anchor=TOP);

      }
    }
  }
}

module ssr_mount(name) {
  pcb_size = get_pcb_size(name);
  hole_depth = get_pcb_hole_depth(name);
  hole_distance = get_pcb_hole_distance(name);
  hole_diameter = get_pcb_hole_diameter(name);
  mount_size = get_pcb_mount_size(name);

  bolt_size=[5.5, 5.5, 2.3];
  slot_size=9;
  slot_height = .5;

  for(y = [1, 0]) {
    ypos = -hole_distance.y / 2 + (hole_distance.y ) * y;
    echo(ypos);
    translate([0, ypos]) {
      diff("hole")
        zrot(180 * y) cuboid(mount_size, anchor=BOTTOM)
          tag("hole") { 
            up(overlap) attach(TOP) cylinder(hole_depth,d=hole_diameter, $fn=cylinder_fn,  anchor=TOP);
            translate([0,0,slot_height]) cuboid(bolt_size);
            translate([0,slot_size/2,slot_height]) cuboid([bolt_size.x, slot_size, bolt_size.z]);
          }
       for(x = [1, -1]) {
	 xpos = hole_distance.x / 2 * x;
	 translate([xpos, 0]) cuboid([3,10,mount_size.z], anchor=BOTTOM);
       }
    }
  }


}
