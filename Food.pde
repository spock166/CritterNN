class Food{
  PVector position;
  boolean isNomed;
  
  public Food(float x,float y){
    position = new PVector(x, y);
    isNomed = false;
  }
  
  


  void update() {
    fill(255);
    rect(position.x-5,position.y-5,10,10); 
  }
  
  PVector getPos(){
    return position;
  }
  
  void hasBeenNomed(){
    isNomed = true;
  }
}
