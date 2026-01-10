/**
* Name: Main
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Main

/* Insert your model definition here */


import "road_ori.gaml"
import "Intersection.gaml"
import "NormalCar.gaml"
import "Pedestrian_road.gaml"
import "Pedestrian.gaml"

global{
	int scale<-3;
	float walk_shift;
	float walk_length;
	intersection o;
	intersection d;
}

experiment main type:gui{
	init{
		
		create road_network_make;
		o <- one_of(intersection where (each.inter_num = 1));
    	d <- one_of(intersection where (each.inter_num = 2));
    	walk_shift<-one_of(pedestrian_road).walk_start_list();
    	walk_length<-one_of(pedestrian_road).walk_l;
		write("road:"+road);
    	create car number: 1 {
	      location <- o.location;
	      current_path <- compute_path(graph: road_network, nodes: [o,d]);
	      color<-#blue;
    	}
    	
    	create car number:1{
    		location<-d.location;
    		current_path<-compute_path(graph:road_network,nodes:[d,o]);
    		color<-#green;
    	}
    	    	
	}
	
	//車右側
	reflex  when:every(40#cycle) {
	  create car number: 1 {
	    location <- o.location;
	    current_path <- compute_path(graph: road_network, nodes: [o, d]);
	    color <- #blue;
	  }
	}
	
	//車左側
	reflex when:every(40#cycle){
		create car number:1{
    		location<-d.location;
    		current_path<-compute_path(graph:road_network,nodes:[d,o]);
    		color<-#green;
    	}
	}
	
	//左上
	reflex when:every(40#cycle){
    		create pedestrian number:1{
    		speed<-0.7;
    		d<-{100,29};
    		location<-{0,50-walk_shift-rnd(0,max(walk_length-1),1)};
    	}
    	}
    //右上
    reflex when:every(40#cycle){
    	create pedestrian number:1{
    	speed<-0.7;
   		d<-{0,29};
   		color<-#yellow;
    	location<-{100,50-walk_shift-rnd(0,max(walk_length-1),1)};
    	}
    }
    //左下
    	reflex when:every(40#cycle){
    		create pedestrian number:1{
    		speed<-0.7;
    		d<-{100,73};
    		location<-{0,50+walk_shift+rnd(0,max(walk_length-1),1)};
    	}
    	}
    //右下
      reflex when:every(40#cycle){
    	create pedestrian number:1{
    	speed<-0.7;
   		d<-{0,73};
   		color<-#yellow;
    	location<-{100,50+walk_shift+rnd(0,max(walk_length-1),1)};
    	}
    }
    
	
  output{
    display d type: opengl background:#cornsilk{
      species road aspect: base;
      species intersection aspect: base;
      species car aspect: base;
      species pedestrian_road aspect:base;
      species pedestrian aspect:base;
    }
  }
}
