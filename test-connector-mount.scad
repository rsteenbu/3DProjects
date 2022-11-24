include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

wall_width=2;

testPlateSize = [50,40,wall_width];

support_depth = 2;
support_height = wall_width + 3;
pos_from_edge = 3;
3_pin_connector_size = [10.0, 6.1, support_height+5];
4_pin_connector_size = [12.4, 6.2, support_height+5];

ydistribute(30) {
  diff("connector")
    cuboid(testPlateSize) { 
      //position(TOP+LEFT) right(pos_from_edge) connector(4_pin_connector_size, anchor=LEFT+BOT);
      //position(TOP+RIGHT) left(pos_from_edge) connector(3_pin_connector_size, anchor=RIGHT+BOT);
      tag("connector") attach(TOP, overlap=1) nema5_15R_female();
    }
}

module connector(connector_size, anchor) {
  // the support surrounding the connector is depth of the support * 2 to account for both parallel sides
  support_size = [connector_size.x + support_depth * 2, connector_size.y + support_depth * 2, support_height];
  //support frame
  down(1) cuboid(support_size, anchor=anchor) 
    attach([BOTTOM], overlap=1)
      tag("connector") cuboid(connector_size);
}

base_nema5_15_size=[18,16, wall_width+2];
module nema5_15R_female() {
  fwd(2) cuboid(base_nema5_15_size) {
    attach(BACK, overlap=1) cuboid([9,wall_width+2,7], anchor=BOTTOM);
    attach(LEFT, overlap=1) left(3) cuboid([10,wall_width+2,5], anchor=BOTTOM);
    attach(RIGHT, overlap=1) right(3) cuboid([10,wall_width+2,5], anchor=BOTTOM);
  }
}
