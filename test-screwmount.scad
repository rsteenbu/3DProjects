include <BOSL2/std.scad>;

ydistribute(15) {
diff("hole")
  cuboid([4,4,7], anchor=BOTTOM)
    attach(TOP)
      tag("hole") up(.5) cylinder(r=1.00, h=6.0, $fn=45, anchor=TOP);

diff("hole")
  cuboid([4,4,7], anchor=BOTTOM)
    attach(TOP)
      tag("hole") up(.5) cylinder(r=1.10, h=6.0, $fn=45, anchor=TOP);

diff("hole")
  cuboid([4,4,7], anchor=BOTTOM)
    attach(TOP)
      tag("hole") up(.5) cylinder(r=1.20, h=6.0, $fn=45, anchor=TOP);

screw("M4", l=8+overlap, thread="coarse", tolerance="6g", anchor=BOTTOM);
fwd(x) nut("M4", "hex", "normal", 6, thread="coarse", $slop=-0.08, tolerance="6H", anchor=BOTTOM) 
}

