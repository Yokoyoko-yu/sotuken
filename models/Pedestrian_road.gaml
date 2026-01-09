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
	point start; //道路の始点
	point end; //道路の終点
	float g_l;//ガードレール
	float bicy_l;//自転車専用道
	float green_l;//植樹帯
	float walk_l;//歩行者道
	float walk_bi_l;//自転車歩行者道
	float shift;
	int width<-30;
	
	init{
		
		shift<-one_of(road).all_length*scale; //車道の中心から端までの距離
		start<-one_of(road).start;
		end<-one_of(road).end;
		g_l<-g_l*scale;
		bicy_l<-bicy_l*scale;
		green_l<-green_l*scale;
		walk_l<-walk_l*scale;
		walk_bi_l<-walk_bi_l*scale;
		
	}
	
	aspect base{
		shift<-one_of(road).all_length*scale;
		//ガードレール
		if(g_l>0){
			draw polygon([start-{0,shift+g_l},start-{0,shift},end-{0,shift},end-{0,shift+g_l}]) color:#white;
			
			draw polygon([start+{0,shift},start+{0,shift+g_l},end+{0,shift+g_l},end+{0,shift}]) color:#white;
		}
		shift<-shift+(g_l);
		//自転車専用道
		if(bicy_l>0){
			draw polygon([start-{0,shift+bicy_l},start-{0,shift},end-{0,shift},end-{0,shift+bicy_l}]) color:#blue;
			
			draw polygon([start+{0,shift},start+{0,shift+bicy_l},end+{0,shift+bicy_l},end+{0,shift}]) color:#blue;
		}
		shift<-shift+(bicy_l);
		//植樹帯
		if(green_l>0){
			draw polygon([start-{0,shift+green_l},start-{0,shift},end-{0,shift},end-{0,shift+green_l}]) color:#green;
			
			draw polygon([start+{0,shift},start+{0,shift+green_l},end+{0,shift+green_l},end+{0,shift}]) color:#green;
		}
		shift<-shift+green_l;
		//歩道
		if(walk_l>0){
			draw polygon([start-{0,shift+walk_l},start-{0,shift},end-{0,shift},end-{0,shift+walk_l}]) color:#orange;
			draw polygon([start+{0,shift},start+{0,shift+walk_l},end+{0,shift+walk_l},end+{0,shift}]) color:#orange;
			
			write("---------");
			write(polygon([start-{0,shift+walk_l},start-{0,shift},end-{0,shift},end-{0,shift+walk_l}]));
			write(polygon([start+{0,shift},start+{0,shift+walk_l},end+{0,shift+walk_l},end+{0,shift}]));
			write("---------");
			free_space<-free_space+polygon([start-{0,shift+walk_l},start-{0,shift},end-{0,shift},end-{0,shift+walk_l}])+polygon([start+{0,shift},start+{0,shift+walk_l},end+{0,shift+walk_l},end+{0,shift}]);
		}
		//歩行者自転車道
		if(walk_bi_l>0){
			draw polygon([start-{0,shift+walk_bi_l},start-{0,shift},end-{0,shift},end-{0,shift+walk_bi_l}]) color:#orange;
			
			draw polygon([start+{0,shift},start+{0,shift+walk_bi_l},end+{0,shift+walk_bi_l},end+{0,shift}]) color:#orange;
//			write("----ここから");
//			write(polygon([start-{0,shift+walk_bi_l},start-{0,shift},end-{0,shift},end-{0,shift+walk_bi_l}]));
//			write(polygon([start+{0,shift},start+{0,shift+walk_bi_l},end+{0,shift+walk_bi_l},end+{0,shift}]));
//			write("-------");
		}
	}
	
}

species pedestrian_road_make{
	init{
		create pedestrian_road with:[
			g_l:0,
			bicy_l:0,
			green_l:1.5,
			walk_l:2,
			walk_bi_l:0,
			shape:polyline({0,50},{100,50})
		]{
			write("fs"+free_space);
			pedestrian_network<-as_edge_graph(pedestrian_road);
			
		}
		
		do die;
	}
	
	


}