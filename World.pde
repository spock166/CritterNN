import java.util.*;
//Critter c = new Critter(width/2, height/2);

ArrayList<Critter> critters;
ArrayList<Food> foods;
float foodTick, curFoodTick;
int eldestAge, time;
Critter eldest;


void initializePop(Critter baseCritter, int numCritters){
  if(baseCritter == null){
    critters = new ArrayList<Critter>();
    for (int j = 0; j < numCritters; j++) {
      
      float[] input_to_hidden_weights = new float[8*Critter.num_hidden];
      float[] hidden_to_output_weights = new float[Critter.num_hidden*2];
    
      //For now do random weights.  In future use reproduction.
      for(int i = 0; i < input_to_hidden_weights.length; i++){
        input_to_hidden_weights[i] = random(-1.0,1.0);
      }
    
      for(int i = 0; i < hidden_to_output_weights.length; i++){
        hidden_to_output_weights[i] = random(-1.0,1.0);
      }
      color c = color(random(255), random(255), random(255));
      Critter temp = new Critter(random(width), random(height), random(TWO_PI), random(1.0),input_to_hidden_weights,hidden_to_output_weights,1);
      critters.add(temp);
    }
  }else{
    
  }
}

void setup() {
  frameRate(30);
  
  initializePop(null,20);

  foods = new ArrayList<Food>();
  for (int i = 0; i < 25; i++) {
    Food food = new Food(random(width), random(height));
    foods.add(food);
  }

  foodTick = 15;
  curFoodTick = 0;

  size(1024, 768);
  stroke(155);
  time = 0;
}

void draw() {
  background(51);
  time++;
  if(critters.size() == 0){
    fill(255);
    text("They're dead Jim.", width/2, height/2);  
  }
  
  for (Food f : foods) {
    f.update();
  }

  Iterator it = critters.iterator();
  while (it.hasNext()) {
    Critter c = (Critter)it.next();
    if (c.getDead()) {
      //System.out.println("Critter has passed away");
      it.remove();
    } else {
      c.update();
    }
  }
  
  int maxAge = 0;
  ArrayList<Integer> crittersToProcreate = new ArrayList<Integer>();
  for(Critter c : critters){
    if(c.time_alive > maxAge){
      maxAge = c.time_alive;
    }
    
    if(c.time_alive > eldestAge){
      eldestAge = c.time_alive;
      //eldest = clone of the eldest 
    }
    
    if(c.SexyTime()){
        crittersToProcreate.add(critters.indexOf(c));
    }
  }
  
  for(int i : crittersToProcreate){
    Critter baby = new Critter(critters.get(i).position.x,critters.get(i).position.y,random(TWO_PI),random(1.0), critters.get(i).input_to_hidden_weights, critters.get(i).hidden_to_output_weights, critters.get(i).generation-1);  //Should make this part of SexyTime()
    baby.hunger += 20;
    critters.add(baby);
  }

  checkMunchies();
  
  if(tickFood()){
    Food food = new Food(random(width),random(height));
    foods.add(food);
  }
  
  fill(255);
  text("Current Population: " + critters.size() + "\nOldest age: " +maxAge, width/2, 20);
  
  if(time%5000 == 0){
    System.out.println("Population at tick " + time + " is " + critters.size()); 
  }
}

void checkMunchies() {
  Iterator fit = foods.iterator();
  
  for(Critter c : critters){
    c.seesFood = 0;
    for(Food f : foods) {
      if (PVector.dist(c.getPos(), f.getPos()) < c.eatRange && f.isNomed == false) {
        f.hasBeenNomed();
        c.feed();
        //System.out.println("Nom nom nom");
      }
      
      if (PVector.dist(c.getPos(), f.getPos()) < c.sightRange && f.isNomed == false) {
        c.seesFood = 1;   
      }
    }
  }
  
  while(fit.hasNext()){
    Food f = (Food)fit.next();
    if(f.isNomed){
      fit.remove();
    }
  }
}

boolean tickFood(){
  foodTick = 50;//foods.size();
  curFoodTick++;
  if(curFoodTick > foodTick){
    curFoodTick = 0;
    return true;
  }else{
    return false;
  }
}
