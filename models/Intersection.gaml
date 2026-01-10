/**
* Name: Intersection
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Intersection

import "MakeRoad.gaml"
/* Insert your model definition here */

global{
	graph road_network;
//	graph pedestrian_network;
}

species intersection skills:[intersection_skill] {
  int inter_num;

  aspect base {
    draw circle(0.2) color:#orange;
  }
}

species road_network_make{
	
	init{
//		create road_make;
		point A<-{0,50};
		point B<-{100,50};
		create make_road with:[
					start:A,
					end:B,
					one_way:false,
					speed:60,
					p_lane:1,
					m_lane:1,
					center_line:2,
					road_width:3,
					sholder:0.5,
					bicycle_line:0,
					g_l:0,
					bicy_l:0,
					green_l:1.5,
					walk_l:2,
					walk_bi_l:0
				];

		
		create intersection number:1 with:[inter_num:1] { location <- A; }
    	create intersection number:1 with:[inter_num:2] { location <- B; }
    	
    	road_network<-as_driving_graph(road,intersection);
//    	pedestrian_network<-as_edge_graph(yoad);
//    	pedestrian_network<-as_edge_graph([{0,50},{100,50}]);
    	do die;
	}
}
