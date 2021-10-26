

float radius = 1;
int colNum = 30;
int rowNum = 30;

float h[][]; //height
float hu[][]; //momentum

//Midpoint helper
float dhdt[][];
float dhudt[][];

//temp array(update each frame)
float h_mid[][];
float hu_mid[][];
float dhdt_mid[][];
float dhudt_mid[][];


PVector tankStart;
float tank_width;
float tank_height;
float tank_depth;


float dx;
float dy;

float damping = 0.7;

//init
void initWater(){
  h = new float[rowNum][colNum];
  hu = new float[rowNum][colNum];
  
  dhdt = new float[rowNum][colNum];
  dhudt = new float[rowNum][colNum];
  
  //
  h_mid = new float[rowNum][colNum];
  hu_mid = new float[rowNum][colNum];
  dhdt_mid = new float[rowNum][colNum];
  dhudt_mid = new float[rowNum][colNum];
  
  tankStart = new PVector(50, 30, 50);
  tank_width = 500;
  tank_height = 200;
  tank_depth = 500;
  
  dx = tank_width / (colNum - 1);
  dy = tank_depth / (rowNum - 1);
  
  initHeight();
}

void initHeight(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      h[i][j] = tankStart.y + j * 5;
    }
  }
}

float offset2 = 30;
void initHeight2(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      if (j > rowNum / 2) h[i][j] = offset2 + tankStart.y +(j - rowNum/2) * 5;
      else h[i][j] = offset2 + tankStart.y;
    }
  }
}

float offset3 = 100;
void initHeight3(){
  for (int i = 0; i < rowNum; i++){
    int m = 0;
    int n = colNum - 1;
    while (m <= n){
      h[i][m] = offset3 - 5 * m;
      h[i][n] = offset3 - 5 * m;
      m++;
      n--;
    }
  }
}


//update
void updateWater(float dt){
  
  //println("============================");
  //compute midpoint
  computeMp();
  
  /**
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      println("h_mid is " + h_mid[i][j]);
      println("hu_mid is " + hu_mid[i][j]);
    }
  }
  */
  
  //compute swe using midpoint
  computeMPSWE();
  
  /**
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      println("dhdt is: " + dhdt_mid[i][j]);
      println("dhudt is: " + dhudt_mid[i][j]);
    }
  }
  */
  
  updateMP(dt);
  
  //update dh and dhu
  computeSWE();
  updateHHU(dt);
  
  //set the boundary condition
  reflective();

  /**
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      if (h[i][j] == 0 || hu[i][j] == 0 || h[i][j] > 1000 || h[i][j] < -100){
        println("h is : " + h[i][j] + ", hu is: " + hu[i][j]);
      }
    }
  }
  */
}


void updateHHU(float dt){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum - 1; j++){
      if (i == 0){
        h[i][j] += dhdt[i][j]*dt * damping;
        hu[i][j] += dhudt[i][j]*dt * damping;
        if (h[i][j] == 0) h[i][j] = 1;
        //if (hu[i][j] == 0) hu[i][j] = 1;
      }
      else{
        h[i][j] = h[0][j];
        hu[i][j] = hu[0][j];
      }
    }
  }
}

void computeSWE(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 1; j < colNum - 1; j++){
      if (i == 0){
        float dhudx = (hu_mid[i][j] - hu_mid[i][j - 1]) / dx;
        dhdt[i][j] = (-1) * dhudx;
        
        float dhu2dx = (pow(hu_mid[i][j], 2) / h_mid[i][j] - pow(hu_mid[i][j - 1], 2) / h_mid[i][j - 1])/dx;
        float dgh2dx = g * (pow(h_mid[i][j], 2) - pow(h_mid[i][j - 1], 2)) / dx;
        
        dhudt[i][j] = (-1) * (dhu2dx + 0.5 * dgh2dx);
      }
      /**
      else{
        dhdt[i][j] = dhdt[0][j];
        dhudt[i][j] = dhudt[0][j];
      }
      */
    }
  }
}

void updateMP(float dt){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum - 1; j++){
      if (i == 0){
        h_mid[i][j] += dhdt_mid[i][j]*dt/2;
        hu_mid[i][j] += dhudt_mid[i][j]*dt/2;
        if (h_mid[i][j] == 0) h_mid[i][j] = 1;
        //if (hu_mid[i][j] == 0) hu_mid[i][j] = 1;
      }
      else{
        h_mid[i][j] = h_mid[0][j];
        hu_mid[i][j] = hu_mid[0][j];
      }
    }
  }
}

//compute midpoint shallow water eulerian
void computeMPSWE(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum - 1; j++){
      if (i == 0){
        //compute dh/dt(mid)
        float dhudx_mid = (hu[i][j+1] - hu[i][j]) /dx;
        dhdt_mid[i][j] = (-1) * dhudx_mid;
        
        //compute dhu/dt(mid)
        float dhu2dx_mid = (pow(hu[i][j+1], 2) / h[i][j+1] - pow(hu[i][j], 2) / h[i][j]) / dx;
        float dgh2dx_mid = g*(pow(h[i][j+1], 2) - pow(h[i][j], 2))/dx;
        dhudt_mid[i][j] = (-1) * (dhu2dx_mid + 0.5*dgh2dx_mid);
      }
     
     }
  }
}

