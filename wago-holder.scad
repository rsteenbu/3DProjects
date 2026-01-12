// --- Configurable Parameters ---
//slot_configs = [ 3, 3 ];
slot_configs = [ 3 ];

// Tolerances (added to Wago dimensions to get cavity size)
slot_clearance_x = -0.2;   // Clearance for width (X-axis) of Wago nut
slot_clearance_y = -0.2;  // Clearance for depth (Y-axis) of Wago nut
slot_clearance_z = -0.1;   // Clearance for height of Wago nut

// Wall & Base Thicknesses
wall_thickness_sides_outer = 2.0;  // Thickness of the outermost side walls
wall_thickness_internal = 2.0;     // Thickness of walls between Wago nuts
back_wall_thickness = 2.0;         // Thickness of the back wall
base_thickness = 4;                // Thickness of the bottom plate

// Lip Geometry (for snap-in)
lip_overhang_top = 3.5;   // How much the top lip extends over the Wago
lip_thickness_top = 1.0;  // Thickness of the top lip
lip_overhang_front =
    1.2;  // How much the front lip extends in front of the Wago
lip_thickness_front = wall_thickness_sides_outer;  // Thickness of the front lip
// Mounting Ear Parameters (will be used later)
ear_thickness = 0;          // Thickness of the ear (Z-axis)
screw_hole_diameter = 4.8;  // For #8 screw
ear_hole_offset_from_edge =
    7;  // Distance from ear's attachment face to center of screw hole
screw_hole_chamfer_depth =
    0.4;  // Depth of the 45-degree chamfer for the screw hole top
ear_min_wall_around_hole =
    2.5;  // Minimum wall thickness around the screw hole (excluding chamfer)
          // (e.g., 0.8mm depth gives 1.6mm added diameter at surface)

// Fillet Parameters
fillet_radius = 0.5;    // [mm] Radius for all fillets
corner_fillet_fn = 50;  // Slices for fillet curves for smoother fillets
ear_fillet_fn = 200;
front_top_chamfer_size =
    4.0;  // [mm] Size of the 45-degree chamfer on the front top edge of walls
back_top_chamfer_size =
    4.0;  // [mm] Size of the 45-degree chamfer on the back top edge of walls

// Pry Cutout Parameters (for screwdriver access under Wagos)
pry_cutout_enable = true;  // Enable/disable pry cutouts
pry_cutout_width = 5.0;    // [mm] Width of the cutout slot
pry_cutout_height = 1.0;   // [mm] Desired height of the cutout opening (will be
                           // capped by lip_thickness_front)
pry_cutout_depth_under_wago =
    5.0;  // [mm] How far it extends under Wago (beyond the front lip)
pry_cutout_chamfer_size =
    0.8;  // [mm] Chamfer size for the bottom opening of the cutout

// --- Helper Constants ---
epsilon = 0.01;  // A small value for ensuring clean boolean operations

// --- Wago 221 Series Dimensions ---
// Function to get Wago dimensions [width, depth, height]
// Note: Wago dimensions are typically given as H x W x D or similar.
// For consistency in OpenSCAD (X, Y, Z), we'll use:
// X: Width (varies by position count)
// Y: Depth (constant for 221 series)
// Z: Height (constant for 221 series)
function get_wago_dimensions(positions) =
    positions == 2 ? [ 13.2, 18.6, 8.4 ] :  // 2-position Wago 221-412
        positions == 3 ? [ 18.8, 18.6, 8.4 ]
                       :  // 3-position Wago 221-413
        positions == 5 ? [ 30.0, 18.6, 8.4 ]
                       :  // 5-position Wago 221-415
        undef  // Semicolon removed: 'undef' is now the expression for
               // the ternary's else branch.
    ;  // This (optional) semicolon now correctly terminates the function
       // definition.

