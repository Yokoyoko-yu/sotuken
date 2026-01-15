/**
* Name: Main4
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Main4

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
	float bicycle_shift;
	float bi_r_length;
	intersection o;
	intersection d;
	//平均速度
	float ave_b;
	int ave_b_count; //母数のカウント用
	float ave_ped;
	int ave_ped_count;
	float step<-0.1#s;
	//最近接距離
	//自転車目線の自転車との最近接距離の平均
	float nearest_b;
	//歩行者目線の自転車との最近接距離
	float nearest_ped;
	
}

experiment main4 type:gui{
	init{
		point A<-{0,50};
		point B<-{300,50};
		create make_road with:[
					start:A,
					end:B,
					one_way:false,
					speed:60,
					p_lane:1,
					m_lane:1,
					center_line:0,
					road_width:3,
					sholder:0,
					bicycle_line:0,
					g_l:0.5,
					bicy_l:1.5,
					green_l:1,
					walk_l:2,
					walk_bi_l:0
				];	
		create intersection number:1 with:[inter_num:1] { location <- A; }
    	create intersection number:1 with:[inter_num:2] { location <- B; }
    	
    	road_network<-as_driving_graph(road,intersection);
    	
    	o <- one_of(intersection where (each.inter_num = 1));
    	d <- one_of(intersection where (each.inter_num = 2));
    	walk_shift<-one_of(pedestrian_road).walk_start_list();
    	walk_length<-one_of(pedestrian_road).walk_l;
    	//自転車用
    	bicycle_shift<-one_of(make_road).bicycle_start();
    	bi_r_length<-one_of(bicycle_road).width;
    	write("自転車のずれ"+bicycle_shift);
    	write("自転車道の横幅"+bi_r_length);
		write("road:"+road);
//    	create car number: 1 {
//	      location <- o.location;
//	      current_path <- compute_path(graph: road_network, nodes: [o,d]);
//	      color<-#blue;
//    	}
//    	
//    	create car number:1{
//    		location<-d.location;
//    		current_path<-compute_path(graph:road_network,nodes:[d,o]);
//    		color<-#green;
//    	}
    	    	
	}
	
	//車右側
	reflex  when:every(43#cycle) {
	  create car number: 1 {
	    location <- o.location;
	    current_path <- compute_path(graph: road_network, nodes: [o, d]);
	    color <- #blue;
	  }
	}
	
	//車左側
	reflex when:every(43#cycle){
		create car number:1{
    		location<-d.location;
    		current_path<-compute_path(graph:road_network,nodes:[d,o]);
    		color<-#green;
    	}
	}
	
 //歩行者
    //左上
     reflex when:every(10#cycle){
    	if(rnd(1,344)=4){
    	create pedestrian number:1{
    	speed<-0.36;
    	d<-{300,73};
    	location<-{0,50-walk_shift-rnd(0,max(walk_length-1),1)};
    	}
    	}
    	}
    //右上
    reflex when:every(10#cycle){
    	if(rnd(1,344)=4){
    		create pedestrian number:1{
	    	speed<-0.36;
	   		d<-{0,29};
	   		color<-#yellow;
	    	location<-{300,50-walk_shift-rnd(0,max(walk_length-1),1)};
    		}
    	}

    }
    //左下
    	reflex when:every(10#cycle){
    		if(rnd(1,344)=4){
    		create pedestrian number:1{
    		speed<-0.36;
    		d<-{300,73};
    		location<-{0,50+walk_shift+rnd(0,max(walk_length-1),1)};
    	}
    	}
    	}
    //右下
      reflex when:every(10#cycle){
      	if(rnd(1,344)=4){
    	create pedestrian number:1{
    	speed<-0.36;
   		d<-{0,73};
   		color<-#yellow;
    	location<-{300,50+walk_shift+rnd(0,max(walk_length-1),1)};
    	}	
    	}
	}
	
	//自転車の作成
    //左上
    reflex when:every(10#cycle){
    	if(rnd(1,172)=7){
    		create bicycle number:1{
    			float bicy_p<-50-bicycle_shift-rnd(0,bi_r_length);
    			write("bicy_p"+bicy_p);
    			location<-{0,50-(4.25*3)};
//    			location<-{0,bicy_p};
    			move_vector<-{1.16,0};
    			color<-#white;
    			target_point<-{300,50-(4.25*3)};
//    			target_point<-{100,bicy_p};
    		}	
    	}
    }


    //右下
    reflex when:every(10#cycle){
    	if(rnd(1,172)=4){
		create bicycle number:1{
    		float bicy_p<-50+bicycle_shift+rnd(0,bi_r_length);
    		write("Aaaaaaaaaaaa"+bicy_p);
//    	
    		location<-{300,50+(4.25*3)};
   			move_vector<-{-1.16,0};
    		color<-#white;
//    		target_point<-{0,bicy_p};
    		target_point<-{0,50+(4.25*3)};
   		}	
    	}
    }
    

    
	reflex when:every(1#cycle){
	    	write("time:"+time);
	    	if(!empty(bicycle)){
	    		loop b over:bicycle{
	    			float v<-norm(b.move_vector);
	    			ave_b_count<-ave_b_count+1;
	    			ave_b<-ave_b+v;
	    		}
	    	}
	    	
	    	if(ave_b_count>0){
	    		write("******自転車"+(ave_b/ave_b_count)/scale*(1/step)*3600/1000+"km/h*****");
	    	}
	    	if(!empty(pedestrian)){
	    		loop p over:pedestrian{
	    			float v<-norm(p.velocity);
	    			ave_ped<-ave_ped+v;
	    			ave_ped_count<-ave_ped_count+1;
	    		}
	    	}
	    	if(ave_ped_count>0){
	    		write("******歩行者"+(ave_ped/ave_ped_count)*scale*(1/step)+"m/s*****");
	    	}
	    	if(b_num>0){
				write("平均車間距離："+ave_b_nearest_c/b_num+"m");
				write("平均自転車距離："+ave_b_nearest_b/b_num+"m");
				write("p_num"+p_num);
				}
			if(p_num>0){
				write("自転車歩行者の平均距離："+ave_p_nearest_c/p_num+"m");
				}
				
			if(arrive_num>0){
			write("自転車の通過時間："+arrive_sum/arrive_num);
			}
	    }
	
	
	output{
    display d type: opengl background:#cornsilk{
      species road aspect: base;
      species intersection aspect: base;
      species car aspect: base;
      species pedestrian_road aspect:base;
      species pedestrian aspect:base;
      species bicycle aspect:base;
      species bicycle_road aspect:base;
     
    }
  }
}