class Cloth{

  //basic information
  float radius = 2;
  PVector startPos;
  float dist; //distance with neighbor node at the beginning
  int iNum; //num of lines of node
  int jNum; //num of node each row
  boolean inAirDragMode;
  PImage tex = imgs[1];
  
  //physic information, need to tune!!!!!!
  float mass = 1.0; //TRY-IT: How does changing mass affect resting length of the rope?
  PVector gravity;
  //float k = 200; //TRY-IT: How does changing k affect resting length of the rope?
  float k;
  float kd; //damping
  
  float k_digLarge;
  float k_digSmall; 
  
  /**
  with aero
  float k = 400;
  float kd = 50; //damping
  */
  float restLen = 20;
  
  //collision constant
  float k_bounce_floor = 0.02;
  float k_bounce_sphere = 0.2;
  
  //air force constant
  float k_aero = -0.000025; //-1/2*p(density)c_d (drag coeffienct)
  PVector v_air = new PVector(-8, 0, 0);
  
  //collision threshold
  float collAvoidDist = 0.1;
  float collAvoidTime = 0.01;
  
  
  //Initial positions and velocities of masses
  PVector pos[][];
  PVector vel[][];
  PVector acc[][];
 
   
  Cloth(int i, int j, float d, PVector p){
    this.iNum = i;
    this.jNum = j;
    this.dist = d;
    this.startPos = p;
    this.pos = new PVector[iNum][jNum];
    this.vel = new PVector[iNum][jNum];
    this.acc = new PVector[iNum][jNum];
    this.restLen = d;
    
    this.gravity = PVector.mult(g, mass);
    this.gravity = PVector.mult(gravity, (-1));
    
    this.setConstToNormalMode();
    //this.setConstToAirDragMode();
    //initialize value of all array
    
    initCloth();
    
  }
  
