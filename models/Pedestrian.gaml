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
	float r<-0.9;  //半径30cmとする
	list<point> start_list<-[{0,29},{100,29},{0,73},{100,73}];
	float speed;
//	one_of(pedestrian_road).free_space
	init{
		write("現在地"+location);
		 write("目的地"+d);
		 write("avoid"+avoid_other);
		 write("ob"+obstacle_consideration_distance);
		 //お試し
		 pedestrian_model <- "advanced";      // まずは高度版SFM
		 avoid_other <- true;                 // 他歩行者を避ける
		
		 pedestrian_species <- [pedestrian];  // ★重要：誰を「歩行者」として扱うか
		 pedestrian_consideration_distance <- 5.0#m; // 検出距離（大きめに）
		 minimal_distance <- 0.8#m;           // 最小距離（好みで調整）

  // 回避の強さ（まずは大きめにして効果を見る）
		  A_pedestrians_SFM <- 6.0;
		  B_pedestrians_SFM <- 0.8#m;
		 //お試し
	}
	reflex walk when:pedestrian_network != nil{
		do compute_virtual_path pedestrian_graph: pedestrian_network target: d;
		do walk;
	}
	
	reflex delete when: time>1.0 and (self.location in start_list){
		write("歩行者を削除します");
		do die;
	}
	aspect base{
		draw circle(r) color:self.color at:self.location;
	}
}