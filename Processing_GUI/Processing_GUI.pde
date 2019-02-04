//Light Recorder Deck for Raspberry Pi.
//Charles Matthews 2019
//GUI for OSC communication with Pure Data
//Run this in presentation mode

//Slider code based on example from the Processing Scrollbar example
//Buttons modified from the Processing Button example
//CC-BY-NC
//https://creativecommons.org/licenses/by-nc/4.0/

//JSON for settings
  JSONObject json;
  

// Buttons
  RoundButton saver, enable, connect;
 

  int[] dimensions = {800, 600};

  //boolean[] buttonFlag = {false, false};

  boolean showCursor = false;

  int[] sliderOffset = {32, 100};
// Faders
  HScrollbar hs1, hs2, hs3; //can I take these out?
  HScrollbar[] sliders = {hs1, hs2, hs3};

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
  
  

 

  //set up screen
    size(800, 600); //Size of my current RPi screen
    sliderOffset[1] = height / 3;
    // noStroke();
  {//Initialise buttons
    saver = new RoundButton("button", width/2, "Save");//work out a ratio for x position, add y
    enable = new RoundButton("toggle", width/2 + 120, "Audio");
    connect = new RoundButton("button", width/2 + 240, "Connect");
  }

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

void draw() {
  //background(180, 0, 100);
  if (!showCursor) noCursor(); //this shouldn't work in presentation mode, but seems to be fine!
  //HScrollbar[] sliders = {hs1, hs2, hs3}; //how to define this globally?

  background(color(sliders[0].getPos(), sliders[1].getPos(), sliders[2].getPos()));
  {//Draw buttons
    saver.drawButton();
    //saver.updateMouse(mouseX, mouseY);
    enable.drawButton();
    connect.drawButton();
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
      text("Light Recorder Deck", sliderOffset[0], height/12);
      textSize(20);
      text("Charles Matthews 2019", sliderOffset[0], height - height/12);
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

      cBuffer[i] = int(map(int(sliders[i].getPos()), 38, 302, 0, 255));
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


void saveArray(){
  JSONArray rgb = new JSONArray();
    for(int i = 0; i < 3; i++) {
      rgb.setInt(i, cBuffer[i]);
      
    }
    json.setJSONArray("rgb", rgb);
    saveJSONObject(json, "data/new.json");
    println("--------------saved--------------");
}

boolean testArray(int[] myTestArray, int[] targetArray){//can I make a multipurpose abstraction?
 
  boolean value = false;
  for (int i = 0; i < myTestArray.length; i++){
    if (myTestArray[i] != targetArray[i]) {
      value = true;
    }
  }

  return value;

}

void mousePressed() {
  if (saver.updateMouse(mouseX, mouseY)){
    saver.click();
    saveArray();
  }
  if (enable.updateMouse(mouseX, mouseY)){
   enable.toggle();
   oscP5.send(new OscMessage("/onoff").add(enable.checkFlag() ? 1 : 0), puredata);
   println("toggle" + (enable.checkFlag() ? 1 : 0));
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
  color rectColor, circleColor, baseColor;
  color rectHighlight, circleHighlight;
  color currentColor;
  boolean rectOver = false;
  boolean circleOver = false;
  int pressedColour = 0;
  boolean[] buttonFlag = {false, false};
  String type, label;
  
  RoundButton (String setType, int setCircleX, String setLabel) {
    rectColor = color(0);
    rectHighlight = color(51);
    circleColor = color(255);
    circleHighlight = color(204);
    baseColor = color(102);
    currentColor = baseColor;
    circleX = setCircleX; //circleX = width/2+circleSize/2+10;
    circleY = sliderOffset[1] + 64 * 2 + 32;//height/2;
    rectX = width/2-rectSize-10;
    rectY = height/2-rectSize/2;
    type = setType;
    label = setLabel;
    ellipseMode(CENTER);
  }
  
   void drawButton(){//int pressedColour
    {//Light label - make this part of a button class/method
      fill(0);
      textSize(32);
      textAlign(CENTER);
      text(label, circleX, circleY - circleSize);
    }
    
    fill(150, 0, 150);
    ellipse(circleX, circleY, circleSize * 1.5, circleSize * 1.5);

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
  
  boolean updateMouse(int x, int y){//from Buttons
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
  boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width &&
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
  }
  
  void click(){
    if (circleOver) {
    currentColor = circleColor;
    //buttonFlag[0] = !buttonFlag[0];
    pressedColour = 255;
  }
  //if (rectOver) {
  //  currentColor = rectColor;
  //}
  }
  
  boolean checkFlag(){
    return buttonFlag[0];
  }
  
  boolean checkChanged(){
    return buttonFlag[0] != buttonFlag[1];
  }
  
  boolean toggle(){ //this doesn't currently make sense
    buttonFlag[0] = !buttonFlag[0];
    buttonFlag[1] = buttonFlag[0];
    return buttonFlag[0]; //return buttonFlag[0] != buttonFlag[1];
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
  
  void setPos(int pos) {
    float mapped = map(pos, 0, 255, 38, 302); //need to set this range!! 
    spos = mapped;
    newspos = mapped;
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
