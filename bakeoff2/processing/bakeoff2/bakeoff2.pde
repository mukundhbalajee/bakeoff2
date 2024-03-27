import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 10; //WILL BE MODIFIED FOR THE BAKEOFF
 //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 1.0f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 128; //PPI for 2021 Macbook Pro 14" screen
//you can test this by drawing a 128x128 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;
float diagonalX1 = 500;
float diagonalY1 = 500;
float diagonalX2;
float diagonalY2;


int stage = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  println("creating "+trialCount + " targets");
  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {
  background(40); //background is dark grey
  if (stage == 0) {
    diagonalX1 = mouseX-1;
    diagonalY1 = mouseY-5;
    if (checkCorner(diagonalX1, diagonalY1)) {
      background(0, 200, 0);
    } else {
      background(50, 0, 0);
      drawTarget(mouseX, mouseY);
    }
  }
  if (stage == 1) {
    logoZ = (float) Math.sqrt((Math.pow(mouseX - diagonalX1, 2) + Math.pow(mouseY - diagonalY1, 2))/2);
    logoRotation = (float) Math.toDegrees(Math.atan2(diagonalY1 - mouseY, diagonalX1 - mouseX)) + 135;
    logoX = (diagonalX1 + mouseX) / 2;
    logoY = (diagonalY1 + mouseY) / 2;
    if (checkAllQuiet()) {
      background(0, 200, 0);
    } else {
      background(50, 0, 0);
      drawTarget(mouseX, mouseY);
    }
  }
  drawButton();


 
  fill(200);
  noStroke();
  
  //Test square in the top left corner. Should be 1 x 1 inch
  // rect(inchToPix(0.5), inchToPix(0.5), inchToPix(1), inchToPix(1));

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    
    rotate(radians(d.rotation)); //rotate around the origin of the Ddestination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(diagonalX1, diagonalY1); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rectMode(CORNER);
  rect(0, 0, logoZ, logoZ);
  rectMode(CENTER);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

void mouseReleased()
{
  if (stage == 0) {
    if (mouseX > 0 && mouseX < 100 && mouseY > 25 && mouseY < 75) {
      return;
    }
    if (!checkCorner(diagonalX1, diagonalY1)) {
      fill(255, 0, 0); // Red color for the button when not at desired location
    }
    stage = 1;
  } else {
    if (mouseX > 0 && mouseX < 100 && mouseY > 25 && mouseY < 75) {
      stage = 0;
      logoZ = 70f;
      return;
    }
    //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
    logoX = (diagonalX1 + mouseX) / 2;
    logoY = (diagonalY1 + mouseY) / 2;

    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
    
    stage = 0;
  }
}

boolean checkCorner(float x, float y) {
  if( trialIndex >= trialCount ){
    return false;
  }
  Destination d = destinations.get(trialIndex);  
  float halfWidth = (float) Math.sqrt(2) * (d.z / 2);
  float radians1 = (float) Math.toRadians(d.rotation + 45);
  float radians2 = (float) Math.toRadians(d.rotation - 45);
  float offsetX1 =  halfWidth * (float) Math.cos(radians1);
  float offsetY1 =  halfWidth * (float) Math.sin(radians1);
  float offsetX2 =  halfWidth * (float) Math.cos(radians2);
  float offsetY2 =  halfWidth * (float) Math.sin(radians2);

  // ellipse(d.x - offsetX1, d.y - offsetY1, 10, 10);
  // ellipse(d.x + offsetX1, d.y + offsetY1, 10, 10);
  // ellipse(d.x - offsetX2, d.y - offsetY2, 10, 10);
  // ellipse(d.x + offsetX2, d.y + offsetY2, 10, 10);
  boolean close1 = dist(d.x - offsetX1, d.y - offsetY1, x, y)<inchToPix(.1f);
  boolean close2 = dist(d.x - offsetX2, d.y - offsetY2, x, y)<inchToPix(.1f);
  boolean close3 = dist(d.x + offsetX2, d.y + offsetY2, x, y)<inchToPix(.1f);
  boolean close4 = dist(d.x + offsetX1, d.y + offsetY1, x, y)<inchToPix(.1f);

  return close1 || close2 || close3 || close4;
}

boolean checkAllQuiet() {
  if (trialIndex >= trialCount){
    return false;
  } 
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  
  return closeDist && closeRotation && closeZ;
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}

void drawTarget(float x, float y) {
  noFill();
  stroke(255, 100, 0); // Red color for the circle
  strokeWeight(2);
  float circleRadius = inchToPix(0.05f); // Adjust the size of the circle as needed
  ellipse(x, y, circleRadius * 2, circleRadius * 2); // Draw a circle around the target corner
}

void drawButton() {
  if (stage == 1 && !checkCorner(diagonalX1, diagonalY1)) {
    background(190,0,0);
    fill(255, 0, 0); // Red color for the button when not at desired location
  } else {
    fill(150); // Grey color for the button by default
  }
  rectMode(CENTER);
  rect(50, 50, 100, 50); 
  fill(255);
  textAlign(CENTER, CENTER);
  text("Reset", 50, 50);
}
