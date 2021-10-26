
/**
Name: Haoyu Tan
ID#: 5677259
*/


//for 3D scene
String textPath;
//0 for ground, 1 for cloth
String[] textName = {"wood.bmp", "goldy.jpg"};
PImage[] imgs = new PImage[textName.length];

//objects render on scene
Camera camera;
MySphere clothSphere;
Cloth cloth;

//Simulation Parameters
float floor = 500;
float floorH = 0;
PVector g = new PVector(0, 9.8, 0);  //gravity constant

//float friction = 2.2;

//Draw the scene: one sphere per mass, one line connecting each pair
boolean paused = true;
int fraction = 20;

int mode = 1;
boolean drawFrame = false;
boolean showAirDrag = false;

void initScene(){
  //load textures
  textPath = sketchPath("textures");
  
  for (int i = 0; i < imgs.length; i++){
    imgs[i] = loadImage(textPath + File.separator + textName[i]);
  }
}

void update(float dt){
  //drawRope(dt);
      cloth.update(dt);

}


//Create Window
String windowTitle = "Project2 Simulation";
void setup() {
  size(1000, 700, P3D);
  surface.setTitle(windowTitle);
  
  initScene();
  camera = new Camera();
  cloth = new Cloth(15, 15, 10,  new PVector(200, 200, 100));
  clothSphere = new MySphere(new PVector(300, 100, 170), 50);
}

int count = 10;
void draw() {
  
   camera.Update(1.0/frameRate);
  
  
  
  if (!paused){ 
    for (int i = 0; i < fraction; i++){
      
      update(1.0/(frameRate * fraction));
    }
  }
  
  //background(255, 255, 255);
  background(0, 0, 0);
  //apply light effects
  lights();
  //spotLight(255, 255, 255, 280, 1000, 170, 0, -1, 0, PI/4, 2);
  //directionalLight(255,255,255, 0,0,-1);
  ambientLight(200, 200, 200);
  
  //update camera
 
  
 
  /*
  if (!paused){
    if (count > 0){
      println(count + " update");
      update(1/frameRate);
      count--;
    }
  }
  */

  //draw
  drawGround();
  
  if (drawFrame){
    cloth.drawFrame();
  }
  else{
    cloth.drawCloth();
  }
  
  clothSphere.drawSphere();
  
  
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
    cloth.initCloth();
    paused = true;
  }
 
  if (key == 'z'){
    if (mode == 1){
      if (!showAirDrag){
        println("change to air drag mode");
        cloth.initCloth();
        cloth.setConstToAirDragMode();
        showAirDrag = true;
      }
      else{
        //without air drag
        cloth.initCloth();
        cloth.setConstToNormalMode();
        showAirDrag = false;
      }
    }
  }
  
  if (key == 'x'){
    drawFrame = !drawFrame;
  }
  
  if (key == '+'){
    
    if (showAirDrag && cloth.v_air.x <= 20){
      println("+ is pressed!");
      cloth.v_air.add(new PVector(1, 0, 0));
    }
  }
  
  if (key == '-'){
    if (showAirDrag && cloth.v_air.x >= -20){
      println("- is pressed!");
      cloth.v_air.sub(new PVector(1, 0, 0));
    }
  }
 
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

void drawGround(){
  noStroke();
  fill(255, 255, 255);
  
  float w = 100, h = 100;
  
  PImage img = imgs[0];
  for (int i = 0; i < 500; i+= w){
    for (int j = 0; j < 500; j+= h){
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
