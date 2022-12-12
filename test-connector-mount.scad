include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_nema_plug = true;
print_connectors = false;

wall_width=2;
connector_plate_size = [60,20,wall_width];
nema_plate_size = [35,30,wall_width];

overlap=1;
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
nema_clip_width=4;  //size to edge is 4.235


/*
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
*/

module connector(connector_size, anchor) {
  // the support surrounding the connector is depth of the support * 2 to account for both parallel sides
  support_size = [connector_size.x + support_depth * 2, connector_size.y + support_depth * 2, support_height];
  //support frame
  
    up(2) cuboid(support_size, anchor=anchor) 
    attach([BOTTOM], overlap=1)
    tag("holes") cuboid(connector_size);
}

module nema5_15R_female(wall_width) {
  nema_depth = wall_width+overlap;
  base_nema5_15_size=[18.3,16, nema_depth];
  nema_clip_width=4;  //size to edge is 4.235
  //nema_clip_notch_depth = 3.2;
  nema_clip_notch_depth = 2.9;
  nema_notch_edge_distance = 1;
  clip_height=10;

  clip_notch_size=[clip_height,nema_clip_notch_depth,1.5+overlap];

  up(overlap/2) cuboid(base_nema5_15_size) {
    attach(BACK, overlap=overlap) cuboid([9,nema_depth,7], anchor=BOTTOM);
    attach(LEFT, overlap=overlap) left(3) cuboid([clip_height,nema_depth,nema_clip_width+overlap], anchor=BOTTOM)
      attach(TOP, overlap=overlap) back(nema_depth/2 - nema_clip_notch_depth/2) cuboid(clip_notch_size, anchor=BOTTOM);
    attach(RIGHT, overlap=overlap) right(3) cuboid([clip_height,nema_depth,nema_clip_width+overlap], anchor=BOTTOM)
      attach(TOP, overlap=overlap) back(nema_depth/2 - nema_clip_notch_depth/2) cuboid(clip_notch_size, anchor=BOTTOM);

  }
}
