/**
 *  ModelN2
 *  Author: odg
 *  Description: 
 */

model ModelN2

/* Insert your model definition here */
global {
	//Recuperation des différentes shapefiles
	file get_route <- file("../includes/route.shp");
	file get_habitation <- file("../includes/polygons.shp");
	file get_departVoiture <- file("../includes/departVoiture.shp");
	file get_destinationVoiture <- file("../includes/destinationVoiture.shp");
	file get_departBus <- file("../includes/departBus.shp");
	file get_destinationBus <- file("../includes/destinationBus.shp");
	//Ajout du shapefile pour l'arret de bus
	file get_arret <-file("../includes/arretBus.shp");

  	geometry shape <- envelope(get_route);
	graph graphe;
	float speedV <- 8.0 #km / #h;
	float speedB<- 5.0 #km / #h;
	float speedmax <- 10.0 #km / #h;
	int intensite <-100;
	
	init{
		create route from: get_route with:[nbLanes::int(read("lanes"))] {}
		create habitation from:get_habitation;
		create departV from:get_departVoiture;
		create destinationV from:get_destinationVoiture;
		create departBus from: get_departBus;
		create destinationBus from: get_destinationBus;
		create arret from:get_arret;
		set graphe <- (as_edge_graph(route));
		
		//Ajout d'un agent humain	
		create humain number:10{
			location<-any_location_in(one_of(arret));
			target <-one_of(arret);
			
		}
	
   }
//Genearation continuelle des voiture en fonction de l'intensité   
reflex creer_voiture when:every (intensite){
   create Voiture number:5{
			speed <- speedV;
			location <- any_location_in(one_of(departV));
			target <- any_location_in(one_of(destinationV));
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self)];
		
		}
  } 
   
//Generation continuelle des bus en fonction de l'intensité
reflex creer_Bus when:every (intensite){
		create Bus number: 5 {
			speed <- speedB;
			location <- any_location_in(one_of(departBus));
			target <- (one_of(destinationBus));
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self)];
			
		}
	
}


}

	entities{
		//entité route
		species route {
		int nbLanes;
		aspect base {
			draw shape color: rgb("black");
		}

	}
	
		//entité habitation
	species habitation {
		float height <- 15#m + rnd(15) #m;
		aspect geom {
			draw shape color: rgb("black") depth: height;
		}
	}

	////entité depart voiture
	species departV{
		aspect base{
			draw square(30) color: rgb("yellow");
		}
	}
	
	//entité destination voiture
	species destinationV{
		aspect base{
			draw square(40) color: rgb("red");
		}
	}
	
	//entité depart de bus
	species departBus{
		aspect base{
			draw circle(30) color: rgb("green");
		}
	}
	
	//entité destination de bus
	species destinationBus{
		aspect base{
			draw circle(40) color: rgb("red");
		}
	}
	
	//entité arret
	species arret {
		aspect base {
			draw circle(20) color: rgb("red");
		}

	}

	//entité agent voiture
	species Voiture skills:[driving]{
		float speed;
		point target <- nil;
		point location <- nil;
		  reflex deplacer when: target != nil {
		  	do goto target:target on:graphe;
		  		
		       
		}
		aspect base{
			draw circle(20)  color: rgb("blue");
		}
	}

//entité agent bus
	species Bus skills:[driving]{
		float speed;
		point target<-nil;
		point location <- nil;
		reflex deplacer when: target != nil {
		  	do goto target:target on:graphe;
		  		
		}
		reflex arret_bus{  
			ask arret{ 
			int tps_arret<-5;
			int counter<-0;
			float distance_to_stop<-myself distance_to self;
			if(location=arret){myself.speed<-0;}
			}
		}
		
		aspect base{
			draw square(40)  color: rgb("green");
		}
		
	}
	
	//entité humain
	species humain skills:[moving]{
		float speed;
		point target<-nil;
		point location<-nil;
		reflex aller when:target!=nil{
			do goto target:target on:graphe;
		}
		aspect base{
			draw circle(10) color:rgb("yellow");
		}
	}


}


experiment my_experiment type: gui {
	output{
		
		display my_display{
			
			species route aspect: base;
			species habitation aspect: geom;
			species departV aspect: base;
			species destinationV aspect: base;
			species departBus aspect: base;
			species destinationBus aspect: base;
			species Voiture aspect: base;
			species Bus aspect: base;
			species arret aspect:base;
			species humain aspect:base;
			
		}
	}
}
