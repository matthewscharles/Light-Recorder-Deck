//Light Recorder Deck for Raspberry Pi.
//Charles Matthews 2019
//GUI for OSC communication with Pure Data
//Run this in presentation mode

//Slider code based on example from the Processing Scrollbar example
//CC-BY-NC
//https://creativecommons.org/licenses/by-nc/4.0/

HScrollbar hs1, hs2, hs3;  // Two scrollbars

int[] cBuffer = {0, 0, 0};
PImage img1, img2;  // Two images to load

import oscP5.*;
import netP5.*;

OscP5 oscP5;

NetAddress puredata;


void setup() {
    oscP5 = new OscP5(this, 12000);
  puredata = new NetAddress("127.0.0.1", 8000);

  size(800, 600);
  noStroke();



  hs1 = new HScrollbar(32, height/3-32, width/3, 40, 2);
  hs2 = new HScrollbar(32, height/3+32, width/3, 40, 2);
  hs3 = new HScrollbar(32, height/3+96, width/3, 40, 2);
  HScrollbar[] sliders = {hs1, hs2, hs3};

  sliders[0].setColor(color(255, 0, 0));
  sliders[1].setColor(color(0, 255, 0));
  sliders[2].setColor(color(0, 0, 255));

  // Load images
  //img1 = loadImage("seedTop.jpg");
  //img2 = loadImage("seedBottom.jpg");
}

void draw() {
  //background(180, 0, 100);
  noCursor(); //this shouldn't work in presentation mode, but seems to be fine!
  HScrollbar[] sliders = {hs1, hs2, hs3}; //how to define this globally?

  background(color(sliders[0].getPos(), sliders[1].getPos(), sliders[2].getPos()));


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

for(int i = 0; i < 3; i++) {
  sliders[i].update();
  sliders[i].display();
  cBuffer[i] = constrain(int(sliders[i].getPos()), 0, 255);
  // println("slider " + i + " " + sliders[i].getPos());
}
  oscP5.send(new OscMessage("/rgb").add((cBuffer[0])).add(cBuffer[1]).add(cBuffer[2]), puredata);


  // hs1.update();
  // hs2.update();
  // hs3.update();
  // hs1.display();
  // hs2.display();
  // hs3.display();


  // stroke(0);
  // line(0, height/2, width, height/2);

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

  void update() {
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
