include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

wall_width=2;

testPlateSize = [40,20,wall_width];

support_depth = 2;
support_height = wall_width + 3;
pos_from_edge = 3;
3_pin_connector_size = [10.0, 6.1, support_height+5];
4_pin_connector_size = [12.4, 6.2, support_height+5];

diff("connector")
  cuboid(testPlateSize) { 
    position(TOP+LEFT) right(pos_from_edge) connector(4_pin_connector_size, anchor=LEFT+BOT);
    position(TOP+RIGHT) left(pos_from_edge) connector(3_pin_connector_size, anchor=RIGHT+BOT);
  }

module connector(connector_size, anchor) {
  // the support surrounding the connector is depth of the support * 2 to account for both parallel sides
  support_size = [connector_size.x + support_depth * 2, connector_size.y + support_depth * 2, support_height];
  //support frame
  down(1) cuboid(support_size, anchor=anchor) 
    attach([BOTTOM], overlap=1)
      tag("connector") cuboid(connector_size);
}
