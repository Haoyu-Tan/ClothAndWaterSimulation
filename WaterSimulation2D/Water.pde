

/**
int colNum = 100;
int rowNum = 100;
*/

int colNum = 105;
int rowNum = 60;

float h[][]; //height
float hu[][]; //momentum
float hv[][];

//Midpoint helper
float dhdt[][];
float dhudt[][];
float dhvdt[][];

//temp array(update each frame)
float h_mid[][];
float hu_mid[][];
float hv_mid[][];
float dhdt_mid[][];
float dhudt_mid[][];
float dhvdt_mid[][];

//midpoint info on each axis independently
float h_mid_u[][];
float h_mid_v[][];
float dhdt_mid_u[][];
float dhdt_mid_v[][];

PVector tankStart;
float tank_width;
float tank_height;
float tank_depth;


float dx;
float dy;

float damping = 0.5;

PShape bathtub;

//init
void initWater(){
  bathtub = objs[0];
  h = new float[rowNum][colNum];
  hu = new float[rowNum][colNum];
  hv = new float[rowNum][colNum];
  
  dhdt = new float[rowNum][colNum];
  dhudt = new float[rowNum][colNum];
  dhvdt = new float[rowNum][colNum];
  
  //
  h_mid = new float[rowNum][colNum];
  hu_mid = new float[rowNum][colNum];
  hv_mid = new float[rowNum][colNum];
  dhdt_mid = new float[rowNum][colNum];
  dhudt_mid = new float[rowNum][colNum];
  dhvdt_mid = new float[rowNum][colNum];
  
  h_mid_u = new float[rowNum][colNum];
  h_mid_v = new float[rowNum][colNum];
  dhdt_mid_u = new float[rowNum][colNum];
  dhdt_mid_v = new float[rowNum][colNum];
  
  
  tankStart = new PVector(50, 30, 50);
  
  tank_height = 150;
  /**
  tank_depth = 500;
  tank_width = 500;
  */
  
  tank_depth = 300;
  tank_width = 525;
  
  dx = tank_width / (colNum - 1);
  dy = tank_depth / (rowNum - 1);

  //dx = tank_depth / (colNum - 1);
  //dy = tank_width / (rowNum - 1);
  
  
  initHeight2();
}

void initHeight(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      h[i][j] = tankStart.y + j * 5;
      hu[i][j] = 0;
      hv[i][j] = 0;
    }
  }
}


void initHeight2(){
  float offset2 = tankStart.y + 100;
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      h[i][j] = offset2;
      
      if (i > 26 && i < 31 && j > 2 && j < 7){
        h[i][j] += 60;
        h[i][j] = h[i][j] - abs(29-i) * 10 - abs(5-j)*10;
      }
      
      hu[i][j] = 0;
      hv[i][j] = 0;
    }
  }
}

void setStart(){
  for(int i = 27; i < 31; i++){
    for (int j = 3; j < 7; j++){
        h[i][j] = tankStart.y + 100 + 60;
        h[i][j] = h[i][j] - abs(29-i) * 10 - abs(5-j)*10;
        hu[i][j] = 0;
        hv[i][j] = 0;
    }
  }
}

void generateRandomHP(){
  int ranX = int(random(7, rowNum - 7));
  int ranY = int(random(7, colNum - 7));
  
  for (int i = ranX - 2; i < ranX + 3; i++){
    for (int j = ranY - 2; j < ranY + 3; j++){
      h[i][j] = 60 + tankStart.y + 100;
      //hu[i][j] = 0;
      //hv[i][j] = 0;
    }
  }
  
  
}


boolean xIsPressed = false;
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
  /**
  if (xIsPressed){
    setStart();
  }
  */
}


void updateHHU(float dt){
  for (int i = 1; i < rowNum - 1; i++){
    for (int j = 1; j < colNum - 1; j++){
        h[i][j] += dhdt[i][j]*dt * damping;
        hu[i][j] += dhudt[i][j]*dt * damping;
        hv[i][j] += dhvdt[i][j]*dt* damping;
        if (h[i][j] == 0) h[i][j] = 1;
        
    }
  }
}

