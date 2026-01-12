/**
* Name: Main3
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Main3

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
}

experiment main3 type:gui{
	init{
		point A<-{0,50};
		point B<-{100,50};
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
					bicycle_line:1.5,
					g_l:0,
					bicy_l:0,
					green_l:1.5,
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
    	
//    	create bicycle number:1{
//    		float bicy_p<-50+bicycle_shift+rnd(0,bi_r_length);
//    		location<-{0,bicy_p};
//    		move_vector<-{2,0};
//    		color<-#black;
//    		target_point<-{100,bicy_p};
//   		}	
    	    	
	}
	
	//車右側
	reflex  when:every(432#cycle) {
	  create car number: 1 {
	    location <- o.location;
	    current_path <- compute_path(graph: road_network, nodes: [o, d]);
	    color <- #blue;
	  }
	}
	
	//車左側
	reflex when:every(432#cycle){
		create car number:1{
    		location<-d.location;
    		current_path<-compute_path(graph:road_network,nodes:[d,o]);
    		color<-#green;
    	}
	}
	
	//左上
	reflex when:every(40#cycle){
    		if(rnd(1,50)=4){
				create pedestrian number:1{
	    		speed<-0.7;
	    		d<-{100,29};
	    		location<-{0,50-walk_shift-rnd(0,max(walk_length-1),1)};
	    		
	    		}
			}
    	}
    //右上
	reflex when:every(100#cycle){
    	if(rnd(1,50)=1){
    	create pedestrian number:1{
    	speed<-0.7;
   		d<-{0,29};
   		color<-#yellow;
    	location<-{100,50-walk_shift-rnd(0,max(walk_length-1),1)};
    	}
    	}
    }

    //左下
    	reflex when:every(40#cycle){
    		if(rnd(1,50)=1){
	    		create pedestrian number:1{
	    		speed<-0.7;
	    		d<-{100,73};
	    		location<-{0,50+walk_shift+rnd(0,max(walk_length-1),1)};
	    		write("生成された高さ:"+50+walk_shift+rnd(0,max(walk_length-1),1));
    		}
    	}
    	}
    //右下
      reflex when:every(400#cycle){
    	create pedestrian number:1{
    	speed<-0.7;
   		d<-{0,73};
   		color<-#yellow;
    	location<-{100,50+walk_shift+rnd(0,max(walk_length-1),1)};
    	}
	}
	
	//自転車
	//左上
	reflex when:every(100#cycle){
    	if(rnd(1,5)=4){
    		create bicycle number:1{
    			avoid_list<-["car"];
    			float bicy_p<-50-bicycle_shift-rnd(0,bi_r_length);
    			location<-{0,bicy_p};
    			move_vector<-{2,0};
    			color<-#white;
    			target_point<-{100,bicy_p};
    		}	
		}	
    }
	


	//右下
	   reflex when:every(100#cycle){
    	if(rnd(1,5)=4){
		create bicycle number:1{
			avoid_list<-["car"];
    		float bicy_p<-50+bicycle_shift+rnd(0,bi_r_length);
    		write("Aaaaaaaaaaaa"+bicy_p);
    		location<-{100,bicy_p};
   			move_vector<-{-2,0};
    		color<-#white;
    		target_point<-{0,bicy_p};
   		}	
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