include <BOSL2/std.scad>;
include <BOSL2/screws.scad>;

// ========================================
// Global Configuration Parameters
// ========================================

// Clip mount configuration
tolerance = 0.1;       // Clearance for PCB in clip mounts (mm)

// Rendering quality
sphere_fn = 45;             // $fn value for spheres
cylinder_fn = 20;           // $fn value for cylinders (lower quality)

// PCB Configuration Data Structure
// Each PCB config is a vector: pcb_size, [hole_distance_x, hole_distance_y], mount_size, hole_diameter, hole_depth]
// use_2_mount: optional boolean, defaults to false if not specified
PCB_CONFIGS = [
//                       pcb_size          [hole_distance] mount_type, hole_diameter, hole_depth, print_pcb]
  ["70x50",              [[50, 70, 1.6],   [46,66],        "screw",    1.94,          5,          false]],
  ["relay",              [[25.5, 51],      [20,45.26],     "screw",    2,             5,          false]],
  ["beefcake_relay",     [[30.5, 62.3],    [25.50, 50.76], "screw",    3.25,          5,          false]],
  ["hiletgo_30A_relay",  [[40, 72, 1.6],   [34, 66.6],     "screw",    3.25,          5,          false]],
  ["wasatch8",           [[100, 100, 1.6], [93, 93],       "screw",    3.5,           5,          false]],
  ["EARU-ssr",           [[45, 60],        [45, 49],       "screw",    3.3,           7.5,        false]],
  ["lm2596",             [[20.8, 43.7],    [15.28, 30.16], "screw", ,  3.25,          5,          false]] // DC-DC Converter LM2596
];

mounts = [
  ["screw",     [6.9,6.5,6.5] ],
  ["clip",      [8,8,4]     ],
  ["ssr_relay", [10,10,8]   ]
];


// Helper functions to extract PCB configuration values
function pcb_config(pcb_name) =
  let(pcb_config = search([pcb_name], PCB_CONFIGS)[0])
  pcb_config != [] ? PCB_CONFIGS[pcb_config][1] : undef;

function get_pcb_size(pcb_name)          = pcb_config(pcb_name)[0];
function get_pcb_hole_distance(pcb_name) = pcb_config(pcb_name)[1];
function get_mount_type(pcb_name)        = pcb_config(pcb_name)[2];
function get_pcb_hole_diameter(pcb_name) = pcb_config(pcb_name)[3];
function get_pcb_hole_depth(pcb_name)    = pcb_config(pcb_name)[4];
function get_print_pcb(pcb_name)         = pcb_config(pcb_name)[5];

// get mount size for general mounts
function get_mount_size(name) =
  let(type_index = search([name], mounts)[0])
    mounts[type_index][1];
// get the mount size for the type specefied PCB_CONFIGS
function get_pcb_mount_size(pcb_name)    = 
  get_mount_size(get_mount_type(pcb_name));

module pcb_mount(name, pcb_height=7) {
  pcb_mount_type = get_mount_type(name);
  pcb_size = get_pcb_size(name);
  hole_depth = get_pcb_hole_depth(name);
  hole_distance = get_pcb_hole_distance(name);
  hole_diameter = get_pcb_hole_diameter(name);
  mount_size = get_pcb_mount_size(name);
  print_pcb = get_print_pcb(name);

  if(print_pcb) color("lightgreen", .2) up (wall_width + pcb_height)
    cuboid(pcb_size, anchor=BOTTOM);

  color("lightblue") translate([0, hole_distance.y / 2, wall_width + pcb_height - mount_size.z]) {
    for(y = [0, -1]) {
      for(x = [1, -1]) {
        translate([(hole_distance.x / 2 )* x, hole_distance.y * y]) {
	    diff("hole") cuboid(mount_size, anchor=BOTTOM) 
              if (pcb_mount_type == "screw") {
	        screw_mount_feature(hole_depth, hole_diameter);
	      }
              if (pcb_mount_type == "clip") {
	        clip_mount_feature(mount_size, pcb_size, hole_distance, hole_diameter, x);
	      } // if (pcb_mount_type == "clip")
	} // mount translate
      } // for x
    } // for y
  }
}

module screw_mount_feature(hole_depth, hole_diameter) {
  attach(TOP) tag("hole") up(overlap) cylinder(hole_depth,d=hole_diameter, $fn=cylinder_fn,  anchor=TOP);
}

module clip_mount_feature(mount_size, pcb_size, hole_distance, hole_diameter, x) {
  clip_cylinder_radius = 1.25; // Radius of clip retaining cylinder (mm)
  clip_wall_thickness = 2;    // Thickness of clip walls (mm)
  clip_standoff_from_edge = 1; // Distance from clip edge to PCB (mm)

  pcb_clip_height = mount_size.z + pcb_size.z + tolerance;
  up(mount_size.z-tolerance) sphere(r=hole_diameter/2, anchor=CENTER, $fn=sphere_fn);
  translate([(clip_wall_thickness/2 + (pcb_size.y - hole_distance.y)/2 + tolerance) * x, 0]) {
    cuboid([clip_wall_thickness, mount_size.y, pcb_clip_height], anchor=BOTTOM);
    up(pcb_clip_height+tolerance) fwd(mount_size.y/2)
      cylinder(h=mount_size.y, r=clip_cylinder_radius, $fn=sphere_fn, orient=BACK );
  }
}

module ssr_mount(name) {
  hole_depth = get_pcb_hole_depth(name);
  hole_distance = get_pcb_hole_distance(name);
  hole_diameter = get_pcb_hole_diameter(name);
  mount_size = get_mount_size("ssr_relay");

  bolt_size=[5.5, 5.5, 2.3];
  slot_size=9;
  slot_height = .5;

  for(y = [1, 0]) {
    ypos = -hole_distance.y / 2 + (hole_distance.y ) * y;
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