void computeSWE(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
        
        if (i > 0 && i < rowNum - 1 && j > 0 && j < colNum - 1){
          float dhudx = (hu_mid[i][j] - hu_mid[i][j - 1]) / dx;
          float dhvdy = (hv_mid[i][j] - hv_mid[i-1][j]) / dy;
          dhdt[i][j] = (-1) * (dhudx + dhvdy);
        }
        
        
        if (j > 0 && j < colNum - 1){
          float dhu2dx = (pow(hu_mid[i][j], 2) / h_mid_u[i][j] - pow(hu_mid[i][j - 1], 2) / h_mid_u[i][j - 1])/dx;
          float dgh2dx = g * (pow(h_mid_u[i][j], 2) - pow(h_mid_u[i][j - 1], 2)) / dx;
          
          float dhuvdy = 0; 
          if (i > 0){
            dhuvdy = ((hu_mid[i][j]*hv_mid[i][j]/ h_mid_u[i][j]) - (hu_mid[i-1][j]*hv_mid[i-1][j] / h_mid_u[i-1][j])) / dy; 
          }
          dhuvdy = 0;
          dhudt[i][j] = (-1) * (dhu2dx + 0.5 * dgh2dx + dhuvdy);
        }
        
        if (i > 0 && i < rowNum - 1){
          float dhv2dy = (pow(hv_mid[i][j], 2) / h_mid_v[i][j] - pow(hv_mid[i-1][j], 2) / h_mid_v[i-1][j]) / dy;
          float dgh2dy = g * (pow(h_mid_v[i][j], 2) - pow(h_mid_v[i-1][j], 2)) / dy;
          
          float dhuvdx = 0;
          if (j > 0){
            dhuvdx = ( (hu_mid[i][j]*hv_mid[i][j] / h_mid_v[i][j]) - (hu_mid[i][j-1]*hv_mid[i][j-1] / h_mid_v[i][j - 1])) / dx;
          }
          dhuvdx = 0;
          dhvdt[i][j] = (-1) * (dhv2dy + 0.5 * dgh2dy + dhuvdx);
        }

    }
  }
}

void updateMP(float dt){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      
      if (j < colNum - 1){    
        h_mid_u[i][j] += dhdt_mid_u[i][j] * dt / 2;
        hu_mid[i][j] += dhudt_mid[i][j] * dt / 2;
      }
      if (i < rowNum - 1){
        h_mid_v[i][j] += dhdt_mid_v[i][j] * dt / 2;
        hv_mid[i][j] += dhvdt_mid[i][j] * dt / 2;
        
      }
     
    }
  }
}

//compute midpoint shallow water eulerian
void computeMPSWE(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){

        
        //compute dh/dt(mid)
        //float dhudx_mid = (hu[i][j+1] - hu[i][j]) /dx;
        //float dhvdy_mid = (hv[i+1][j] - hu[i][j]) / dy;
        //dhdt_mid[i][j] = (-1) * (dhudx_mid + dhvdy_mid);
        
        //compute dhv/dt(mid)
        if (i < rowNum - 1){
          //compute dhdt_mid_v
          float dhvdy_mid = (hv[i+1][j] - hv[i][j]) / dy;
          dhdt_mid_v[i][j] = (-1) * (dhvdy_mid);
          
          float dhv2dy_mid = (pow(hv[i+1][j], 2) / h[i+1][j] - pow(hv[i][j], 2) / h[i][j]) / dy;
          float dgh2dy_mid = g*(pow(h[i+1][j], 2) - pow(h[i][j], 2)) / dy;
          
          //!!!!!!!!!!!!!
          float dhuvdx_mid = 0;
          if (j < colNum - 1){
            dhuvdx_mid = (hv[i][j+1]*hu[i][j+1]/h[i][j+1] - hv[i][j]*hu[i][j]/h[i][j]) / dx;
          }
          dhuvdx_mid = 0;
          
          dhvdt_mid[i][j] = (-1) * (dhv2dy_mid + 0.5*dgh2dy_mid + dhuvdx_mid);
        }
        
        //compute dhudt
        if (j < colNum - 1){
          //compute dhdt_mid_u
          float dhudx_mid = (hu[i][j+1] - hu[i][j]) / dx;
          dhdt_mid_u[i][j] = (-1) * (dhudx_mid);
          
          
          //compute dhu/dt(mid)
          float dhu2dx_mid = (pow(hu[i][j+1], 2) / h[i][j+1] - pow(hu[i][j], 2) / h[i][j]) / dx;
          float dgh2dx_mid = g*(pow(h[i][j+1], 2) - pow(h[i][j], 2))/dx;
          
          float dhuvdy_mid = 0;
          if (i < rowNum - 1){
             dhuvdy_mid = (hu[i+1][j]*hv[i+1][j]/h[i+1][j] - hu[i][j]*hv[i][j]/h[i][j]) / dy;
          }
          dhuvdy_mid = 0;
          
          dhudt_mid[i][j] = (-1) * (dhu2dx_mid + 0.5*dgh2dx_mid + dhuvdy_mid);
        }
        
     
     }
  }
}