// Helper function to sum elements of an array
function sum_array(vec, index = 0, sum = 0) = index >= len(vec)
                                                  ? sum
                                                  : sum_array(vec, index + 1,
                                                              sum + vec[index]);

// Helper function to calculate cavity dimensions for a single Wago type
function calculate_single_slot_cavity_dims(p_count) = [
  get_wago_dimensions(p_count)[0] + slot_clearance_x,
  get_wago_dimensions(p_count)[1] + slot_clearance_y,
  get_wago_dimensions(p_count)[2] +
  slot_clearance_z
];

// Phase 1, Step 2: Calculate Overall Holder Dimensions

// If the original slot_configs order [A, B, C] was appearing right-to-left (C,
// B, A visually from left-to-right), processing a reversed list will make it
// appear left-to-right (A, B, C visually from left-to-right). Conversely, if it
// was already A,B,C (L-R), this change will make it C,B,A (L-R).
_slot_configs_for_layout =
    [for (i = len(slot_configs) - 1; i >= 0; i = i - 1) slot_configs[i]];
slot_cavity_dims = [for (p_count = _slot_configs_for_layout)
        calculate_single_slot_cavity_dims(p_count)];

// Max Wago dimensions (with clearance) needed for overall holder size
max_wago_cavity_depth = max([for (dim = slot_cavity_dims) dim[1]]);
max_wago_cavity_height = max([for (dim = slot_cavity_dims) dim[2]]);

// Calculate total width occupied by Wago cavities
total_wago_cavity_widths = sum_array([for (dim = slot_cavity_dims) dim[0]]);

// Calculate total width of internal walls
num_slots = len(slot_configs);
total_internal_wall_width = num_slots > 1
                                ? (num_slots - 1) * wall_thickness_internal
                                : 0;

// Calculate internal width of the holder (cavities + internal walls)
holder_internal_width = total_wago_cavity_widths + total_internal_wall_width;

// --- Overall Holder Block Dimensions ---
holder_block_width = holder_internal_width + 2 * wall_thickness_sides_outer;
holder_block_depth =
    back_wall_thickness + max_wago_cavity_depth + lip_overhang_front;
holder_block_height =
    base_thickness + max_wago_cavity_height + lip_thickness_top;

// --- Calculate X-offsets for each slot cavity ---
// Each offset is to the start (min X) of the cavity, inside the holder block
slot_start_x_offsets =
    [for (i = [0:num_slots - 1]) let(
         previous_cavity_widths = sum_array(
             i == 0 ? [] : [for (j = [0:i - 1]) slot_cavity_dims[j][0]]),
         previous_internal_walls_width = i > 0 ? i * wall_thickness_internal
                                               : 0) wall_thickness_sides_outer +
        previous_cavity_widths +
        previous_internal_walls_width];

// --- Helper Module for Rounded Cubes ---
module rounded_cube(size, radius, fn = 0) {
  _fn = fn > 0 ? fn : (radius > 0 ? corner_fillet_fn : $fn);
  translate([ radius, radius, radius ]) {
    minkowski() {
      cube([ size[0] - 2 * radius, size[1] - 2 * radius, size[2] - 2 * radius ],
           center = false);  // This cube's corner is at [0,0,0]
      sphere(r = radius,
             $fn = _fn);  // Sphere for minkowski is centered at [0,0,0]
    }
  }
}
// Alternative chamfering method using a rotated cube
module rotated_cube_cutter_for_back_top_chamfer(target_width, target_height,
                                                chamfer_size) {
  s = chamfer_size;
  len = target_width + 2 * epsilon;  // Ensure full span plus overlap

  // The target edge for the chamfer is at Y=0, Z=target_height, extending along
  // X. We want to cut 's' into the +Y direction (from Y=0 to Y=s on the top
  // face) and 's' into the -Z direction (from Z=target_height to
  // Z=target_height-s on the back face).

  // To achieve this with a cube rotated -45 degrees around the X-axis:
  // 1. Position a cube relative to the rotation axis.
  // 2. Rotate.
  // 3. Translate the whole rotated assembly to the final position.

  // The rotation axis will be: (any_X, Y=0, Z=target_height)
  // We translate the setup so this axis is effectively the world X-axis, then
  // rotate, then translate to final X-start, Y, Z position.

  translate([
    -epsilon, 0,
    target_height
  ]) {  // Step 3: Position the rotation axis origin
    rotate(a = -45, v = [ 1, 0, 0 ]) {  // Step 2: Rotate around current X-axis
      // Step 1: Position the cube relative to the (now local) X-axis.
      // A cube of [len, s, s] placed with its corner at [0,0,-s]
      // relative to the rotation axis will, after -45deg rotation,
      // cut the desired chamfer.
      // Cube corners before rotation: [0,0,-s] and [len,s,0]
      translate([ 0, 0, -s ]) { cube([ len, s, s ]); }
    }
  }
}

