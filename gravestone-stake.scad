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
//               but it is a tall tower on a thin U of bed contact.
//   "none"    - as used, for looking at it.
//
// Set show_stake = false to print the C-channel on its own as a fit test.

// Units: millimetres throughout.

$fa = 2;
$fs = 0.25;

/* ---------- parameters ---------- */

total_h       = 130;  // (mm) DR-1 overall height
channel_h     = 30;   // (mm) DR-3 C-channel section (floor + walls)
foam_t        = 20;   // (mm) DR-2 foam gravestone thickness
foam_gap      = 1;    // (mm) FR-3 slip fit on the foam
channel_depth = 35;   // (mm) how far the gravestone sits into the channel (X)
wall_t        = 3;    // (mm) back / left / right wall thickness
floor_t       = 4;    // (mm) channel floor - the stake stops here (AR-3)
lead_in       = 1.0;  // (mm) chamfer at the mouth to guide the foam in (also
                      // thins the wall at the bed, so keep it under wall_t)

ridge_p       = 2.5;  // (mm) FR-2 bite of the vertical ridges, on the side walls
ridge_p_h     = 1.5;  // (mm) FR-2 bite of the horizontal ridges, on the back wall
ridge_pitch   = 6;    // (mm) spacing, both sets
ridge_inset   = 3;    // (mm) gap before the first ridge on each wall

stake_tip     = 0.03; // fraction of the base left at the tip
stake_overlap = 1;    // (mm) AR-4 how far the stake buries into the floor

show_stake    = true;    // false = C-channel only, for a quick fit-test print
print_mode    = "flat";  // "flat" | "upright" | "none" - see the header
show_gravestone = false;  // AR-3/DR-2 check: translucent 200 x 400 x 20 reference panel

/* ---------- derived ---------- */

slot     = foam_t + foam_gap;        // cavity between the side walls
outer_x  = channel_depth + wall_t;   // back wall + cavity, front is open
outer_y  = slot + 2 * wall_t;
stake_h  = total_h - channel_h;      // the stake is the rest of the height
cav_x0   = -outer_x / 2 + wall_t;    // inner face of the back wall
cav_len  = channel_depth + 1;        // cavity cut, runs out through the open front
ridge_len = channel_h - floor_t - lead_in;  // side ridges run the cavity height

// Where the vertical ridges sit across the channel depth: starting a pitch in
// from the back wall, since the back wall's own horizontal ridges grip that
// end, then one more hard against the open front, where the gravestone has
// least to hold it.
ridge_x = concat([for (x = [cav_x0 + ridge_inset + ridge_pitch : ridge_pitch : outer_x / 2 - ridge_p]) x],
                 [outer_x / 2 - ridge_p]);

// FR-4 stake cross section: an isoceles triangle sitting inside the channel
// footprint, its base edge in the plane of the back wall's outer face.
stake_base_w = outer_y - 4;           // base edge, across the channel (Y)
stake_base_d = stake_base_w * 0.85;   // out towards the apex (X), near equilateral

/* ---------- parts ---------- */

// One vertical grip ridge, running the height of the cavity. The gravestone
// slides straight down past these rather than over them. Profile: 45 deg face
// towards the back wall, flat face towards the open front, so the foam catches
// on them if it works its way forwards - and in the "flat" print orientation
// that slope is the underside, so it self-supports.
module grip_ridge(len, p)
{
	linear_extrude(height = len)
		polygon([[0, p], [p, p], [p, 0]]);
}

// One horizontal grip ridge, running across the back wall. Flat underside so
// the gravestone catches on it if it lifts, 45 deg top face so it slides down
// past them on the way in. This wall is flat on the bed in the "flat" print
// orientation, so these just point straight up out of it.
module grip_ridge_h(len, p)
{
	rotate([90, 0, 0])
		linear_extrude(height = len)
			polygon([[0, 0], [p, 0], [0, p]]);
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

	// FR-2: vertical ridges on the two walls that grip the faces of the gravestone
	for (x = ridge_x)
	{
		for (side = [1, -1])
		{
			scale([1, side, 1])
				translate([x, slot / 2 - ridge_p, floor_t])
					grip_ridge(ridge_len, ridge_p);
		}
	}

	// FR-2: horizontal ridges on the back wall, which the edge of the
	// gravestone butts up against
	// (they simply merge into the first vertical ridge if ridge_p_h > ridge_inset)
	for (z = [floor_t + ridge_inset : ridge_pitch : channel_h - ridge_p_h])
	{
		translate([cav_x0, slot / 2, z])
			grip_ridge_h(slot, ridge_p_h);
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
