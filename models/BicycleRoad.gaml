/**
* Name: BicycleRoad
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model BicycleRoad

import "Main5.gaml"
/* Insert your model definition here */

species bicycle_road{
	float width;
	float length;
	point start_p;
	init{
		width<-width*scale;
		shape<- polygon([self.start_p,self.start_p+{self.length,0},self.start_p+{self.length,self.width},start_p+{0,width}]);
		write("bicy_rのshape:"+shape);
	}
	

	
	aspect base{
		
	}
}