// --- Helper module for 2D ear profile with filleted outer corners ---
// Creates a 2D shape for the ear, to be extruded.
// 'length' is along X (protrusion), 'width' is along Y.
// Fillets are applied to the two corners at X = length.
module ear_2d_profile_filleted(length, width, radius, fn = 0) {
  _fn = fn > 0 ? fn : (radius > 0 ? ear_fillet_fn : $fn);
  hull() {
    // Main rectangle part, stopping short of where fillets begin on the length
    square([ length - radius, width ]);
    // Vertical strip along the filleted edge, between the start of the two
    // fillets
    translate([ length - radius, radius, 0 ])
        square([ radius, width - 2 * radius ]);
    // Fillet circle 1 (min Y side, at max X)
    translate([ length - radius, radius, 0 ]) circle(r = radius, $fn = _fn);
    // Fillet circle 2 (max Y side, at max X)
    translate([ length - radius, width - radius, 0 ])
        circle(r = radius, $fn = _fn);
  }
}

// --- Main Holder Block Definition ---
// Module to create the main rectangular body of the holder.
module main_holder_block_geometry() {
  difference() {
    // Main block with rounded vertical edges
    // This block spans from [0,0,0] to [holder_block_width, holder_block_depth,
    // holder_block_height] with vertical edges filleted inwards by
    // fillet_radius.
    translate([ fillet_radius, fillet_radius, 0 ]) {
      linear_extrude(height = holder_block_height) {
        minkowski() {
          square(
              [
                holder_block_width - 2 * fillet_radius, holder_block_depth - 2 *
                fillet_radius
              ],
              center = false);
          circle(r = fillet_radius, $fn = corner_fillet_fn);
        }
      }
    }

    // Subtract front-top chamfer if size is positive
    if (front_top_chamfer_size > 0) {
      chamfer_x_start = 0 - epsilon;
      chamfer_x_end = holder_block_width + epsilon;
      y_block_edge = holder_block_depth;
      z_block_edge = holder_block_height;
      cs = front_top_chamfer_size;

      polyhedron(
          points =
              [
                // Start face points (at chamfer_x_start)
                [
                  chamfer_x_start, y_block_edge - cs, z_block_edge + epsilon
                ],  // 0: Point on top face (extended by epsilon in +Z), set
                    // back along Y
                [
                  chamfer_x_start, y_block_edge + epsilon, z_block_edge - cs
                ],  // 1: Point on front face (extended by epsilon in +Y), set
                    // down along Z
                [
                  chamfer_x_start, y_block_edge + epsilon, z_block_edge +
                  epsilon
                ],  // 2: Outer corner point (extended by epsilon in +Y and +Z)
                // End face points (at chamfer_x_end)
                [
                  chamfer_x_end, y_block_edge - cs, z_block_edge + epsilon
                ],  // 3
                [
                  chamfer_x_end, y_block_edge + epsilon, z_block_edge - cs
                ],  // 4
                [
                  chamfer_x_end, y_block_edge + epsilon, z_block_edge + epsilon
                ]  // 5
              ],
          faces = [
            [ 0, 1, 2 ],  // Front triangle of the chamfering prism
            [ 5, 4, 3 ],  // Back triangle (reversed winding for outward normal)
            [ 0, 3, 4, 1 ],  // Chamfer surface itself
            [ 1, 4, 5, 2 ],  // Surface along the original block's front face
            [ 2, 5, 3, 0 ]   // Surface along the original block's top face
          ]);
    }

    // Subtract back-top chamfer if size is positive
    if (back_top_chamfer_size > 0) {
      chamfer_x_start = 0 - epsilon;
      chamfer_x_end = holder_block_width + epsilon;
      y_back_edge = -epsilon;  // Back edge of the block is at Y=0
      z_block_edge = holder_block_height;
      bcs = back_top_chamfer_size;

      translate([ 0, 0, bcs ]) {
        rotated_cube_cutter_for_back_top_chamfer(holder_block_width,
                                                 holder_block_height, bcs);
      }
    }
  }
}

