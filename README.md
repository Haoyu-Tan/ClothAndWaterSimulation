# ClothAndWaterSimulation

## Introduction

This is a project for cloth simulation and water simulation. 

For cloth simulation, I implement the cloth as an array of nodes connected with each others by springs. By calculating the forces on each node, the acceleration, velocity and position of the node can be updated each frame. There are two modes for this simulation, one is cloth without air drag and the other is cloth with air drag. The air drag helps the cloth stops naturally rather than swings back and forth for a while. There is a sphere on scene and the cloth is able to interact with it naturally. I also add a camera to better observe the simulation and multiple lights on scene to improve the rendering.

For water simulation, I choose to implement the shallow water equations(SWE) in both 1D and 2D. For 1D SWE, the water is placed in a tank. For 2D SWE, I place the simulation in a bathtub scene to improve the rendering. 

## Features

### Part 2

(1) Cloth Simulation

(2) 3D Simulation & Rendering

(3) Air Drag for Cloth

### Part 3 (grad`*)

Continuum Fluid Simulation (both 1D and 2D)

## User Control

### General

-- press 'q', 'a', 'e', 'd' move the camera in down, left, up, right direction
-- press 'w', 's' move the camera forward and backward
-- press 'left', 'right', 'up', 'down' rotate the camera
-- press 'space' pause the simulation
-- press 'r' to reset the simulation

### Cloth Simulation

-- press 'z'd switchs between the non-air drag mode(by default) and air drag mode. 
-- press 'x' switchs between wireframe mode and texture mode(by default).

### 2D Shallow Water Equation(SWE) Simulation

-- press 'z' to generate a random drop of water


## Images

(1) Cloth Simulation

* When cloth hits with the sphere
![2e714f9981408519619ab76aaed354b](https://user-images.githubusercontent.com/35856355/138800833-b26bdfcf-805c-43f9-b089-513a1c4a2d63.png)

* Moving the camera
![afaafddc760c9e1ff1405c275b27dab](https://user-images.githubusercontent.com/35856355/138800836-06d600dc-ea49-44b7-8fa2-be5714a922ee.png)

* When the cloth stays still naturally 
![aed1689efb99c13a88ae9303d5b66e1](https://user-images.githubusercontent.com/35856355/138800840-aaa253b6-a739-482b-a238-c5b8e84e58e2.png)

(2) 1D Shallow Water Eequation(SWE)

 * Start of the simulation
![03c7504b30cff6db3642a1cc88cbec7](https://user-images.githubusercontent.com/35856355/138800997-bc4cf0db-b2d7-4d6a-949d-35a0280bace1.png)

 * During the simulation
![b3811e9bda00d96016537b0debf4c42](https://user-images.githubusercontent.com/35856355/138801112-6661cdd6-abf4-4d1a-b490-a5768c707c1e.png)

(3) 2D Shallow Water Equation(SWE)

 * Start of the simulation
 ![184cb370c55dd8149db1d63b34a9a1e](https://user-images.githubusercontent.com/35856355/138801583-cf1a084f-4b16-418a-a41f-5eda86ec8c04.png)
 
 * During the simulation
 ![7c2139ed7659b4954c179cca76c8481](https://user-images.githubusercontent.com/35856355/138801678-ae00cad1-a601-499a-8500-eeab288f7777.png)
 
 ![47d97bd834ab3120a720d6a693b8ae7](https://user-images.githubusercontent.com/35856355/138801708-4fbada2f-2742-4062-b1c4-4c3ca66dd134.png)
 
 ![3ea98863ba28c00d8bd64f4e281d6cd](https://user-images.githubusercontent.com/35856355/138801745-cfa207e9-e95d-44b4-8d3d-ac4831d66604.png)


## Video and Timestamp

## Encountered Difficulties

The most challenge part is the 2D SWE simulation. The equations itself is hard to understand. At the beginning when I tried, the simulation always exploded in seconds. After trying different combination, I found that I need to treat each dimension seperately and calulate their midpoint seperately. 

## Art Contest

## References
Framework: 

Camera framework from Liam Tyler

Assets:

Bathtub: https://quaternius.com/

Floor texture for 2D water: https://assetstore.unity.com/packages/2d/textures-materials/floors/floor-materials-pack-v-1-140435 (Floor materials pack v.1)
