class Rope{
  
   //basic information
  float radius = 2;
  PVector startPos;
  float dist; //distance with neighbor node at the beginning
  int iNum; //num of lines of node

  //physic information, need to tune!!!!!!
  float mass = 1.0; //TRY-IT: How does changing mass affect resting length of the rope?
  PVector gravity;
  //float k = 200; //TRY-IT: How does changing k affect resting length of the rope?
  float k;
  float kd; //damping
  
  boolean isReleased = false;
  
  /**
  with aero
  float k = 400;
  float kd = 50; //damping
  */
  float restLen = 20;
  
  //collision constant
  float k_bounce_floor = 0.02;
  float k_bounce_sphere = 0.2;
  
  //collision threshold
  float collAvoidDist = 0.1;
  float collAvoidTime = 0.01;
  
  
  //Initial positions and velocities of masses
  PVector pos[];
  PVector vel[];
  PVector acc[];
 
   
  Rope(int i, float d, PVector p){
    this.iNum = i;
    this.dist = d;
    this.startPos = p;
    this.pos = new PVector[iNum];
    this.vel = new PVector[iNum];
    this.acc = new PVector[iNum];
    this.restLen = d;
    
    this.gravity = PVector.mult(g, mass);
    this.gravity = PVector.mult(gravity, (-1));
    
    this.setConstToNormalMode();
    //initialize value of all array
    
    initRope();
    
  }
  
  void initRope(){
    for (int i = 0; i < iNum; i++){
        pos[i] = new PVector(startPos.x + i*dist, startPos.y, startPos.z);
        vel[i] = new PVector(0, 0, 0);
        acc[i] = new PVector(0, 0, 0);
    }
  }
  
  void update(float dt){
    //reset acceleration
    for (int i = 0; i < iNum; i++){
        acc[i] = new PVector(0, 0, 0);
        //acc[i][j].add(gravity);
        acc[i] = PVector.add(acc[i], gravity);
    }
    
    /**
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
         println("pos: " + pos[i][j].x + ", " + pos[i][j].y + ", " + pos[i][j].z);
      }
    }
    */
    
    //calculate forces & update acceleration
    //horizontal
    for (int i = 1; i < iNum; i++){
        computeSpringForce(i-1, i);
    }
    
    
    //update velocity and position
    //eulerian currently
    for (int i = 0; i < iNum; i++){
        //velocity need to set to 0 for the first line
        if (!isReleased && i == 0) vel[i] = new PVector(0, 0, 0);
        //else vel[i][j].add(acc[i][j].mult(dt));
        else vel[i] = PVector.add(vel[i], PVector.mult(acc[i], dt));
        
        
        PVector deltP = PVector.mult(vel[i], dt);
        pos[i] = PVector.add(pos[i], deltP);
    }
    
    
    
    //handleCollision(dt);
    
    handleCollision2(dt);
    
    /**
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        println("acc: " + acc[i][j].x + ", " + acc[i][j].y + ", " + acc[i][j].z);
        println("vel: " + vel[i][j].x + ", " + vel[i][j].y + ", " + vel[i][j].z);
        println("pos: " + pos[i][j].x + ", " + pos[i][j].y + ", " + pos[i][j].z);
      }
    }
    */
    
  }
  
  void setConstToNormalMode(){
    k = 200;
    kd = 30;
  }
  
  
  void handleCollision2(float dt){
    
    for (int i = 0; i < iNum; i++){
        float di = clothSphere.pos.dist(pos[i]);
        
        if (di < clothSphere.r + collAvoidDist + radius){
          PVector norm = PVector.sub(clothSphere.pos, pos[i]);
          norm = PVector.mult(norm, -1);
          norm.normalize();
          PVector bounce = PVector.mult(norm, PVector.dot(vel[i], norm));
          PVector deltV = PVector.mult(bounce, (1 + k_bounce_sphere));
          vel[i] = PVector.sub(vel[i], deltV);
          PVector deltP =  PVector.mult(norm, (collAvoidDist + radius + clothSphere.r - di));
          pos[i] = PVector.add(pos[i], deltP);
          
        }
      }
    }
  
  
  