// --- Mounting Ear Module Definition ---
// Creates one mounting ear.
// Assumes its attachment face is at its local X=0 and it protrudes in its local
// +X direction. Its local origin [0,0,0] is at the corner of this attachment
// face (min_x, min_y, min_z). Dimensions of the ear: [ear_length_protrusion
// (local X), ear_width (local Y), ear_thickness (local Z)]
module mounting_ear_geometry() {
  // Calculate ear dimensions based on hole and minimum wall thickness
  current_ear_width = screw_hole_diameter + 2 * ear_min_wall_around_hole;
  current_ear_length_protrusion = ear_hole_offset_from_edge +
                                  (screw_hole_diameter / 2) +
                                  ear_min_wall_around_hole;

  // ear_hole_offset_from_edge is the distance from the ear's attachment face
  // (local X=0) into the protrusion along its local X-axis.
  hole_center_x = ear_hole_offset_from_edge;
  hole_center_y = current_ear_width /
                  2;  // Centered along the ear's calculated local Y dimension
  chamfer_top_diameter = screw_hole_diameter + 2 * screw_hole_chamfer_depth;

  // echo(str("Calculated Ear Width: ", current_ear_width, ", Calculated Ear
  // Length Protrusion: ", current_ear_length_protrusion));

  difference() {
    // Ear body - extruded 2D profile with specific outer vertical fillets
    // Horizontal edges will be sharp.
    linear_extrude(height = ear_thickness) {
      ear_2d_profile_filleted(current_ear_length_protrusion, current_ear_width,
                              screw_hole_diameter);
    }

    // Screw hole (through hole)
    // Centered in ear's X, offset in ear's Y, passes through ear's Z.
    translate([ hole_center_x, hole_center_y, -epsilon ]) {
      cylinder(d = screw_hole_diameter, h = ear_thickness + 2 * epsilon,
               $fn = 32);
    }

    // Chamfer for screw hole (from top surface)
    if (screw_hole_chamfer_depth > 0) {
      translate([
        hole_center_x, hole_center_y, ear_thickness - screw_hole_chamfer_depth
      ]) {
        cylinder(d1 = screw_hole_diameter, d2 = chamfer_top_diameter,
                 h = screw_hole_chamfer_depth + epsilon, $fn = 32);
      }
    }
  }
}

// Creates a square fillet in the first quadrant (X>=0, Y>=0), extruded along Z.
module square_fillet(radius, height) {
  linear_extrude(height = height) {
    difference() {  // Creates a square with a concave quarter-circle removed
                    // from one corner
      square([ radius, radius ]);
      translate([
        radius, radius
      ]) {  // Move the circle's center to the [radius, radius] corner
        circle(r = radius, $fn = ear_fillet_fn);
      }
    }
  }
}

// Phase 2, Step 4: Slot Cavity Subtraction

