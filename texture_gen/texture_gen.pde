/*
  tile wall generator
  -------------------
  Creates a basic pixelart tile wall texture using cellular automata.
  This was created as a test for practical applications of cellular automata as well as to be potentially used in future game related projects.
  
  written by Adrian Margel, Fall 2017
*/

class Tile {
  //tile position
  int x;
  int y;
  //tile size (width and height)
  int sizeX;
  int sizeY;
  //tile color/hue
  int hue;
  //the texture of the tile generated
  Pixel texture[][];
  
  //set pos x and y, size x and y, as well as hue
  Tile(int tx, int ty, int tsx, int tsy, int h) {
    x=tx;
    y=ty;
    sizeX=tsx;
    sizeY=tsy;
    //initialize texture with size
    texture=new Pixel[sizeX][sizeY];
    hue=h;
  }
  
  //generate the texture
  void generate() {
    
    //create a 2d array of values for how deeply each pixel is engraved
    int depth[][]=new int[sizeX][sizeY];
    
    //set each pixel to a random depth
    for (int i=0; i<depth.length; i++) {
      for (int j=0; j<depth[i].length; j++) {
        depth[i][j]=(int)random(1, 2.4);
      }
    }
    
    //run a simple cellular automata for a few cycles to smooth out the randomness
    for (int cycle=0; cycle<3; cycle++) {
      
      //stores the new depth results from the cellular automata like a buffer
      int DCell[][]=new int[sizeX][sizeY];
      
      for (int i=0; i<depth.length; i++) {
        for (int j=0; j<depth[i].length; j++) {
          
          //set the depth buffer for the cellular automata to the current depth of the pixel
          DCell[i][j]=depth[i][j];
          
          //surround keeps track of a total score based on current target pixel's neighbors
          int surround=0;
          
          //for all pixels in a 3x3 square around the target pixel:
          //  -increase surround if a lower depth value than the target tile
          //  -decrease surround if a higher depth value than the target tile
          
          //the following code is broken into a series of if else statements in order to only test tiles in the array bounds
          if (i-1>=0) {
            if (depth[i-1][j]<depth[i][j]) {
              surround++;
            } else if (depth[i-1][j]>depth[i][j]) {
              surround--;
            }
            if (j-1>=0) {
              if (depth[i-1][j-1]<depth[i][j]) {
                surround++;
              } else if (depth[i-1][j-1]>depth[i][j]) {
                surround--;
              }
            }
            if (j+1<sizeY) {
              if (depth[i-1][j+1]<depth[i][j]) {
                surround++;
              } else if (depth[i-1][j+1]>depth[i][j]) {
                surround--;
              }
            }
          }
          if (i+1>sizeX) {
            if (depth[i+1][j]<depth[i][j]) {
              surround++;
            } else if (depth[i+1][j]>depth[i][j]) {
              surround--;
            }
            if (j-1>=0) {
              if (depth[i+1][j-1]<depth[i][j]) {
                surround++;
              } else if (depth[i+1][j-1]>depth[i][j]) {
                surround--;
              }
            }
            if (j+1<sizeY) {
              if (depth[i+1][j+1]<depth[i][j]) {
                surround++;
              } else if (depth[i+1][j+1]>depth[i][j]) {
                surround--;
              }
            }
          }
          if (j-1>=0) {
            if (depth[i][j-1]<depth[i][j]) {
              surround++;
            } else if (depth[i][j-1]>depth[i][j]) {
              surround--;
            }
          }
          if (j+1<sizeY) {
            if (depth[i][j+1]<depth[i][j]) {
              surround++;
            } else if (depth[i][j+1]>depth[i][j]) {
              surround--;
            }
          }
          
          //if the enough neighbors are on a higher/lower depth then change the depth of the target pixel to be closer to the neighbors
          //this will cause things to slowly smooth out
          if (surround>=3) {
            DCell[i][j]--;
          } else if (surround<=-3) {
            DCell[i][j]++;
          }
        }
      }
      
      //flip the depth buffer/cellular automata output back to the depth array
      //like any cellular automata this needs to be done AFTER the rest of the calculations for the cycle
      for (int i=0; i<depth.length; i++) {
        for (int j=0; j<depth[i].length; j++) {
          depth[i][j]=DCell[i][j];
        }
      }
    }
    
    //update the display pixels with the new depth info to recalculate the lighting
    for (int i=0; i<texture.length; i++) {
      for (int j=0; j<texture[i].length; j++) {
        if (i==0||j==0) {
          texture[i][j]=new Pixel(color(hue, 30, 250));
        } else {
          if (depth[i-1][j]<depth[i][j]||depth[i][j-1]<depth[i][j]) {
            texture[i][j]=new Pixel(color(hue, 40, 200));
          } else if (depth[i-1][j]>depth[i][j]||depth[i][j-1]>depth[i][j]) {
            texture[i][j]=new Pixel(color(hue, 30, 250));
          } else {
            texture[i][j]=new Pixel(color(hue, 40, 220));
          }
        }
        if (i==sizeX-1||j==sizeY-1) {
          texture[i][j]=new Pixel(color(hue, 40, 200));
        }
      }
    }
  }
  
  //display all of the pixels for the texture to screen based on the tile position
  void display() {
    for (int i=0; i<texture.length; i++) {
      for (int j=0; j<texture[i].length; j++) {
        texture[i][j].display((x+i)*zoom, (y+j)*zoom, zoom);
      }
    }
  }
}

//this class is used to hold the pixels for a texture
//it's basically just a wrapper for color in case I later move this out of processing
class Pixel {
  color col;
  Pixel(color tcol) {
    col=tcol;
  }
  void display(float x, float y, float size) {
    fill(col);
    noStroke();
    rect(x, y, size, size);
  }
}

//zoom multiplier / how large each pixel is
float zoom=5;

//how tall the tiles are
int tileHeight=10;
//how wide the tiles are
int tileWidth=15;
//what color/hue the tiles are
int tileHue=40;

void setup() {
  //set color mode to use hue
  colorMode(HSB);
  //set window size
  size(800, 800);
  //set framerate to 1 so textures stay on screen for one second each
  frameRate(1);
  
  //fill the screen with a wall of tiles
  fillScreen();
}

void draw() {
  //randomize the tile size and color to be drawn to screen
  tileHeight=(int)random(5, 30);
  tileWidth=(int)random(5, 30);
  tileHue=(int)random(0, 256);
  
  //fill the screen with a wall of tiles
  fillScreen();
}

//draws enough randomly generated tiles to fill the screen
void fillScreen(){
  //create the tile used to draw the wall of tiles
  Tile drawTile=new Tile(0, 0, tileWidth, tileHeight, tileHue);
  drawTile.generate();
  drawTile.display();
  
  //regenerate and display the tile at various positions till the entire screen is filled
  while (drawTile.y*zoom<height) {
    while (drawTile.x*zoom<width) {
      drawTile=new Tile(drawTile.x+tileWidth, drawTile.y, tileWidth, tileHeight, tileHue);
      drawTile.generate();
      drawTile.display();
    }
    drawTile=new Tile(0, drawTile.y+tileHeight, tileWidth, tileHeight, tileHue);
    drawTile.generate();
    drawTile.display();
  }
}