void computeMp(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum - 1; j++){
      if (i == 0){
        h_mid[i][j] = (h[i][j+1] + h[i][j]) / 2;
        hu_mid[i][j] = (hu[i][j+1] + hu[i][j]) / 2;
        if (h_mid[i][j] == 0) h_mid[i][j] = 1;
        //if (hu_mid[i][j] == 0) hu_mid[i][j] = 1;
      }
      else{
        h_mid[i][j] = h_mid[0][j];
        hu_mid[i][j] = hu_mid[0][j];
      }
    }
  }
}

//boundary

void free(){
  for (int i = 0; i < rowNum; i++){
    h[i][0] = h[i][1];
    h[i][colNum - 1] = h[i][colNum - 2];
    
    hu[i][0] = hu[i][1];
    hu[i][colNum - 1] = hu[i][colNum - 2];
  }
}

void reflective(){
  for (int i = 0; i < rowNum; i++){
    h[i][0] = h[i][1];
    h[i][colNum - 1] = h[i][colNum - 2];
    
    hu[i][0] = -hu[i][1];
    hu[i][colNum - 1] = -hu[i][colNum - 2];
  }
}

//draw
void drawWater(){
  drawTank();
  //drawFrame();
  renderWater();
}

void drawTank(){
  
  float w = tankStart.x + tank_width;
  float h = tankStart.y + tank_height;
  float d = tankStart.z + tank_depth;
  
  
  stroke(0, 0, 0);
  strokeWeight(3);
  
  line(tankStart.x, tankStart.y, tankStart.z, w, tankStart.y, tankStart.z);
  line(tankStart.x, tankStart.y, tankStart.z, tankStart.x, tankStart.y, d);
  line(tankStart.x, tankStart.y, tankStart.z, tankStart.x, h, tankStart.z);
  
  line(w, tankStart.y, d, w, tankStart.y, tankStart.z);
  line(w, tankStart.y, d, tankStart.x, tankStart.y, d);
  
  line(w, tankStart.y, d, w, h, d);
  line(tankStart.x, tankStart.y, d, tankStart.x, h, d);
  line(w, tankStart.y, tankStart.z, w, h, tankStart.z);
  
  line(tankStart.x, h, tankStart.z, w, h, tankStart.z);
  line(tankStart.x, h, tankStart.z, tankStart.x, h, d);
  line(w, h, d, tankStart.x, h, d);
  line(w, h, d, w, h, tankStart.z);
  
}

void renderWater(){
  noStroke();
  fill(36, 197, 229, 200);
  for (int i = 0; i < rowNum - 1; i++){
    for (int j = 0; j < colNum - 1; j++){
      PVector p1 = new PVector(tankStart.x + i*dx, h[i][j], tankStart.z + j*dy);
      PVector p2 = new PVector(tankStart.x + (i+1)*dx, h[i+1][j], tankStart.z + j*dy);
      PVector p3 = new PVector(tankStart.x + (i+1)*dx, h[i+1][j+1], tankStart.z + (j+1)*dy);
      PVector p4 = new PVector(tankStart.x + i*dx, h[i][j+1], tankStart.z + (j+1)*dy);
            
      beginShape();
      vertex(p1.x, p1.y, p1.z);
      
      vertex(p3.x, p3.y, p3.z);
      vertex(p2.x, p2.y, p2.z);
      endShape();
      
      beginShape();
      vertex(p1.x, p1.y, p1.z);
      vertex(p3.x, p3.y, p3.z);
      vertex(p4.x, p4.y, p4.z);
      endShape();
      
    }
  }
  
  for (int i = 0; i < rowNum - 1; i++){
    //one side
    beginShape();
    vertex(tankStart.x + i*dx, h[i][0], tankStart.z);
    vertex(tankStart.x + (i+1)*dx, h[i+1][0], tankStart.z);
    vertex(tankStart.x + (i+1)*dx, tankStart.y, tankStart.z);
    vertex(tankStart.x + i*dx, tankStart.y, tankStart.z);
    endShape();
    
    //the other side
    
    beginShape();
    vertex(tankStart.x + i*dx, h[i][colNum -1], tankStart.z + tank_depth);
    vertex(tankStart.x + (i+1)*dx, h[i+1][colNum - 1], tankStart.z + tank_depth);
    vertex(tankStart.x + (i+1)*dx, tankStart.y, tankStart.z + tank_depth);
    vertex(tankStart.x + i*dx, tankStart.y, tankStart.z + tank_depth);
    endShape();
    
  }
  
  for (int j = 0; j < colNum - 1; j++){
    beginShape();
    vertex(tankStart.x, h[0][j], tankStart.z + j * dy);
    vertex(tankStart.x, h[0][j+1], tankStart.z + (j+1)*dy);
    vertex(tankStart.x, tankStart.y, tankStart.z + (j+1) * dy);
    vertex(tankStart.x, tankStart.y, tankStart.z + j*dy);
    endShape();
    
    //the other side
    
    beginShape();
    vertex(tankStart.x + tank_width, h[colNum - 1][j], tankStart.z + j * dy);
    vertex(tankStart.x + tank_width, h[colNum - 1][j+1], tankStart.z + (j+1)*dy);
    vertex(tankStart.x + tank_width, tankStart.y, tankStart.z + (j+1) * dy);
    vertex(tankStart.x + tank_width, tankStart.y, tankStart.z + j*dy);
    endShape();
    
  }
  
}

void drawFrame(){
  
  stroke(255, 0, 0);
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      point(tankStart.x + i*dx, h[i][j], tankStart.z + j*dy);
    }
  }
}
