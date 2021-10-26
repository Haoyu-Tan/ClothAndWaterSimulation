
/**
Name: Haoyu Tan
ID#: 5677259
*/


//for 3D scene
String textPath;
//0 for ground, 1 for cloth
String[] textName = {"floor1.png"};
String[] objName = {"Bathroom_Bathtub.obj"};
PImage[] imgs = new PImage[textName.length];
PShape[] objs = new PShape[objName.length];

//objects render on scene
Camera camera;

//Simulation Parameters
float floor = 500;
float floorH = 0;
//PVector g = new PVector(0, 9.8, 0);  //gravity constant
float g = 540;

//float friction = 2.2;

//Draw the scene: one sphere per mass, one line connecting each pair
boolean paused = true;
int fraction = 20;

int mode = 1;
boolean drawFrame = true;
boolean showAirDrag = false;

void initScene(){
  //load textures
  textPath = sketchPath("textures");
  
  for (int i = 0; i < imgs.length; i++){
    imgs[i] = loadImage(textPath + File.separator + textName[i]);
  }
  
  for (int i = 0; i < objs.length; i++){
    objs[i] = loadShape(textPath + File.separator + objName[i]);
  }
  
  initWater();
}

void update(float dt){
  updateWater(dt);

}


//Create Window
String windowTitle = "Water Simulation";
void setup() {
  size(1000, 700, P3D);
  surface.setTitle(windowTitle);
  
  initScene();
  camera = new Camera();

}

int count = 10;
void draw() {
  
  //update camera
  camera.Update(1.0/frameRate);
  

  
  
   if (!paused){ 
    for (int i = 0; i < fraction; i++){
      
      update(1.0/(frameRate * fraction));
    }
  }
  
  //background(255, 255, 255);
  background(20, 20, 20);
  //lights();
  //apply light effects
  
  directionalLight(50, 50, 50, 0, -1.4142, 1.4142);
  spotLight(255, 255, 255, 100, 3000, 300, 0, -1, 0, PI/2, 100);
  ambientLight(40, 40, 40);
  
  

  //draw
  drawGround();
  
  drawWater();
  
  
  if (paused)
    surface.setTitle(windowTitle + " [PAUSED]");
  else
    surface.setTitle(windowTitle + " "+ nf(frameRate,0,2) + "FPS");
}

void keyPressed(){
  camera.HandleKeyPressed();
 
  if (key == ' '){
    paused = !paused;
    
  }
  
  if (key == 'r'){
    //println("reset");
    initWater();
    
    paused = true;
  }
  /**
  if (key == 'x'){
    xIsPressed = !xIsPressed;
  }
  */
  if (key == 'z'){
    generateRandomHP();
  }
 
 
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

void drawGround(){
  noStroke();
  fill(255, 255, 255);
  
  float w = 500, h = 500;
  
  PImage img = imgs[0];
  for (int i = -700; i < 800; i+= w){
    for (int j = -500; j < 1000; j+= h){
      pushMatrix();
      beginShape();
      texture(img);
      noStroke();
      translate(i, floorH, j);
      vertex(0, 0, 0, 0, 0);
      vertex(w, 0, 0, img.width, 0);
      vertex(w, 0, h, img.width, img.height);
      vertex(0, 0, h, 0, img.height);
      endShape();
      popMatrix();
    }
  }
  noStroke();
}
