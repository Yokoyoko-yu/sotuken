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

global{
	//自転車との最近接距離の平均
	float ave_p_nearest_c;
	float p_num; //自転車の母数
	float arrive_p_num;
}

species pedestrian skills:[pedestrian]{
	point d;	//目的地
	rgb color<-#purple;
	float r<-0.9;  //半径30cmとする
	list<point> start_list<-[{0,29},{300,29},{0,73},{300,73}];
	float speed;
	//一つ前の位置座表
	float p_nearest_b<-150.0;
	float sporn_time;
//	one_of(pedestrian_road).free_space
	init{
		self.sporn_time<-time;
//		write("現在地"+location);
//		 write("目的地"+d);
//		 write("avoid"+avoid_other);
//		 write("ob"+obstacle_consideration_distance);
		 //お試し
		 pedestrian_model <- "advanced";      // まずは高度版SFM
		 avoid_other <- true;                 // 他歩行者を避ける
		
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
	
	reflex delete when: time>1.0 and self.current_waypoint=nil{
//		write("歩行者を削除します");
		ave_p_nearest_c<-ave_p_nearest_c+(self.p_nearest_b)/scale;
		p_num<-p_num+1;
		arrive_p_num<-arrive_p_num+(time-self.sporn_time);
		do die;
	}
	
	reflex calc_nearest{
		list<bicycle> near_bi<-(bicycle)as list;
		loop bi over:near_bi{
			float p_d<-max(0,(bi distance_to self)-r);
			if(p_nearest_b>p_d){
				p_nearest_b<-p_d;
			}
//		write("999999999999");
//		write("自転車との距離:"+self.p_nearest_b);
//		write("999999999999");
//		write("p_num"+p_num);
		}
	}
	aspect base{
		draw circle(r) color:self.color at:self.location;
	}
}