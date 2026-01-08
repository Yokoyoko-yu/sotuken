/**
* Name: Intersection
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Intersection

import "road_ori.gaml"
/* Insert your model definition here */

global{
	graph road_network;
}

species intersection skills:[intersection_skill] {
  int inter_num;

  aspect base {
    draw circle(0.2) color:#orange;
  }
}

species road_network_make{
	init{
		create road_make;
		point A<-{0,50};
		point B<-{100,50};
		
		create intersection number:1 with:[inter_num:1] { location <- A; }
    	create intersection number:1 with:[inter_num:2] { location <- B; }
    
    	road_network<-as_driving_graph(road,intersection);
    	do die;
	}
}