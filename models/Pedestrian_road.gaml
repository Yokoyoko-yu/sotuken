/**
* Name: Pedestrianroad
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Pedestrianroad

/* Insert your model definition here */

import "Main.gaml"
import "road_ori.gaml"

global{
	graph pedestrian_network;
}

species pedestrian_road skills:[pedestrian_road]{
	point start; //道路の始点 roadと同じ点
	point end; //道路の終点	roadと同じ点
	float g_l;//ガードレール
	float bicy_l;//自転車専用道
	float green_l;//植樹帯
	float walk_l;//歩行者道
	float walk_bi_l;//自転車歩行者道
	float shift; //車道の横幅
	bool one_way;
	geometry free_space;
	
	init{
		if(one_way=false){
			create pedestrian_road with:[
				start:self.start,
				end:self.end,
				g_l:self.g_l,
				bicy_l:self.bicy_l,
				green_l:self.green_l,
				walk_l:self.walk_l,
				walk_bi_l:self.walk_bi_l,
				shift:self.shift,
				one_way:true
			];
		}
		g_l<-g_l*scale;
		bicy_l<-bicy_l*scale;
		green_l<-green_l*scale;
		walk_l<-walk_l*scale;
		walk_bi_l<-walk_bi_l*scale;
		//shapeの記述
		float walk_s; //中心から歩道のセンターラインまでの距離
		walk_s<-self.shift+g_l+bicy_l+green_l+(walk_l/2);
		write("walk_s"+walk_s);
		if(one_way=false){
			shape<-polyline([self.start-{0,walk_s},self.end-{0,walk_s}]);
			
		}
		else{
			shape<-polyline([self.start+{0,walk_s},self.end+{0,walk_s}]);
		}
		pedestrian_network <- as_edge_graph(pedestrian_road);
		write("created pedestrian_network: nodes=" + length(pedestrian_network.vertices) + " edges=" + length(pedestrian_network.edges));
		
	}
	
	//中心点から歩道のスタートまでの絶対値
	float walk_start_list{
		return (shift+self.g_l+bicy_l+green_l);
	}
	
	
	
	aspect base{
		shift<-self.shift;
		float s<-self.shift;
		write("最初のshift"+shift);
		//ガードレール
		if(g_l>0){
			draw polygon([start-{0,s+g_l},start-{0,s},end-{0,s},end-{0,s+g_l}]) color:#white;
			
			draw polygon([start+{0,s},start+{0,s+g_l},end+{0,s+g_l},end+{0,s}]) color:#white;
		}
		s<-s+(g_l);
		//自転車専用道
		if(bicy_l>0){
			draw polygon([start-{0,s+bicy_l},start-{0,s},end-{0,s},end-{0,s+bicy_l}]) color:#blue;
			
			draw polygon([start+{0,s},start+{0,s+bicy_l},end+{0,s+bicy_l},end+{0,s}]) color:#blue;
		}
		s<-s+(bicy_l);
		write("ここのshi"+shift);
		write("ここのs"+s);
		write("start"+start);
		//植樹帯
		if(green_l>0){
			draw polygon([start-{0,s+green_l},start-{0,s},end-{0,s},end-{0,s+green_l}]) color:#green;
//			write("スタート位置"+polygon([start-{0,shift+green_l},start-{0,shift},end-{0,shift},end-{0,shift+green_l}]));
			draw polygon([start+{0,s},start+{0,s+green_l},end+{0,s+green_l},end+{0,s}]) color:#green;
		}
		s<-s+green_l;
		//歩道
		if(walk_l>0){
			draw polygon([start-{0,s+walk_l},start-{0,s},end-{0,s},end-{0,s+walk_l}]) color:#orange;
			draw polygon([start+{0,s},start+{0,s+walk_l},end+{0,s+walk_l},end+{0,s}]) color:#orange;
			
			write("---------");
			write(polygon([start-{0,shift+walk_l},start-{0,shift},end-{0,shift},end-{0,shift+walk_l}]));
			write(polygon([start+{0,shift},start+{0,shift+walk_l},end+{0,shift+walk_l},end+{0,shift}]));
			write("---------");
			free_space<-free_space+polygon([start-{0,s+walk_l},start-{0,s},end-{0,s},end-{0,s+walk_l}])+polygon([start+{0,s},start+{0,s+walk_l},end+{0,s+walk_l},end+{0,s}]);
			write("fs"+free_space);
		}
		//歩行者自転車道
		if(walk_bi_l>0){
			draw polygon([start-{0,s+walk_bi_l},start-{0,s},end-{0,s},end-{0,s+walk_bi_l}]) color:#orange;
			
			draw polygon([start+{0,s},start+{0,s+walk_bi_l},end+{0,s+walk_bi_l},end+{0,s}]) color:#orange;

		}
	}
	
}