void computeMp(){
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      //h_mid[i][j] = (h[i][j+1] + h[i][j]) / 2;
      //if (h_mid[i][j] == 0) h_mid[i][j] = 1;
      
      //compute midpoint on each direciton seperately
      if (j < colNum - 1){
        h_mid_u[i][j] = (h[i][j+1] + h[i][j]) / 2;
        hu_mid[i][j] = (hu[i][j+1] + hu[i][j]) / 2;
        if (h_mid_u[i][j] == 0) h_mid_u[i][j] = 1;
      }
      
      if (i < rowNum - 1){
        h_mid_v[i][j] = (h[i+1][j] + h[i][j]) / 2;
        hv_mid[i][j] = (hv[i+1][j] + hv[i][j]) / 2;
        if (h_mid_v[i][j] == 0) h_mid_v[i][j] = 1;
      }
      
    }
  }
}

//boundary
/**
void free(){
  for (int i = 0; i < rowNum; i++){
    h[i][0] = h[i][1];
    h[i][colNum - 1] = h[i][colNum - 2];
    
    hu[i][0] = hu[i][1];
    hu[i][colNum - 1] = hu[i][colNum - 2];
  }
}
*/


void reflective(){
  for (int i = 0; i < rowNum; i++){
    h[i][0] = h[i][1];
    h[i][colNum - 1] = h[i][colNum - 2];
    
    hu[i][0] = -hu[i][1];
    hu[i][colNum - 1] = -hu[i][colNum - 2];
  }
  
  for (int j = 0; j < colNum; j++){
    
    h[0][j] = h[1][j];
    h[rowNum - 1][j] = h[rowNum - 2][j];
    
    hv[0][j] = -hv[1][j];
    hv[rowNum - 1][j] = -hv[rowNum - 1][j];
  }
  
}

//draw
void drawWater(){
  //drawTank();
  //drawFrame();
  drawBathtub();
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

void drawBathtub(){
  
  pushMatrix();
  translate(tankStart.x + 148, tankStart.y + 40, tankStart.z + 286);
  //rotate(PI/2);
  scale(217, 115, 144);
  shape(bathtub);
  popMatrix();
}

void renderWater(){
  noStroke();
  //fill(102, 255, 255, 200);
  //fill(102, 255, 220, 200);
  fill(152, 228, 255, 200);
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
  
  /**
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
    vertex(tankStart.x + tank_width, h[rowNum - 1][j], tankStart.z + j * dy);
    vertex(tankStart.x + tank_width, h[rowNum - 1][j+1], tankStart.z + (j+1)*dy);
    vertex(tankStart.x + tank_width, tankStart.y, tankStart.z + (j+1) * dy);
    vertex(tankStart.x + tank_width, tankStart.y, tankStart.z + j*dy);
    endShape();
    
  }
  */
}

void drawFrame(){
  
  stroke(255, 0, 0);
  for (int i = 0; i < rowNum; i++){
    for (int j = 0; j < colNum; j++){
      point(tankStart.x + i*dx, h[i][j], tankStart.z + j*dy);
    }
  }
}
