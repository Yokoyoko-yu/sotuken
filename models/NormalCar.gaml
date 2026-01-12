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
	point start_loc;
	point move_vector;
	point before_location;
  init{
    vehicle_length <- 4.5#m;
    max_speed <- 40#km/#h;
    max_acceleration <- 3.0;
    start_loc<-self.location;

  }
  
  

  reflex go when: final_target != nil {
  	self.before_location<-self.location;
    do drive;
    //1ステップ当たりに動いた距離からm/sに変換
    self.move_vector<-(self.location-self.before_location)/scale*(1/step);
  }
  
  reflex delete{
  	float judge_x;
  	float end_x<-intersection(final_target).location.x;
  	float start_x<-self.start_loc.x;
  	judge_x<-(end_x-start_x);
  	if (self.current_path=nil){
  		write("車が削除されました");
  		do die;
  		}
	if(judge_x>0){
		if(self.location distance_to {100,50}<5){
			do die;
		}
	}else{
		if(self.location distance_to {0,50}<5){
			do die;
		}
	}
  }
  
  float calc_loc{
  	float judge_x;
  	float end_x<-intersection(final_target).location.x;
  	float start_x<-self.start_loc.x;
  	judge_x<-(end_x-start_x);
  	//目的地のxが大きかったら上側
  	if(judge_x>0){
  		return (road(current_road).car_shift)*-1;
  	}else{
  		return (road(current_road).car_shift);
  	}
  }
  
  

  aspect base{
    draw circle(1.2#m) color:self.color at:self.location+{0,calc_loc()};
  }
}