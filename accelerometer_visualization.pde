import processing.serial.*;
import processing.opengl.*;
Serial myPort;
int baudRate = 9600;
int lf = 10;

PFont font;
int[] xAxis;
int[] yAxis;
int[] zAxis;

int currentX = 0;
int currentY = 0;
int currentZ = 0;
int oneGSensorValue = 400;
float oneGMillivolt = oneGSensorValue * 4.9;

int totalReadings = 400;
int readingPos = 0; // the reading position in the array

void setup(){
  smooth();
  size(600, 300, OPENGL); 

  font = createFont(PFont.list()[270], 24);
  smallFont();
  
  xAxis = new int[totalReadings];
  yAxis = new int[totalReadings];
  zAxis = new int[totalReadings];
  
  for (int i=0; i < totalReadings; i++){
    xAxis[i] = oneGSensorValue;
    yAxis[i] = oneGSensorValue;
    zAxis[i] = oneGSensorValue;
  }
  
  myPort = new Serial(this, Serial.list()[0], baudRate);
  myPort.bufferUntil(lf);
  
  noLoop();
}

void serialEvent(Serial p){
  String inString;
  
  try{
    inString = (myPort.readString());
    currentX = xValue(inString);
    currentY = yValue(inString);
    currentZ = zValue(inString);
    xAxis = insertValueIntoArray(xAxis, currentX, readingPos, totalReadings);
    yAxis = insertValueIntoArray(yAxis, currentY, readingPos, totalReadings);
    zAxis = insertValueIntoArray(zAxis, currentZ, readingPos, totalReadings);
    readingPos = readingPos + 1; // increment the array position
  }catch(Exception e){
   println(e);
  }
  redraw();
}

void draw()
{
  background(#FEFFFC);
  drawGraph(xAxis, 100, color(#519050), "X - Axis");  
  drawGraph(yAxis, 200, color(#708CDE), "Y - Axis");
  drawGraph(zAxis, 300, color(#D38031), "Z - Axis");
  draw3d(currentX, currentY, currentZ);
}

void drawGraph(int[] arrToDraw, int yPos, color graphColor, String name){
  int arrLength = arrToDraw.length;
  stroke(graphColor);
  for (int x=0; x<arrLength - 1; x++) {
    float normalizedLine = norm(arrToDraw[x], 0.0, 700.0);
    float lineHeight = map(normalizedLine, 0.0, 1.0, 0.00, 85.0);
    line(x, yPos, x, yPos - int(lineHeight));

  }
  pushStyle();
  smallFont();
  stroke(#FFFFFF);
  fill(#FFFFFF);
  String gString = nfc(gFromSensorValue(arrToDraw[arrLength - 2]), 2);
  text(name + " : " + gString + " Gs", 10, yPos - 10);
  popStyle();
}

void draw3d(int currentX, int currentY, int currentZ){
  float normalizedX = norm(currentX, 0.0, 700.0);
  float normalizedY = norm(currentY, 0.0, 700.0);
  float normalizedZ = norm(currentZ, 0.0, 700.0);
  float finalZ = map(normalizedZ, 0.0, 1.0, 300.00, 0.0);
  float finalY = map(normalizedY, 0.0, 1.0, -3.5, 3.5);
  float finalX = map(normalizedX, 0.0, 1.0, -3.5, 3.5);

  pushMatrix();
  ambientLight(102, 102, 102);
  lightSpecular(204, 204, 204);
  directionalLight(102, 102, 102, -1, -1, -1);
  shininess(1.0);
  translate(500, finalZ);
  rotateY(finalY + 1.0);
  rotateZ(finalX);
  fill(#E2E8D5);
  noStroke();
  fill(#B76F6F);
  float heightWidth = finalX * 1.8;
  box(65, 65, 50);
  popMatrix();
}

int xValue(String inString){
  int pipeIndex = inString.indexOf('|');
  return int(inString.substring(0,pipeIndex));
}

int yValue(String inString){
  int pipeIndex = inString.indexOf('|');
  int colonIndex = inString.indexOf(':');
  return int(inString.substring(pipeIndex+1, colonIndex)); 
  
}

int zValue(String inString){
  int colonIndex = inString.indexOf(':');
  return int(inString.substring(colonIndex + 1, inString.length() - 2));
}

int[] insertValueIntoArray(int[] targetArray, int val, int pos, int maxLength){
   if(pos > (maxLength-1)){
     // if the pos == maxSize, shift the array to retain the original value
     int[] returnArray = subset(targetArray, 1, maxLength-1);
     returnArray = expand(returnArray, maxLength);
     returnArray[maxLength-2] = val;
     return returnArray;
   }else{
     targetArray[pos] = val;
     return targetArray;
   }
}

float gFromSensorValue(int sensorValue){
  //convert analog value into a millivolts
  float mvValue = sensorValue * 4.9;
  return mvValue/oneGMillivolt;
}

void smallFont(){  textFont(font, 24); }
void mediumFont(){ textFont(font, 30); }
void largeFont(){  textFont(font, 40); }
