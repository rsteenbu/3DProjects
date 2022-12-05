
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_psu = false;

wall_width = 3;
plate_size = [75, 75, 1];
tolerance = .15;
overlap = .5;

psu_size = [63.1, 51.3, 28];
screw_height = 14.9;
screw_distance = 39.66;
mount_height = 4;

cuboid(plate_size, anchor=BOTTOM);
5v_psu_mount(psu_size);


module 5v_psu_mount(psu_size) {
  diff("screwholes") up(plate_size.z - overlap) {
    right(wall_width) back(psu_size.y / 2 + wall_width / 2 + tolerance) 
      cuboid([psu_size.x + tolerance*2, wall_width, mount_height+overlap], anchor=BOTTOM);
    right(wall_width) fwd(psu_size.y / 2 + wall_width / 2 + tolerance) {
      down(tolerance) cuboid([psu_size.x + tolerance*2, wall_width, mount_height+overlap], anchor=BOTTOM);
      // screw host mount posts
      if (print_psu) color("lightgreen") left(screw_distance/2 + wall_width) fwd(4) cuboid([2, 1, screw_height], anchor=BOTTOM);
      left(screw_distance/2 + wall_width) cuboid([8, wall_width, screw_height+4], anchor=BOTTOM)
	tag("screwholes") attach([FRONT], overlap=-overlap) fwd((screw_height+4)/2 ) back(screw_height) cylinder(r=1.5+tolerance, h=wall_width+2*overlap, $fn=45, anchor=TOP);
      right(screw_distance/2 - wall_width) cuboid([8, wall_width, screw_height+4], anchor=BOTTOM)
	tag("screwholes") attach([FRONT], overlap=-overlap) fwd((screw_height+4)/2 ) back(screw_height) cylinder(r=1.5+tolerance, h=wall_width+2*overlap, $fn=45, anchor=TOP);
    }

    right(psu_size.x / 2 + wall_width / 2 + tolerance) {
      cuboid([wall_width, psu_size.y+wall_width*2+tolerance*2, mount_height+overlap], anchor=BOTTOM);
    }

    if (print_psu) {
      color("lightgreen") cuboid(psu_size, anchor=BOTTOM);
    }
  }
}


