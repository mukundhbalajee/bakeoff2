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

float heightMid = 400;
float widthMid = 500;
boolean size = false;
boolean orientation = false;
boolean location = false;
boolean logoMoving = false;
boolean bg_color = false;
float prevMouseX;
float prevMouseY;
float submitButtonWidth = 100; // width
float submitButtonHeight = 25; // height
float submitButtonX;
float submitButtonY;
float stepIndicatorX;
float stepIndicatorY;
float stepIndicatorWidth = 200;
float stepIndicatorHeight = 50;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 400;
float logoZ = 100f;
float logoRotation = 0;

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
  println(submitButtonWidth);
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches
  
  submitButtonX = width/2;
  submitButtonY = inchToPix(.3f) + (submitButtonHeight/2);
  stepIndicatorX = width / 2;
  stepIndicatorY = inchToPix(1.5f);
  
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

  if (bg_color == false) {
    background(40); //background is dark grey
  } else {
    background(0,255,0);
  }
  fill(200);
  noStroke();
  
  //Test square in the top left corner. Should be 1 x 1 inch
  //rect(inchToPix(0.5), inchToPix(0.5), inchToPix(1), inchToPix(1));

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
  translate(logoX, logoY); //translate draw center to the center of the logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();
  heightMid = logoY;
  widthMid = logoX;
  //===========DRAW EXAMPLE CONTROLS=================
  if((size == false || orientation == false) && bg_color)
  {
    // Draw the submit button
    fill(200); // Button color
    //submitButtonX=mouseX;
    //submitButtonY=mouseY;
    if (mouseX > submitButtonX-(submitButtonWidth/2) && mouseX < submitButtonX + (submitButtonWidth/2) &&
        mouseY > submitButtonY-(submitButtonHeight/2) && mouseY < submitButtonY + (submitButtonHeight/2)) {
      fill(150); // Button hover color
    }
    rect(submitButtonX, submitButtonY, submitButtonWidth, submitButtonHeight);
    fill(0);
    text("Submit", submitButtonX, submitButtonY+10);
  }
  drawStepIndicator();
  fill(255);
  scaffoldControlLogic();
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(1f));
}

public boolean inSubmit() {
  return ((size == false || orientation == false) && bg_color) && (mouseX > submitButtonX-(submitButtonWidth/2) && mouseX < submitButtonX + (submitButtonWidth/2) &&
         mouseY > submitButtonY-(submitButtonHeight/2) && mouseY < submitButtonY + (submitButtonHeight/2) && (!size || !orientation));
}  

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  if (size == false && mouseY > inchToPix(.8f) && mousePressed ) {
    if (mouseY > heightMid) 
      logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!
    else 
      logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!
  } else if (size == true && orientation == false && mouseY > inchToPix(.8f) && mousePressed){
    if(mouseX < widthMid)
      logoRotation--;
    else
      logoRotation++;
  } else if (size == true && orientation == true && location == false) {
    logoY = max(inchToPix(.8f)+(logoZ/2),mouseY);
    logoX = mouseX;
  }
  stepSuccessCheck();
}

public void drawStepIndicator() {
  String curr_step="";
  Destination d = destinations.get(trialIndex);  
  if(!size)
  {
    if(logoZ < d.z)
      curr_step = "Increase size";
    else
      curr_step = "Decrease size";
  }
  else if(!orientation)
  {
    float diff = (abs(d.rotation-logoRotation) % 90);
    if(diff<45) 
      curr_step = "Rotate Clockwise";
    else
      curr_step = "Rotate Counter-Clockwise";
  }
  else if(!location)
    curr_step = "Move box";
  else
    curr_step = "HIT SUBMIT";
  fill(100);
  rect(stepIndicatorX, stepIndicatorY, stepIndicatorWidth, stepIndicatorHeight);
  fill(0); // Set color for text
  text(curr_step, stepIndicatorX, stepIndicatorY+7);
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
  // Check if the click is within the button's area
  if (mouseX > submitButtonX-(submitButtonWidth/2) && mouseX < submitButtonX + (submitButtonWidth/2) &&
      mouseY > submitButtonY-(submitButtonHeight/2) && mouseY < submitButtonY + (submitButtonHeight/2) && (!size || !orientation)) {
    if (size == false) 
      size = true;
    else if (orientation == false) 
      orientation = true;
    } else if (size == true && orientation == true && location == false)
    {
      location = true; println("ENTERED");
      // Perform the action for the submit button
      if (userDone==false && !checkForSuccess())
      {
        errorCount++;
        println("ERROR");
      }
      size = false;
      orientation=false;
      location=false;
      trialIndex++; //and move on to next trial
  
      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      }
    bg_color = false;
  }
}

public void stepSuccessCheck()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  
  if (!closeZ && !size)
  {
    bg_color = false;
    size = false;
  } else if(closeZ && !size)
    bg_color = true;
  else if (!closeRotation && !orientation && size)
  {
    orientation = false;
    bg_color = false;
  } else if(closeRotation && !orientation && size)
    bg_color = true;
  else if (!closeDist && !location && (size && orientation))
  {
    location = false;
    bg_color = false;
  } else if (closeDist && !location && (size && orientation))
    bg_color = true;
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

  return closeZ && closeRotation && closeDist;
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
