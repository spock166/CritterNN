

class Critter {
  PVector position;
  float theta, maxrotate, velocity, sightRange, eatRange, max_velocity, hunger;
  int health, hungerTick, healthTick, curHungerTick, curHealthTick, seesFood,generation, base_color;
  boolean isDead;
  public static final int num_hidden = 7;
  
  //Neural Network Stufff
  float[] input_to_hidden_weights;
  float[] hidden_to_output_weights;
  float[] input_layer, hidden_layer, output_layer;
  int time_alive,time_since_sexy,time_since_nom;
  float mutationRate;
  color colour;
  
  public Critter(float x, float y,float orientation, float velocity, float[] input_weights, float[] output_weights, int gen) {
    position = new PVector(x, y);
    input_to_hidden_weights = input_weights.clone();
    hidden_to_output_weights = output_weights.clone();
    max_velocity = 3;
    this.velocity = velocity;
    theta = orientation; //Start going east
    maxrotate = PI/2;
    sightRange = 75;
    eatRange = 20;
    health = 100;
    hunger = 0;
    hungerTick = 20;
    healthTick = 10;
    curHungerTick = 0;
    curHealthTick = 0;
    isDead = false;
    mutationRate = 0.01;
    seesFood = 0;
    time_since_sexy = 0;
    time_since_nom = 0;
    generation = gen;
    base_color = (int)random(255);
    
    //Neural Network Stuff
    //Take position x/y, hunger, and health as inputs (add in seeing food and reproduction also).
    //Output theta
    //Should add a bias node.
    setupSigmoid();
  }

  void update() {
    if(isDead){
      return;
    }

    updateStats();
    move();
    
    fill(50,0,0,50);
    circle(position.x,position.y, sightRange);
    fill(0,50,50,100);
    circle(position.x,position.y, eatRange);
    fill(255,0,0,255);
    text(generation + "\n" + hunger + "\n" + health,position.x,position.y);
    fill(hunger/100*255,float(health)/100*2,base_color);
    triangle(position.x, position.y,position.x - 4, position.y+10,position.x +4, position.y +10);   
  }
  
  void updateStats(){
    time_alive++;
    time_since_sexy++;
    time_since_nom++;
    curHungerTick++;
    curHealthTick++;
    
    if(curHungerTick > hungerTick){
      curHungerTick = 0;
      hunger += velocity+1.0;
      hunger = min(hunger,100);
    }
    
    if(curHealthTick > healthTick){
      curHealthTick = 0;
      if(hunger == 100){
        health--;
      }
      
      health = max(health,0);
      if(health == 0){
        isDead = true;
      }
    }
  }
  
  void move(){
    
    input_layer = new float[] {theta/TWO_PI,abs(velocity/max_velocity),hunger/100,float(health)/100,seesFood,time_since_sexy/1000, time_since_nom/3000, 1}; //position.x/width,position.y/height
    hidden_layer = new float[num_hidden];
    output_layer = new float[2];
    
    for(int i = 0; i < hidden_layer.length; i++){
      hidden_layer[i] = 0;
      for(int j = 0; j < input_layer.length; j++){
        hidden_layer[i] += input_layer[j] * input_to_hidden_weights[j*hidden_layer.length + i];
      }
      hidden_layer[i] = lookupSigmoid(hidden_layer[i]);
      //System.out.println(hidden_layer[i]);
    }
    
    for(int i = 0; i < output_layer.length; i++){
      output_layer[i] = 0;
      for(int j = 0; j < hidden_layer.length; j++){
        output_layer[i] += hidden_layer[j] * hidden_to_output_weights[j*output_layer.length + i];
      }
      
      output_layer[i] = lookupSigmoid(output_layer[i]);
      //System.out.println(output_layer[0]);
    }
    
    
    
    
    theta += output_layer[0]*maxrotate;
    velocity = abs(output_layer[1] * max_velocity);
    
    
    
    //Chance this with neural net
    //theta += random(-maxrotate,maxrotate);
    PVector temp = new PVector(velocity*cos(theta), velocity*sin(theta)); 
    position.add(temp);
    
    if (position.y < 0) {
      position.y = height;
    }

    if (position.y > height) {
      position.y = 0;
    }

    if (position.x < 0) {
      position.x = width;
    }

    if (position.x > width) {
      position.x = 0;
    }
  }
  
  PVector getPos(){
    return position;
  }
  
  boolean getDead(){
    return isDead;
  }
  
  void feed(){
    time_since_nom = 0;
    
    hunger -= 20;
    hunger = max(0,hunger);
    
    health += 10;
    health = min(100,health);
  }
  
  boolean SexyTime(){
    if(time_since_sexy > 1000 + random(-50,50) && hunger < 70){
      time_since_sexy = 0;
      hunger += 20;
      generation++;
      for(int i = 0; i < input_to_hidden_weights.length; i++){
        float prob = random(1.0);
        if(prob < mutationRate){
          colour = color(random(255), random(255), random(255));
          input_to_hidden_weights[i] = random(-1.0,1.0);
        }
      }
      
      for(int i = 0; i < hidden_to_output_weights.length; i++){
        float prob = random(1.0);
        if(prob < mutationRate){
          colour = color(random(255), random(255), random(255));
          hidden_to_output_weights[i] = random(-1.0,1.0);
        }
      }
      
      return true;
    }
    
    return false;
  }
}
