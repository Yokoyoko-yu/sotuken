/**
* Name: Pedestrian
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Pedestrian

/* Insert your model definition here */

import "Intersection.gaml"
import "Pedestrian_road.gaml"



species pedestrian skills:[pedestrian]{
	point d;	//目的地
	rgb color<-#purple;
	float r<-0.8;
	list<point> start_list<-[{0,40},{100,50}];
	float speed;
	init{
		location<-one_of(start_list);
		 d <- one_of(start_list where (each != location));
		 
		 
//		 do compute_virtual_path pedestrian_graph: pedestrian_network target: d;
	}
	reflex walk when:pedestrian_network != nil{
		do compute_virtual_path pedestrian_graph: pedestrian_network target: d;
		do walk;
		
	}
	aspect base{
		draw circle(r) color:self.color at:self.location;
	}
}