include <BOSL2/std.scad>;

ydistribute(15) {
diff("hole")
  cuboid([4,4,7], anchor=BOTTOM)
    attach(TOP)
      tag("hole") up(.5) cylinder(r=1.00, l=6.0, $fn=45, anchor=TOP);

diff("hole")
  cuboid([4,4,7], anchor=BOTTOM)
    attach(TOP)
      tag("hole") up(.5) cylinder(r=1.10, l=6.0, $fn=45, anchor=TOP);

diff("hole")
  cuboid([4,4,7], anchor=BOTTOM)
    attach(TOP)
      tag("hole") up(.5) cylinder(r=1.20, l=6.0, $fn=45, anchor=TOP);
}