// Module to generate the union of all slot cavities to be subtracted.
// These cavities represent the space where the Wago connectors (plus clearance)
// will sit. The lips are formed by the material of the main_holder_block that
// is *not* removed by these cavities, thanks to holder_block_depth/height
// including lip_thickness_front/top.
module all_slot_cavities_geometry() {
  union() {
    for (i = [0:num_slots - 1]) {
      wago_actual_width = slot_cavity_dims[i][0];
      wago_actual_depth = slot_cavity_dims[i][1];   // Includes clearance_y
      wago_actual_height = slot_cavity_dims[i][2];  // Includes clearance_z

      cavity_x_pos = slot_start_x_offsets[i];
      cavity_base_y = back_wall_thickness;
      cavity_base_z = base_thickness;

      // --- Subtraction 1: Main Wago Pocket ---
      // This is the space the Wago connector itself (plus clearance) occupies.
      union() {  // This union is for all subtractions for a single slot
        translate([ cavity_x_pos, cavity_base_y, cavity_base_z ]) {
          rounded_cube(
              [ wago_actual_width, wago_actual_depth, wago_actual_height ],
              fillet_radius);
        }
      }

      // Subtraction 2: channels. This cuts "out" from the main wago pocket,
      // leaving the front and top lips.
      translate([
        cavity_x_pos, wall_thickness_sides_outer + lip_overhang_top,
        base_thickness +
        lip_thickness_front
      ]) {
        rounded_cube(
            [ wago_actual_width, holder_block_depth, holder_block_height ],
            fillet_radius);
      }
    }
  }
}

// --- Pry Cutout Geometry ---

// Module to generate a single chamfered pry cutout shape.
// Profile is in local YZ plane. Y extends from 0 (front) to -pc_total_depth
// (back). Z extends from 0 (bottom) to pc_h (top). Chamfer is on the
// bottom-front edge.
module single_pry_cutout_shape(pc_w, pc_h, pc_total_depth, pc_cs) {
  // pc_h: total height of the cutout.
  // pc_cs: chamfer size (applies to Z height from bottom and Y depth from
  // front). actual_cs: effective chamfer size, cannot exceed pc_h or
  // pc_total_depth.
  actual_cs =
      pc_cs > 0 ? min(pc_cs, pc_h - epsilon, pc_total_depth - epsilon) : 0;

  profile_points = actual_cs > 0 ? [
    [-pc_total_depth, 0],           // Back-bottom (Y=-pc_total_depth, Z=0)
    [-pc_total_depth, pc_h],        // Back-top (Y=-pc_total_depth, Z=pc_h)
    [0, pc_h],                      // Front-top (Y=0, Z=pc_h)
    [0, -actual_cs]                  // Front-bottom chamfer outer point (Y=0, Z=actual_cs)
  ] : [ // Rectangular profile if no chamfer
    [0, 0],                         // Front-bottom
    [-pc_total_depth, 0],           // Back-bottom
    [-pc_total_depth, pc_h],        // Back-top
    [0, pc_h]                       // Front-top
  ];

  // Raw shape: Extruded along its Z-axis (which becomes world X after
  // multmatrix) Profile X-axis is local Y (depth), Profile Y-axis is local Z
  // (height)
  linear_extrude(height = pc_w) polygon(profile_points);
}

