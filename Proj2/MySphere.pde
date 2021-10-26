
class MySphere{
  
  PVector pos;
  float r;
  
  MySphere(PVector p, float radius){
    this.pos = p;
    this.r = radius;

  }
  
  void drawSphere(){
    pushMatrix();
    noStroke();
    fill(26, 102, 34);
    translate(pos.x, pos.y, pos.z);
    
    sphere(r);
    popMatrix();
  }
}
