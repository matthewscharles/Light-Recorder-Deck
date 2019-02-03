//Light Recorder Deck for Raspberry Pi.
//Charles Matthews 2019
//GUI for OSC communication with Pure Data
//Run this in presentation mode

//Slider code based on example from the Processing Scrollbar example
//CC-BY-NC
//https://creativecommons.org/licenses/by-nc/4.0/

// Buttons 
  int rectX, rectY;      // Position of square button
  int circleX, circleY;  // Position of circle button
  int rectSize = 90;     // Diameter of rect
  int circleSize = 93;   // Diameter of circle
  color rectColor, circleColor, baseColor;
  color rectHighlight, circleHighlight;
  color currentColor;
  boolean rectOver = false;
  boolean circleOver = false;

  boolean[] buttonFlag = {false, false};

  boolean showCursor = true;
  

// Faders
  HScrollbar hs1, hs2, hs3;

  int[] cBuffer = {0, 0, 0};
  PImage img1, img2;  // Two images to load
  int[] sliderArray = {0, 0, 0};


// Set up OscP5
  import oscP5.*;
  import netP5.*;

  OscP5 oscP5;

  NetAddress puredata;

void setup() {

  {//Initialise OscP5
    oscP5 = new OscP5(this, 12000);
    puredata = new NetAddress("127.0.0.1", 8000);
  }

  {//Initialise buttons
    rectColor = color(0);
    rectHighlight = color(51);
    circleColor = color(255);
    circleHighlight = color(204);
    baseColor = color(102);
    currentColor = baseColor;
    circleX = width/2+circleSize/2+10;
    circleY = height/2;
    rectX = width/2-rectSize-10;
    rectY = height/2-rectSize/2;
    ellipseMode(CENTER);
  }

  //set up screen
    size(800, 600); //Size of my current RPi screen
    // noStroke();
  

  {//Initialise sliders
    hs1 = new HScrollbar(32, height/3-32, width/3, 40, 2);
    hs2 = new HScrollbar(32, height/3+32, width/3, 40, 2);
    hs3 = new HScrollbar(32, height/3+96, width/3, 40, 2);
    HScrollbar[] sliders = {hs1, hs2, hs3};

    sliders[0].setColor(color(255, 0, 0));
    sliders[1].setColor(color(0, 255, 0));
    sliders[2].setColor(color(0, 0, 255));
  }
  // sliders[3].setColor(color(255, 255, 255)); //re-introduce white later

  // Load images
  //img1 = loadImage("seedTop.jpg");
  //img2 = loadImage("seedBottom.jpg");
}

void draw() {
  //background(180, 0, 100);
  if (!showCursor) noCursor(); //this shouldn't work in presentation mode, but seems to be fine!
  HScrollbar[] sliders = {hs1, hs2, hs3}; //how to define this globally?

  background(color(sliders[0].getPos(), sliders[1].getPos(), sliders[2].getPos()));
  {//Draw buttons
    updateMouse(mouseX, mouseY);
    background(currentColor);

    if (rectOver) {
      fill(rectHighlight);
    } else {
      fill(rectColor);
    }
    stroke(255);
    rect(rectX, rectY, rectSize, rectSize);

    if (circleOver) {
      fill((buttonFlag[0] ? 255 : 0));
    } else {
      fill((buttonFlag[0] ? 255 : 0));
    }
    stroke(0);
    ellipse(circleX, circleY, circleSize, circleSize);
  }
  /*
    // Get the position of the img1 scrollbar
    // and convert to a value to display the img1 image
    //float img1Pos = hs1.getPos()-width/2;
    //fill(255);
    //image(img1, width/2-img1.width/2 + img1Pos*1.5, 0);

    // Get the position of the img2 scrollbar
    // and convert to a value to display the img2 image
    */
    //float img2Pos = hs2.getPos()-width/2;
    //fill(255);
    //image(img2, width/2-img2.width/2 + img2Pos*1.5, height/2);
  {//Draw and update sliders
    for(int i = 0; i < 3; i++) {
      sliders[i].update();
      sliders[i].display();
      
      cBuffer[i] = int(map(int(sliders[i].getPos()), 38, 302, 0, 255));
      //println(cBuffer[0]);
      // println("slider " + i + " " + sliders[i].getPos());
    }
    
    if (testArray(cBuffer[0], cBuffer[1], cBuffer[2])) {
      OscMessage sliderMsg = new OscMessage("/rgb");
      for (int i = 0; i < 3; i++) {
        sliderMsg.add((cBuffer[i]));
        sliderArray[i] = cBuffer[i];
        //println(sliderArray[0]);
      }
      oscP5.send(sliderMsg, puredata);
      //println(sliderMsg);
  }
    
    {//Send the OSC message from sliders
      
      if (buttonFlag[0] != buttonFlag[1]){
        oscP5.send(new OscMessage("/onoff").add(buttonFlag[0] ? 1 : 0), puredata);
        buttonFlag[1] = buttonFlag[0];
        println("got it: " + (buttonFlag[0] ? 1 : 0));
      }
      
      
    }
  }
}

boolean testArray(int r, int g, int b){
  int[] myArray = {r, g, b};
  boolean value = false;
  for (int i = 0; i < 3; i++){
    if (myArray[i] != sliderArray[i]) {
      value = true;
    }
  }
  
  
  
  return value;
  
}

void mousePressed() {
  if (circleOver) {
    currentColor = circleColor;
    buttonFlag[0] = !buttonFlag[0];
  }
  if (rectOver) {
    currentColor = rectColor;
  }
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width &&
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

void updateMouse(int x, int y){//from Buttons
  if ( overCircle(circleX, circleY, circleSize) ) {
    circleOver = true;
    rectOver = false;
  } else if ( overRect(rectX, rectY, rectSize, rectSize) ) {
    rectOver = true;
    circleOver = false;
  } else {
    circleOver = rectOver = false;
  }
}

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  color bgcolor = color(0, 0, 0);

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() { //added x y from buttons


    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;


    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void setColor(color c) {
    bgcolor = c;
  }



  void display() {
   stroke(0);
   strokeWeight(3);
   fill(bgcolor, 100);
   rect(xpos, ypos, swidth, sheight);
   // if (over || locked) {
   //   fill(0, 0, 0, 100);
   // } else {
     fill(bgcolor, 255);
   // }
   ellipse(spos+sheight/2, ypos+sheight/2, sheight * 1.5, sheight * 1.5);
 }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}
