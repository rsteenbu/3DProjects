// WAGO 221-412 snap mount (single) - parametric
// Dimensions sourced from WAGO datasheet (width ~13.2 mm, height ~8.6 mm, depth ~18.8 mm).
// Adjust parameters below as needed.

//////////////////////
// Parameters
//////////////////////
wago_width = 13.2;      // nominal connector width (mm)
wago_height = 8.6;      // nominal connector height (mm)
wago_depth = 18.8;      // nominal connector depth/length (mm)

clearance = 0.6;        // radial clearance for snap-fit (mm)
side_wall_thickness = 2.2; // thickness of side walls (mm)
base_thickness = 3.0;   // thickness of base plate (mm)
retention_lip = 1.6;    // front lip that prevents connector pulling forward (mm)
rear_stop = 1.5;        // rear overhang behind connector (mm)

mount_hole_d = 3.2;     // thru-hole for M3 screws (slightly larger) (mm)
countersink = true;     // countersink for flat-head M3? (simple chamfer)
cs_diam = 6.5;          // countersink diameter (mm)
cs_depth = 1.5;         // countersink depth (mm)
mount_spacing = 30;     // center-to-center spacing of the two mounting holes (mm)
mount_offset_y = 0;     // offset of mount holes in Y relative to connector center

fillet_radius = 1.2;    // optional fillet radius on corners (not a true fillet; uses minkowski)
use_minkowski = false;  // set true if you want rounded corners (may be slower)

//////////////////////
// Derived dims
//////////////////////
slot_w = wago_width + 2*clearance;
slot_h = wago_height + clearance;
slot_d = wago_depth + rear_stop + retention_lip;

total_width = slot_w + 2*side_wall_thickness;
total_depth = slot_d + 8; // extra for mount front/back clearance
total_height = base_thickness + slot_h + 2; // little extra

mount_y = mount_offset_y;
mount_x_left = -mount_spacing/2;
mount_x_right = mount_spacing/2;
mount_z = 0.1; // through holes go through base

//////////////////////
// Modules
//////////////////////
module base_plate() {
    difference() {
        translate([ -total_width/2, -total_depth/2, 0 ])
            cube([ total_width, total_depth, base_thickness ], center=false);
        // optional countersink holes
        translate([ mount_x_left, mount_y, -1 ])
            rotate([90,0,0])
                if (countersink) difference() {
                    cylinder(h = base_thickness + 2, r = cs_diam/2, $fn=64);
                    translate([0,0,-cs_depth])
                        cylinder(h = base_thickness + 4, r = mount_hole_d/2, $fn=32);
                } else translate([0,0,0]) cylinder(h=base_thickness+2, r = mount_hole_d/2, $fn=32);
        translate([ mount_x_right, mount_y, -1 ])
            rotate([90,0,0])
                if (countersink) difference() {
                    cylinder(h = base_thickness + 2, r = cs_diam/2, $fn=64);
                    translate([0,0,-cs_depth])
                        cylinder(h = base_thickness + 4, r = mount_hole_d/2, $fn=32);
                } else translate([0,0,0]) cylinder(h=base_thickness+2, r = mount_hole_d/2, $fn=32);
    }
}

module side_walls_and_slot() {
    // left wall
    translate([ -total_width/2, -slot_d/2 + 4, base_thickness ])
        cube([ side_wall_thickness, slot_d-8, slot_h+0.1 ]);
    // right wall
    translate([ total_width/2 - side_wall_thickness, -slot_d/2 + 4, base_thickness ])
        cube([ side_wall_thickness, slot_d-8, slot_h+0.1 ]);
    // back wall (rear stop)
    translate([ -total_width/2 + side_wall_thickness, slot_d/2 - rear_stop - 4, base_thickness ])
        cube([ slot_w, rear_stop + 4, slot_h + 0.1 ]);
    // retention lip at front
    translate([ -slot_w/2, -slot_d/2 + 2, base_thickness ])
        cube([ slot_w, retention_lip + 2, retention_lip ]);
}

module connector_cutout() {
    // cutout where the connector sits (centered)
    translate([ -slot_w/2, -wago_depth/2 + clearance/2, base_thickness ])
        cube([ slot_w, wago_depth + clearance, slot_h ]);
}

//////////////////////
// Assemble
//////////////////////
if (!use_minkowski) {
    // straightforward assembly
    union() {
        base_plate();
        side_walls_and_slot();
        // Subtract internal cavity for connector
        difference() {
            // no-op union to hold shapes before subtract
            translate([0,0,0]) {}
            translate([0,0,0]) 
                connector_cutout();
        }
    }
} else {
    // with rounded outer corners (minkowski)
    minkowski() {
        union() {
            base_plate();
            side_walls_and_slot();
            difference() {
                translate([0,0,0]) {}
                translate([0,0,0]) connector_cutout();
            }
        }
        sphere(r=fillet_radius, $fn=32);
    }
}

// Show optional debug dimensions (comment/uncomment to view)
// translate([0,0,base_thickness+slot_h+5]) text(str("slot_w=" + str(slot_w) + "mm"), size=3, halign="center");