  //continuous collision detection not work as expected
  void handleCollision(float dt){
    
    
    float actualRadius = clothSphere.r + radius;
    
    for (int i = 0; i < iNum; i++){
        //in this project, the height of floor is fixed at 0
        float ttcWithFloor = (pos[i].y - floorH - radius) / vel[i].y ;
        
        //check if hit with floor
        //when t >= 0 or t <= dt need to handle collision
        boolean hitWithFloor = (ttcWithFloor >= 0) && (ttcWithFloor <= dt) ? true : false;
        
        hitInfo hitWithSphere = raySphereIntersect(clothSphere.pos, actualRadius, pos[i], vel[i], dt);
        
        if (hitWithSphere.hit && hitWithFloor){
          //hit with sphere & floor, need to compare the time to solve collision
          if (hitWithSphere.t < ttcWithFloor){
            //hit with sphere first
            
           
            //1
            PVector deltPos =  PVector.mult(vel[i], hitWithSphere.t - collAvoidTime);
            pos[i] = PVector.add(pos[i], deltPos);
            PVector norm = PVector.sub(clothSphere.pos, pos[i]);
            norm.mult(-1);
            norm.normalize();
            
            PVector bounceDir = PVector.mult(norm, PVector.dot(vel[i], norm));
            PVector deltV = PVector.mult(bounceDir, (1+k_bounce_sphere));
            vel[i] = PVector.sub(vel[i], deltV);
  
            
          }
          else{
            //hit with floor first
            pos[i].y = floorH + radius + collAvoidDist;
            vel[i].y = vel[i].y * k_bounce_floor * (-1);
          }
          
          continue;
          
        }
        else if (hitWithSphere.hit){
          //hit with spere only
           
          
           PVector deltPos =  PVector.mult(vel[i], hitWithSphere.t - collAvoidTime);
            pos[i] = PVector.add(pos[i], deltPos);
            PVector norm = PVector.sub(clothSphere.pos, pos[i]);
            norm.mult(-1);
            norm.normalize();
            
            PVector bounceDir = PVector.mult(norm, PVector.dot(vel[i], norm));
            PVector deltV = PVector.mult(bounceDir, (1+k_bounce_sphere));
            vel[i] = PVector.sub(vel[i], deltV);
            
           //don't forget to update position!!!!!
           continue;
        }
        else if (hitWithFloor){
          //not hit with floor only
          pos[i].y = floorH + radius + collAvoidDist;
          vel[i].y = vel[i].y * k_bounce_floor * (-1);
          continue;
        }
        
        PVector addVal = PVector.mult(vel[i], dt);
        pos[i] = PVector.add(pos[i], addVal);
        
      }
    
  }
  
  /**
  void collisionDetection(){

  }
  */
  
  void computeSpringForce(int i, int m){
    //spring
    PVector diff = PVector.sub(pos[m], pos[i]);
    
    //println("diff: " + diff.x + ", " + diff.y + ", " + diff.z);
    //println("pos: " + pos[m][n].x + ", " + pos[m][n].y + ", " + pos[m][n].z);
    
    
    float stringF = -k * (diff.mag() - restLen);
    
    //damping
    PVector strDir = diff.normalize();
    float projFirst = vel[i].dot(strDir);
    float projSecond = vel[m].dot(strDir);
    float dampF =  (projSecond - projFirst) * (-kd);
    
    PVector force = strDir.mult(stringF + dampF);
    
    //acc[i][j].add(force.mult(-1.0 / mass));
    //acc[m][n].add(force.mult(1.0/mass));
    
    acc[i].add(PVector.mult(force, (-1.0) / mass));
    acc[m].add(PVector.mult(force, 1.0 / mass));
    
    
  }
  
  void drawCloth(){
  }
  
  void drawFrame(){
    for (int i = 0; i < iNum; i++){
      
        PVector currNode = pos[i];
        PVector nextNode = pos[i+1];
        //draw node itself
        fill(255, 0, 0);
        noStroke();
        pushMatrix();
        translate(currNode.x, currNode.y, currNode.z);
        sphere(radius);
        popMatrix();
    
        stroke(0, 0, 0);
        strokeWeight(2);
        
        line(currNode.x, currNode.y, currNode.z, nextNode.x, nextNode.y, nextNode.z);
        
    }
  }
  
}