  void initCloth(){
    v_air = new PVector(-8, 0, 0);
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        pos[i][j] = new PVector(startPos.x + i * dist, startPos.y + 0, startPos.z + j*dist);
        vel[i][j] = new PVector(0, 0, 0);
        acc[i][j] = new PVector(0, 0, 0);
      }
    }
  }
  
  void update(float dt){
    //reset acceleration
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        acc[i][j] = new PVector(0, 0, 0);
        //acc[i][j].add(gravity);
        acc[i][j] = PVector.add(acc[i][j], gravity);
      }
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
    for (int i = 0; i < iNum - 1; i++){
      for (int j = 0; j < jNum; j++){
        computeSpringForce(i, j, i + 1, j, 0);
      }
    }
    //println("after first slot");
    
    //vertical
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum - 1; j++){
        computeSpringForce(i, j, i, j + 1, 0);
      }
    }
    
    //println("after second slot");
    
    //diagonal
    
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        //dir:\
        //last line don't have string in this dir
        if (i > 0 && j > 0)
          computeSpringForce(i - 1, j - 1, i, j, 1);
        //println("after third slot");
        //dir:/
        //from bottom line to upper left
        if ( j < (jNum - 1) && i > 0)
          computeSpringForce(i-1, j+1,  i, j, 1);
        if (i > 1 && j > 1){
          computeSpringForce(i - 2, j - 2, i, j, 2);
        }
        if (i > 1 && j < jNum - 2){
          computeSpringForce(i-2, j+2, i, j, 2);
        }
      }
    }
    

   if (inAirDragMode){
      for (int i = 0; i < iNum - 1; i++){
        for (int j = 0; j < jNum - 1; j++){
          
          //1,2,4
          computeAeroForce(i,j, i+1,j,i,j+1);
          
          
          //1,2,3
          computeAeroForce(i,j, i+1,j, i+1,j+1);
          
          //1,3,4
          computeAeroForce(i,j, i+1,j+1, i,j+1);
          
          //2,3,4
          computeAeroForce(i+1,j, i+1,j+1, i,j+1);
          
        }
      }
   }
    
   
   
    
    //println("after forth slot");
    
    
    //update velocity and position
    //eulerian currently
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        //velocity need to set to 0 for the first line
        if (i == 0) vel[i][j] = new PVector(0, 0, 0);
        //else vel[i][j].add(acc[i][j].mult(dt));
        else vel[i][j] = PVector.add(vel[i][j], PVector.mult(acc[i][j], dt));
        
        
        PVector deltP = PVector.mult(vel[i][j], dt);
        pos[i][j] = PVector.add(pos[i][j], deltP);
      }
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
  
  void setConstToAirDragMode(){
    
    /**
    k = 400;
    kd = 50;
    */
    
    
    k = 200;
    kd = 15;
    
   
    /**
    k = 100;
    kd = 15;
    */
    
    k_digLarge = 200;
    k_digSmall = 200;
    
    /**
    k_digLarge = 10;
    k_digSmall = 10;
    */
    inAirDragMode = true;
  }
  
  void setConstToNormalMode(){
    k = 200;
    kd = 30;
   
    
    k_digLarge = 150;
    k_digSmall = 180;
   
    inAirDragMode = false;
  }
  
  //provide index of three points P(i, j), P(m, n), P(a, b), compute the air drag used on the triangle
  void computeAeroForce(int i, int j, int m, int n, int a, int b){
    //V:
    //compute average velocity of triangle
    PVector vAvg = PVector.add(vel[i][j], vel[m][n]);
    //vAvg.add(vel[a][b]);
    vAvg = PVector.add(vAvg,vel[a][b]);
    vAvg = PVector.div(vAvg, 3.0f);
    vAvg = PVector.sub(vAvg,v_air);
    
    /*
    vAvg.div(3.0f);
    vAvg.sub(v_air);
    */
    //println(vAvg.x,vAvg.y,vAvg.z);
    
    //n
    //compute the normal of triangle
    PVector v1 = PVector.sub(pos[m][n], pos[i][j]);
    PVector v2 = PVector.sub(pos[a][b], pos[i][j]);
    PVector normStar = v1.cross( v2); //not normalize normal
    //println("normStar: " + normStar);
    
    //
    float temp = vAvg.mag();
    temp *= PVector.dot(vAvg, normStar);
    temp = temp / (2 * normStar.mag());
    temp *= k_aero;
    PVector fAero = PVector.mult(normStar, temp);
    
    fAero = PVector.div(fAero, mass);
    
    acc[i][j].add(fAero);
    acc[m][n].add(fAero);
    acc[a][b].add(fAero);
    //println("aero force is " + fAero);
    
    //return fAero;
    
  }
  
  
  void handleCollision2(float dt){
    
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        float di = clothSphere.pos.dist(pos[i][j]);
        
        if (di < clothSphere.r + collAvoidDist + radius){
          PVector norm = PVector.sub(clothSphere.pos, pos[i][j]);
          norm = PVector.mult(norm, -1);
          norm.normalize();
          PVector bounce = PVector.mult(norm, PVector.dot(vel[i][j], norm));
          PVector deltV = PVector.mult(bounce, (1 + k_bounce_sphere));
          vel[i][j] = PVector.sub(vel[i][j], deltV);
          PVector deltP =  PVector.mult(norm, (collAvoidDist + radius + clothSphere.r - di));
          pos[i][j] = PVector.add(pos[i][j], deltP);
          
        }
      }
    }
    
  }
  
  
  
  //continuous collision detection not work as expected
  void handleCollision(float dt){
    
    
    float actualRadius = clothSphere.r + radius;
    
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        
        //in this project, the height of floor is fixed at 0
        float ttcWithFloor = (pos[i][j].y - floorH - radius) / vel[i][j].y ;
        
        //check if hit with floor
        //when t >= 0 or t <= dt need to handle collision
        boolean hitWithFloor = (ttcWithFloor >= 0) && (ttcWithFloor <= dt) ? true : false;
        
        hitInfo hitWithSphere = raySphereIntersect(clothSphere.pos, actualRadius, pos[i][j], vel[i][j], dt);
        
        if (hitWithSphere.hit && hitWithFloor){
          //hit with sphere & floor, need to compare the time to solve collision
          if (hitWithSphere.t < ttcWithFloor){
            //hit with sphere first
            
           
            //1
            PVector deltPos =  PVector.mult(vel[i][j], hitWithSphere.t - collAvoidTime);
            pos[i][j] = PVector.add(pos[i][j], deltPos);
            PVector norm = PVector.sub(clothSphere.pos, pos[i][j]);
            norm.mult(-1);
            norm.normalize();
            
            PVector bounceDir = PVector.mult(norm, PVector.dot(vel[i][j], norm));
            PVector deltV = PVector.mult(bounceDir, (1+k_bounce_sphere));
            vel[i][j] = PVector.sub(vel[i][j], deltV);
  
            
          }
          else{
            //hit with floor first
            pos[i][j].y = floorH + radius + collAvoidDist;
            vel[i][j].y = vel[i][j].y * k_bounce_floor * (-1);
          }
          
          continue;
          
        }
        else if (hitWithSphere.hit){
          //hit with spere only
           
          
           PVector deltPos =  PVector.mult(vel[i][j], hitWithSphere.t - collAvoidTime);
           pos[i][j] = PVector.add(pos[i][j], deltPos);
           PVector norm = PVector.sub(clothSphere.pos, pos[i][j]);
           //norm.mult(-1);
           norm.normalize();
            
           PVector bounceDir = PVector.mult(norm, PVector.dot(vel[i][j], norm));
           PVector deltV = PVector.mult(bounceDir, (1+k_bounce_sphere));
           vel[i][j] = PVector.sub(vel[i][j], deltV);
          
            
           //don't forget to update position!!!!!
           continue;
        }
        else if (hitWithFloor){
          //not hit with floor only
          pos[i][j].y = floorH + radius + collAvoidDist;
          vel[i][j].y = vel[i][j].y * k_bounce_floor * (-1);
          continue;
        }
        
        PVector addVal = PVector.mult(vel[i][j], dt);
        pos[i][j] = PVector.add(pos[i][j], addVal);
        
      }
    }
    
  }
  
  /**
  void collisionDetection(){

  }
  */
  
  void computeSpringForce(int i, int j, int m, int n, int mode){
    float kString = k;
    //spring
    PVector diff = PVector.sub(pos[m][n], pos[i][j]);
    
    //println("diff: " + diff.x + ", " + diff.y + ", " + diff.z);
    //println("pos: " + pos[m][n].x + ", " + pos[m][n].y + ", " + pos[m][n].z);
    
    float realStrLen = restLen;
    if (mode == 1){
      realStrLen = restLen * sqrt(2); 
      kString = k_digSmall;
    }
    else if (mode == 2){
      realStrLen = restLen * 2 * sqrt(2);
      kString = k_digLarge;
    }
    
    float stringF = -kString * (diff.mag() - realStrLen);
    
    //damping
    PVector strDir = diff.normalize();
    float projFirst = vel[i][j].dot(strDir);
    float projSecond = vel[m][n].dot(strDir);
    float dampF =  (projSecond - projFirst) * (-kd);
    
    PVector force = strDir.mult(stringF + dampF);
    
    //acc[i][j].add(force.mult(-1.0 / mass));
    //acc[m][n].add(force.mult(1.0/mass));
    
    acc[i][j].add(PVector.mult(force, (-1.0) / mass));
    acc[m][n].add(PVector.mult(force, 1.0 / mass));
    
    
  }
  
  void drawCloth(){
    float pwidth = tex.width/jNum;
    float pheight = tex.height/iNum;
    for (int i = 0; i < iNum - 1; i++){
      for (int j = 0; j < jNum - 1; j++){
        PVector p1 = pos[i][j];
        PVector p2 = pos[i][j+1];
        PVector p3 = pos[i+1][j+1];
        PVector p4 = pos[i+1][j];
        float startW = pwidth*i;
        float endW = pwidth * (i+1);
        float startH = pheight*(jNum - j);
        float endH = pheight * (jNum - j - 1);
        
        beginShape();
        texture(tex);
        noStroke();
        /**
        vertex(p1.x, p1.y, p1.z,startW, startH);
        vertex(p2.x, p2.y, p2.z,startW, endH);
        vertex(p3.x, p3.y, p3.z, endW, endH);
        vertex(p4.x, p4.y, p4.z, endW, startH);
        */
        
        vertex(p1.x, p1.y, p1.z,startH, startW);
        vertex(p2.x, p2.y, p2.z, endH, startW);
        vertex(p3.x, p3.y, p3.z, endH, endW);
        vertex(p4.x, p4.y, p4.z, startH, endW);

        endShape();
        
      }
    }
  }
  
  void drawFrame(){
    for (int i = 0; i < iNum; i++){
      for (int j = 0; j < jNum; j++){
        PVector currNode = pos[i][j];
        //draw node itself
        fill(255, 0, 0);
        noStroke();
        pushMatrix();
        translate(currNode.x, currNode.y, currNode.z);
        sphere(radius);
        popMatrix();
        
        boolean dR = true;
        boolean dB = true;
        boolean dBL = true;
        //draw lines
        if (i + 1 >= iNum) dR = false;
        if (j + 1 >= jNum) dB = false;
        if (i - 1 < 0) dBL = false;
        
        stroke(0, 0, 0);
        strokeWeight(2);
        if (dR)
          line(currNode.x, currNode.y, currNode.z, pos[i+1][j].x, pos[i+1][j].y, pos[i+1][j].z);
  
        
        if (dB)
          line(currNode.x, currNode.y, currNode.z, pos[i][j+1].x, pos[i][j+1].y, pos[i][j+1].z);
        
        if (dR && dB)
          line(currNode.x, currNode.y, currNode.z, pos[i+1][j+1].x, pos[i+1][j+1].y, pos[i+1][j+1].z);
        
        if (dBL && dB)
          line(currNode.x, currNode.y, currNode.z, pos[i-1][j+1].x, pos[i-1][j+1].y, pos[i-1][j+1].z);
        
      }
    }
  }
  
}
