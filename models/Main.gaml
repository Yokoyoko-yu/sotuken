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

global{
	int scale<-3;
}

experiment main type:gui{
	init{
		create road_network_make;
		
		intersection o <- one_of(intersection where (each.inter_num = 1));
    	intersection d <- one_of(intersection where (each.inter_num = 2));
    	
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
	
	
  output{
    display d type: opengl background:#cornsilk{
      species road aspect: base;
      species intersection aspect: base;
      species car aspect: base;
    }
  }
}
