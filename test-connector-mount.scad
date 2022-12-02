include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_nema_plug = true;
print_connectors = true;

wall_width=2;
connector_plate_size = [60,20,wall_width];
nema_plate_size = [35,30,wall_width];

support_depth = 2;
support_height = wall_width + 3;
pos_from_edge = 3;
//2_pin_connector_size = [7.45, 6.0, support_height+5];
//3_pin_connector_size = [9.95, 6.0, support_height+5];
//4_pin_connector_size = [12.35, 6.0, support_height+5];
2_pin_connector_size = [7.45, 5.95, support_height+5];
3_pin_connector_size = [9.95, 5.95, support_height+5];
4_pin_connector_size = [12.45, 5.95, support_height+5];

base_nema5_15_size=[18.3,16, wall_width+2];
nema_clip_width=4.7;


ydistribute(35) {
    if (print_connectors) {
      diff("connector") 
	cuboid(connector_plate_size) { 
	  position(TOP+LEFT)  right(pos_from_edge) connector(2_pin_connector_size, anchor=LEFT+BOT);
	  position(TOP+CENTER)   connector(4_pin_connector_size, anchor=BOT);
	  //position(TORIGHT   left(pos_from_edge) connector(2_pin_connector_size, anchor=RIGHT+BOT);
	  position(TOP+RIGHT)  left(pos_from_edge) connector(3_pin_connector_size, anchor=RIGHT+BOT);
	}
    }
    if (print_nema_plug) {
      diff("plug") 
      cuboid(nema_plate_size) { 
	tag("plug") attach(TOP, overlap=1) nema5_15R_female();
      }
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

module nema5_15R_female() {
  fwd(2) cuboid(base_nema5_15_size) {
    attach(BACK, overlap=1) cuboid([9,wall_width+2,7], anchor=BOTTOM);
    attach(LEFT, overlap=1) left(3) cuboid([10,wall_width+2,nema_clip_width], anchor=BOTTOM);
    attach(RIGHT, overlap=1) right(3) cuboid([10,wall_width+2,nema_clip_width], anchor=BOTTOM);
  }
}
