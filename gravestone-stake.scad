// Gravestone stake - ground stake with a C-channel that grips a 20mm foam gravestone.
//
// Use orientation: tip at z=0, C-channel mouth open at z=total_h facing UP,
// gravestone slides down into the channel from the top.
//
// Printing (FR-5), set with print_mode:
//   "flat"    - lies on the flat face of the triangular stake, which is the same
//               plane as the outside of the channel's back wall (FR-4). That
//               wall then lies flat on the bed and the cavity opens straight
//               up: the side walls stand up off it, the grip ridges run up them
//               as vertical ribs, and nothing bridges or overhangs at all.
//   "upright" - channel mouth on the bed, stake pointing up. Also support-free,
//               but it is a 130mm tower on a thin U of bed contact.
//   "none"    - as used, for looking at it.
//
// Set show_stake = false to print the C-channel on its own as a fit test.

$fa = 2;
$fs = 0.25;

/* ---------- parameters ---------- */

total_h       = 130;  // DR-1 overall height
channel_h     = 30;   // DR-3 C-channel section (floor + walls)
foam_t        = 20;   // DR-2 foam gravestone thickness
foam_gap      = 1;    // FR-3 slip fit on the foam
channel_depth = 35;   // how far the gravestone sits into the channel (X)
wall_t        = 3;    // back / left / right wall thickness
floor_t       = 4;    // channel floor - the stake stops here (AR-3)
lead_in       = 1.0;  // chamfer at the mouth to guide the foam in (also thins
                      // the wall at the bed, so keep it well under wall_t)

ridge_p       = 1;    // FR-2 how far the grip ridges bite into the foam
ridge_pitch   = 6;    // vertical spacing of the ridges
ridge_inset   = 3;    // first ridge above the channel floor

stake_tip     = 0.03; // taper left at the tip, as a fraction of the base
stake_overlap = 1;    // AR-4 how far the stake buries into the floor

show_stake    = true;    // false = C-channel only, for a quick fit-test print
print_mode    = "flat";  // "flat" | "upright" | "none" - see the header
show_gravestone = true;  // AR-3/DR-2 check: translucent 200 x 400 x 20 reference panel

/* ---------- derived ---------- */

slot     = foam_t + foam_gap;        // 21mm cavity between the side walls
outer_x  = channel_depth + wall_t;   // back wall + cavity, front is open
outer_y  = slot + 2 * wall_t;
stake_h  = total_h - channel_h;      // 90mm below the channel
cav_x0   = -outer_x / 2 + wall_t;    // inner face of the back wall
cav_len  = channel_depth + 1;        // cavity cut, runs out through the open front
ridge_len = channel_depth + 0.01;    // ridges stop flush with the open front

// FR-4 stake cross section: an isoceles triangle sitting inside the channel
// footprint, its base edge in the plane of the back wall's outer face.
stake_base_w = outer_y - 4;           // base edge, across the channel (Y)
stake_base_d = stake_base_w * 0.85;   // out towards the apex (X), near equilateral

/* ---------- parts ---------- */

// One horizontal grip ridge running along X (the depth of the channel).
// Profile: flat underside so the foam catches on pull-out, 45 deg top face so
// it slides down in easily - and so the face prints without support once the
// model is flipped.
module grip_ridge(len, p)
{
	rotate([90, 0, 90])
		linear_extrude(height = len)
			polygon([[0, 0], [p, 0], [p, p]]);
}

// FR-1 / OR-1 / OR-2: back + left + right walls, open at the front and at the top.
module channel()
{
	difference()
	{
		union()
		{
			translate([-outer_x / 2, -outer_y / 2, 0])
				cube([outer_x, outer_y, channel_h]);
		}

		// cavity - open through the front face and out the top
		translate([cav_x0, -slot / 2, floor_t])
			cube([cav_len, slot, channel_h - floor_t + 1]);

		// flared lead-in at the mouth
		translate([0, 0, channel_h - lead_in])
			linear_extrude(height = lead_in + 0.01, scale = [1, (slot + 2 * lead_in) / slot])
				translate([cav_x0 + cav_len / 2, 0])
					square([cav_len, slot], center = true);
	}

	// FR-2: ridges on both inner side walls
	for (z = [floor_t + ridge_inset : ridge_pitch : channel_h - lead_in - ridge_p - 0.5])
	{
		for (side = [1, -1])
		{
			scale([1, side, 1])
				translate([cav_x0 - 0.01, slot / 2 - ridge_p, z])
					grip_ridge(ridge_len, ridge_p);
		}
	}
}

// FR-4: triangular stake, tapered the whole way and pointed at the bottom.
// The extrusion scales towards the midpoint of the base edge, so that whole
// face stays in the plane x = -outer_x/2 - the back of the channel, the closed
// side - and the two make one flat surface to print on. Printed on that face
// no outside wall of the channel ends up overhanging.
//
// AR-2 / AR-4: the top of the taper sits stake_overlap deep in the channel
// floor, so the solids intersect instead of just touching. floor_t is thicker
// than stake_overlap, so nothing reaches the cavity (AR-3).
module stake()
{
	translate([-outer_x / 2, 0, stake_h + stake_overlap])
		mirror([0, 0, 1])
			linear_extrude(height = stake_h + stake_overlap, scale = stake_tip)
				polygon([[0, -stake_base_w / 2],
				         [0,  stake_base_w / 2],
				         [stake_base_d, 0]]);
}

// AR-1: channel centered on the stake axis. AR-3: the stake stops at the
// channel floor, so the cavity above it is empty.
module gravestone_stake()
{
	if (show_stake)
		stake();

	translate([0, 0, stake_h])
		channel();
}

// Reference only: a 200 x 400 x 20 foam gravestone seated on the channel floor.
// Its thickness sits in the slot, its width runs out through the open front.
module gravestone_ref()
{
	translate([cav_x0, -foam_t / 2, stake_h + floor_t])
		cube([200, foam_t, 400]);
}

// show_gravestone is a visual check, so it always uses the as-used orientation.
if (show_gravestone)
{
	gravestone_stake();
	%gravestone_ref();
}
else if (print_mode == "flat")
{
	// roll the FR-4 flat face down onto the bed
	translate([0, 0, outer_x / 2])
		rotate([0, -90, 0])
			gravestone_stake();
}
else if (print_mode == "upright")
{
	translate([0, 0, total_h])
		rotate([180, 0, 0])
			gravestone_stake();
}
else
{
	gravestone_stake();
}
