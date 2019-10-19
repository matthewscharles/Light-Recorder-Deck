import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Workshop_GUI extends PApplet {

//Light Recorder Deck for Raspberry Pi
//Engage and Interact / Defiant Journey version for Joanne Cox
//Charles Matthews 2019
//GUI for OSC communication with Pure Data
//Run this in presentation mode and make showCursor false for touch screen

//I wrote this as an initial Processing experiment. There are lots of lazy/wrong things within..
//Slider code based on example from the Processing Scrollbar example
//Buttons modified from the Processing Button example
//CC-BY-NC
//https://creativecommons.org/licenses/by-nc/4.0/

boolean showCursor = false;

//JSON for settings
  JSONObject json;


// Buttons
  RoundButton saver, enable, test, connect;
  RoundButton off, colour, sun, back, bugs, sophie;
  RoundButton[] allButtons = {off, colour, sun, back, bugs, sophie};


  int[] dimensions = {700, 500};

  //boolean[] buttonFlag = {false, false};



  int[] sliderOffset = {32, 100};
// Faders
  HScrollbar hs1, hs2, hs3; //can I take these out?
  HScrollbar[] sliders = {hs1, hs2, hs3};

  int[] cBuffer = {0, 0, 0};
  PImage img1, img2;  // Two images to load
  int[] sliderArray = {0, 0, 0};


// Set up OscP5
  
  

  OscP5 oscP5;

  NetAddress puredata;

public void setup() {

  {//Initialise OscP5
    oscP5 = new OscP5(this, 12000);
    puredata = new NetAddress("127.0.0.1", 8000);
  }





  //set up screen
     //Size of my current RPi screen
    sliderOffset[1] = height / 3;
    // noStroke();
  {//Initialise buttons
    saver = new RoundButton("button", PApplet.parseInt(width/3 * 2.5f), PApplet.parseInt(height / 4.5f * 1), "Save");//work out a ratio for x position, add y
    enable = new RoundButton("toggle", PApplet.parseInt(width/3 * 2.5f), PApplet.parseInt(height /4.5f * 2), "Audio");
    test = new RoundButton("toggle", PApplet.parseInt(width/3 * 2.5f), PApplet.parseInt(height / 4.5f * 3), "Test");
    connect = new RoundButton("button", PApplet.parseInt(width/3 * 2.5f), PApplet.parseInt(height / 4.5f * 4), "Connect");
    off = new RoundButton("button", PApplet.parseInt(width/3 * 2), PApplet.parseInt(height / 4.5f * 1), "Off");//work out a ratio for x position, add y
    colour = new RoundButton("button", PApplet.parseInt(width/3 * 2), PApplet.parseInt(height / 4.5f * 2), "Colours");//work out a ratio for x position, add y
    sun = new RoundButton("button", PApplet.parseInt(width/3 * 1.5f), PApplet.parseInt(height / 4.5f * 1), "Sun");//work out a ratio for x position, add y
    back = new RoundButton("button", PApplet.parseInt(width/3 * 1.5f), PApplet.parseInt(height / 4.5f * 2), "I'm Back");//work out a ratio for x position, add y
    bugs = new RoundButton("button", PApplet.parseInt(width/3 * 1.5f), PApplet.parseInt(height / 4.5f * 3), "Bed Bugs");//work out a ratio for x position, add y
    sophie = new RoundButton("button", PApplet.parseInt(width/3 * 1.5f), PApplet.parseInt(height / 4.5f * 4), "Sophie's Song");//work out a ratio for x position, add y



  }
    enable.setToggle(true);
  {//Initialise sliders

    //HScrollbar[] sliders = {hs1, hs2, hs3};
    for (int i = 0; i < 3; i++) {
      sliders[i] = new HScrollbar(sliderOffset[0], sliderOffset[1] + (64 * i), width/3, 40, 2);
    }
    //hs1 = new HScrollbar(sliderOffset[0], sliderOffset[1], width/3, 40, 2);
    //hs2 = new HScrollbar(sliderOffset, height/3+32, width/3, 40, 2);
    //hs3 = new HScrollbar(sliderOffset, height/3+96, width/3, 40, 2);
    //HScrollbar[] sliders = {hs1, hs2, hs3};

    sliders[0].setColor(color(255, 0, 0));
    sliders[1].setColor(color(0, 255, 0));
    sliders[2].setColor(color(0, 0, 255));
  }

  {//Initialise JSON
    //json = new JSONObject();
    json = loadJSONObject("data/new.json");
    JSONArray jRGB = json.getJSONArray("rgb");
    int[] myValues = jRGB.getIntArray();
    for (int i = 0; i<3; i++){
       cBuffer[i] = myValues[i];//is this redundant? just set straight to slider?
       sliders[i].setPos(cBuffer[i]);
       println("value " + i + " " + cBuffer[i]);
    }
  }
  // sliders[3].setColor(color(255, 255, 255)); //re-introduce white later

  // Load images
  //img1 = loadImage("seedTop.jpg");
  //img2 = loadImage("seedBottom.jpg");
}

public void draw() {
  //background(180, 0, 100);
  if (!showCursor) noCursor(); //this shouldn't work in presentation mode, but seems to be fine!
  //HScrollbar[] sliders = {hs1, hs2, hs3}; //how to define this globally?

  background(color(sliders[0].getPos(), sliders[1].getPos(), sliders[2].getPos()));
  {//Draw buttons

    fill(100, 0, 100, 100);
    rect(width/6 * 4.5f, height / 9 * 1, width/6 * 1, (height / 7) * 6);
    noFill();

    //looks like I wrote this just as I was starting to get into processing, this is clunky!
    sun.drawButton();
    back.drawButton();
    colour.drawButton();
    off.drawButton();
    bugs.drawButton();
    sophie.drawButton();

    saver.drawButton();
    //saver.updateMouse(mouseX, mouseY);
    enable.drawButton();

    connect.drawButton();
    test.drawButton();
    //enable.updateMouse(mouseX, mouseY);
    // background(currentColor);

    //if (rectOver) {
    //  fill(rectHighlight);
    //} else {
    //  fill(rectColor);
    //}
    //stroke(255);
    //rect(rectX, rectY, rectSize, rectSize);
  }

   {//title text
      fill(0);
      stroke(0);
      textSize(24);
      textAlign(LEFT);
      text("Light Recorder Deck", sliderOffset[0], 80);
      textSize(20);
      text("Charles Matthews 2019", sliderOffset[0], height - 64);
    }


  {//Draw and update sliders
    //Slider label - level with light on label?
    {
      fill(0);
      stroke(0);
      textSize(32);
      textAlign(LEFT);
      text("RGB", sliderOffset[0], sliderOffset[1] - 40);
    }
    for(int i = 0; i < 3; i++) {
      sliders[i].update();
      sliders[i].display();

      cBuffer[i] = PApplet.parseInt(map(PApplet.parseInt(sliders[i].getPos()), 38, 302, 0, 255));
      //println(cBuffer[0]);
      // println("slider " + i + " " + sliders[i].getPos());
    }

    if (testArray(cBuffer, sliderArray)) {
      OscMessage sliderMsg = new OscMessage("/rgb");
      for (int i = 0; i < 3; i++) {
        sliderMsg.add((cBuffer[i]));
        sliderArray[i] = cBuffer[i];
        println(sliderArray[0]);
      }
      oscP5.send(sliderMsg, puredata);
      //println(sliderMsg);
  }

    {//Send the OSC message from sliders
      if (saver.updateMouse(mouseX, mouseY)){
        oscP5.send(new OscMessage("/onoff").add(enable.checkFlag() ? 1 : 0), puredata);


        //println("got it: " + (buttonFlag[0] ? 1 : 0));
      }


    }
  }
}


public void saveArray(){
  JSONArray rgb = new JSONArray();
    for(int i = 0; i < 3; i++) {
      rgb.setInt(i, cBuffer[i]);

    }
    json.setJSONArray("rgb", rgb);
    saveJSONObject(json, "data/new.json");
    println("--------------saved--------------");
}

public boolean testArray(int[] myTestArray, int[] targetArray){//can I make a multipurpose abstraction?

  boolean value = false;
  for (int i = 0; i < myTestArray.length; i++){
    if (myTestArray[i] != targetArray[i]) {
      value = true;
    }
  }

  return value;

}

public void setScene(int scene) {
   oscP5.send(new OscMessage("/scene").add(scene), puredata);
}

public void mousePressed() {
  //this could be an array/for loop
  //for (int i = 0; i < 6; i++) {
  //  if (allButtons[i].updateMouse(mouseX, mouseY)) {
  //    setScene(i);
  //  }
  //}
   if (sun.updateMouse(mouseX, mouseY)) {
      setScene(2);
   } else if (back.updateMouse(mouseX, mouseY)) {
     setScene(3);
   } else if (bugs.updateMouse(mouseX, mouseY)) {
     setScene(4);
   } else if (sophie.updateMouse(mouseX, mouseY)) {
     setScene(5);
   } else if (colour.updateMouse(mouseX, mouseY)) {
     setScene(1);
   } else if (off.updateMouse(mouseX, mouseY)) {
     setScene(0);
   }
  if (saver.updateMouse(mouseX, mouseY)){
    saver.click();
    saveArray();
  }
  if (enable.updateMouse(mouseX, mouseY)){
   enable.toggle();
   oscP5.send(new OscMessage("/audio").add(enable.checkFlag() ? 1 : 0), puredata);
   println("toggle" + (enable.checkFlag() ? 1 : 0));
  }
  if (test.updateMouse(mouseX, mouseY)){
   test.toggle();
   oscP5.send(new OscMessage("/onoff").add(test.checkFlag() ? 1 : 0), puredata);
  }
  if (connect.updateMouse(mouseX, mouseY)){
   connect.click();
   oscP5.send(new OscMessage("/connect").add(1), puredata);
  }

}




class RoundButton {
  int rectX, rectY;      // Position of square button
  int circleX, circleY;  // Position of circle button
  int rectSize = 90;     // Diameter of rect  -- not needed atm!
  int circleSize = 45;   // Diameter of circle
  int rectColor, circleColor, baseColor;
  int rectHighlight, circleHighlight;
  int currentColor;
  boolean rectOver = false;
  boolean circleOver = false;
  int pressedColour = 0;
  boolean[] buttonFlag = {false, false};
  String type, label;

  RoundButton (String setType, int setCircleX, int setCircleY, String setLabel) {
    rectColor = color(0);
    rectHighlight = color(51);
    circleColor = color(255);
    circleHighlight = color(204);
    baseColor = color(102);
    currentColor = baseColor;
    circleX = setCircleX; //circleX = width/2+circleSize/2+10;
    circleY = setCircleY; //sliderOffset[1] + 64 * 2 + 32;//height/2;
    rectX = width/2-rectSize-10;
    rectY = height/2-rectSize/2;
    type = setType;
    label = setLabel;
    ellipseMode(CENTER);
  }

   public void drawButton(){//int pressedColour
    {//Light label - make this part of a button class/method
      fill(0);
      textSize(20);
      textAlign(CENTER);
      text(label, circleX, circleY - circleSize);
    }

    fill(150, 0, 150);
    ellipse(circleX, circleY, circleSize * 1.5f, circleSize * 1.5f);

    //if (circleOver) {
    //  fill((buttonFlag[0] ? 255 : 0));
    //} else {

    switch (type){
      case "toggle" : fill((buttonFlag[0] ? 255 : 0));
      break;
      case "button" : fill(pressedColour);
      break;
    }

    ellipse(circleX, circleY, circleSize, circleSize);
    if (pressedColour > 0) pressedColour -= 5;
  }

  public boolean updateMouse(int x, int y){//from Buttons
  if ( overCircle(circleX, circleY, circleSize) ) {
    circleOver = true;
    return true;
    //rectOver = false;
  } else if ( overRect(rectX, rectY, rectSize, rectSize) ) {
    //rectOver = true;
    //circleOver = false;
    return false;
  } else {
    circleOver = rectOver = false;
    return false;
  }
}
  public boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width &&
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
  }

  public void click(){
    if (circleOver) {
    currentColor = circleColor;
    //buttonFlag[0] = !buttonFlag[0];
    pressedColour = 255;
  }
  //if (rectOver) {
  //  currentColor = rectColor;
  //}
  }

  public boolean checkFlag(){
    return buttonFlag[0];
  }

  public boolean checkChanged(){
    return buttonFlag[0] != buttonFlag[1];
  }

  public boolean toggle(){ //I don't think I need this array for now
    buttonFlag[0] = !buttonFlag[0];
    buttonFlag[1] = buttonFlag[0];
    return buttonFlag[0]; //return buttonFlag[0] != buttonFlag[1];
  }

  public void setToggle(boolean input){
    buttonFlag[0] = input;
  }


public boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

}

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider --set these!
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  int bgcolor = color(0, 0, 0);

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

  public void setPos(int pos) {
    float mapped = map(pos, 0, 255, 38, 302); //need to set this range!!
    spos = mapped;
    newspos = mapped;
  }

  public void update() { //added x y from buttons


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

  public float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  public boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  public void setColor(int c) {
    bgcolor = c;
  }



  public void display() {
   stroke(0);
   strokeWeight(3);
   fill(bgcolor, 100);
   rect(xpos, ypos, swidth, sheight);
   // if (over || locked) {
   //   fill(0, 0, 0, 100);
   // } else {
     fill(bgcolor, 255);
   // }
   ellipse(spos+sheight/2, ypos+sheight/2, sheight * 1.5f, sheight * 1.5f);
 }

  public float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}
  public void settings() {  size(800, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "Workshop_GUI" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