// Module to generate the union of all pry cutouts.
module all_pry_cutouts_geometry() {
  if (pry_cutout_enable && pry_cutout_width > 0 && pry_cutout_height > 0) {
    // Effective height of the cutout, capped by the front lip's Z-thickness.
    // lip_thickness_front is the Z-dimension of the front lip.
    effective_pc_h =
        max(epsilon, pry_cutout_height + lip_thickness_front + epsilon * 2);

    pry_total_depth = lip_overhang_front + pry_cutout_depth_under_wago;
    union() {
      for (i = [0:num_slots - 1]) {
        slot_x_center = slot_start_x_offsets[i] + slot_cavity_dims[i][0] / 2;
        // Reorient and position the cutout:
        // Raw shape from single_pry_cutout_shape:
        // - Extrusion length (pc_w) is along its Z axis.
        // - Profile's X-axis (local Y, -pc_total_depth to 0) is depth.
        // - Profile's Y-axis (local Z, 0 to pc_h) is height.
        // multmatrix maps: Raw Z -> World X, Raw X -> World Y, Raw Y -> World Z
        translate([
          slot_x_center -
              pry_cutout_width / 2,  // Center World X (cutout width)
          holder_block_depth,  // Position front face of cutout (World Y=0 of
                               // cutout) at holder's front face
          base_thickness - pry_cutout_height -
              epsilon  // Position bottom of cutout (World Z=0 of cutout) at
                       // holder's base
        ])
            multmatrix([
              [ 0, 0, 1, 0 ], [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 0, 1 ]
            ])  // Z_raw->X, X_raw->Y, Y_raw->Z
            single_pry_cutout_shape(pry_cutout_width, effective_pc_h,
                                    pry_total_depth, pry_cutout_chamfer_size);
      }
    }
  }
}
// --- Assemble the Holder Base (Main Block + Ears) ---
// This module combines the main block and the mounting ears.
// The main block is placed with its min_x, min_y, min_z corner at [0,0,0].
module wago_holder_with_ears() {
  difference() {  // Changed from union to difference to subtract cavities
    union() {     // Explicitly union the main block and ears first
      // Instantiate the main holder block
      main_holder_block_geometry();  // Restore main block

      // Calculate ear width for centering offset
      actual_ear_width = screw_hole_diameter + 2 * ear_min_wall_around_hole;
      ear_attachment_y_offset = (holder_block_depth - actual_ear_width) / 2;

      // Left Ear:
      // Attaches to the left face of the main block (X = 0).
      // Protrudes in the -X direction.
      // Achieved by mirroring the standard ear (which protrudes in +X) across
      // the YZ plane.
      translate([ 0, ear_attachment_y_offset, 0 ]) {
        mirror([ 1, 0, 0 ]) { mounting_ear_geometry(); }
      }

      // Right Ear:
      // Attaches to the right face of the main block (X = holder_block_width).
      // Protrudes in the +X direction.
      translate([ holder_block_width, ear_attachment_y_offset, 0 ]) {
        mounting_ear_geometry();
      }

      inner_fillet_radius =
          (holder_block_depth -
           (ear_min_wall_around_hole * 2 + screw_hole_diameter)) /
          2;
      // Additive fillets at ear/body junctions for strength
      // Radius is ear_min_wall_around_hole
      // Left Ear Junction Fillets
      // TL: Fillet extends in +X (main body) and +Y (ear top)
      translate([ 0, ear_attachment_y_offset, 0 ]) scale([ -1, -1, 1 ])
          square_fillet(inner_fillet_radius, ear_thickness);

      // BL: Fillet extends in +X (main body) and -Y (ear bottom)
      translate([ 0, ear_attachment_y_offset + actual_ear_width, 0 ])
          scale([ -1, 1, 1 ]) square_fillet(inner_fillet_radius, ear_thickness);

      // Right Ear Junction Fillets
      // TR: Fillet extends in -X (main body) and +Y (ear top)
      translate([ holder_block_width, ear_attachment_y_offset, 0 ])
          scale([ 1, -1, 1 ]) square_fillet(inner_fillet_radius, ear_thickness);

      // BR: Fillet extends in -X (main body) and -Y (ear bottom)
      translate(
          [ holder_block_width, ear_attachment_y_offset + actual_ear_width, 0 ])
          scale([ 1, 1, 1 ]) square_fillet(inner_fillet_radius, ear_thickness);
    }

    // Subtract all slot cavities
    all_slot_cavities_geometry();

    // Subtract pry cutouts
    all_pry_cutouts_geometry();
  }
}

