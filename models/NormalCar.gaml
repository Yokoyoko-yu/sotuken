/**
* Name: NormalCar
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model NormalCar

import "Intersection.gaml"

species car skills:[driving]{
	rgb color;
  init{
    vehicle_length <- 4.5#m;
    max_speed <- 40#km/#h;
    max_acceleration <- 3.0;
  }

  reflex go when: final_target != nil {
    do drive;
  }

  aspect base{
    draw circle(1.2#m) color:self.color;
  }
}