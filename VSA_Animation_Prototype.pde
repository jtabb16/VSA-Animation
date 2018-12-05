/* VSA_Animation_Prototype
 * Author: Jack Tabb
 * Date: 20181016
 * Purpose: Provide an animation for a PSA process by drawing the concentrations of species in a column over time.
 * Note: setup() and draw() automatically run.
 *       -- setup() runs once. 
 *       -- draw() runs indefinitely at the specified frameRate
*/

/* Define global variables used in animation */
Table stateMatrix; // Load all data into a table from a CSV file
int numTimePts; // The number of time points is the number of rows in the data file
int timepoint; // Current timepoint the animation is working with
Column column01; // The column on display for the animation
GUI_Panel gui;

/* Set up the animation */
void setup() {
  println("Welcome to the Animation!");
  // The size of the window is fixed. 
  // The user can change this source code to change size of window.
  // All drawings will be based on this size, but should work for other sizes.
  // size(768, 432); // A 16:9 aspect ratio size for the window
  // size(500, 600);
  size (700, 700);
  
  // Set the speed to play the animation to make it easier to see what is happening
  // Note: You won't see a difference past a certain point because your processor 
  //        isn't fast enough to output frames above a certain rate.
  frameRate(10); // 1 frame per second, 60fps, 1000fps, etc. Let the user choose.
  
  // Initialize the global variables
  // TODO: Integrate this application with Google Drive API to access the data so that not all of the data has to be kept locally
  println("Loading Data...");
  //stateMatrix = loadTable("data/LiClinoStateMatrixData.csv");
  stateMatrix = loadTable("data/Ba-ETS-4_Simulation Data_20181016_Taehun Kim_v1.csv");
  println("Finished Loading Data.");
  numTimePts = stateMatrix.getRowCount();
  timepoint = 0;
  column01 = new Column(stateMatrix);
  
  // Construct the GUI
  gui = new GUI_Panel(this); // In this case, "this" is the PApplet for this animation
}

/* Run the animation */
void draw() {
  background(0); // Black background
  
  // Draw the column
  shape(column01.drawColumn(), width/2, height/2);
  
  // Draw the current state of the column at this timepoint
  shapeMode(CENTER);
  
  // int numVarPerCSTR = column01.getNumVarPerCSTR();
  // float cBarW = column01.getColorBarWidth();
  float cBarH = column01.getColorBarHeight();
  // float xCoord = width/2 + cBarW/2 - (numVarPerCSTR*cBarW)/2;
  float xCoord = width/2;
  float yCoord = 0 - (cBarH)/2;
  // shape(column01.drawColContents(timepoint), xCoord, yCoord) ;
  shape(column01.drawColContentsConglomerate(timepoint), xCoord, yCoord) ;
  
  // Establish the current timepoint.
  timepoint++;
  timepoint = (timepoint % numTimePts); // Cycle back to the beginning timepoint when necessary
  
  // Draw the positioning grid
  // stroke(255);
  // drawGrid(5, 3); // The width is split into thirds. The height is split into fifths
  
  // Save this animation to be able to share it:
  // saveFrame("frames/####.png");
}

/* Draw positioning grid */
void drawGrid(int numRows, int numCols) {
  for (int x = 1; x < numRows; x++) {
    line(0, x*(height/numRows), width, x*(height/numRows));
  }
  for (int x = 1; x < numCols; x++) {
    line(x*(width/numCols), 0, x*(width/numCols), height);
  }
}
