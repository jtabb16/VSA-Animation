/* Column
 * Author: Jack Tabb
 * Date: 20181016
 * Purpose: To handle the drawing and calculations dealing with a Column
*/

class Column {
  Table stateMatrix;
  double maxConc;
  
  int numCSTR;
  int numVarPerCSTR = 4; // 4 variables per CSTR: ThetaA, ThetaB, QA, QB
  float colorBar_width; // How wide to make a color bar
  float colorBar_height; // How tall to make a color bar
  
  /* Construct a Column */
  Column(Table stateMatrix) {
    println("Initializing Column...");
    this.stateMatrix = stateMatrix;
    
    TableRow concData = stateMatrix.getRow(0); // Get current timepoint's concentration data from all CSTRs
    numCSTR = concData.getColumnCount() / numVarPerCSTR; // Number of CSTRs to draw
    // colorBar_width = width/3/numVarPerCSTR;
    colorBar_width = width/3;
    colorBar_height = 3*(height/5)/numCSTR;
    
    println("Calculating max concentration...");
    maxConc = calcMaxConc(stateMatrix);
    println("Finished calculating max concentration: '" + maxConc + "'.");
    println("Finished Initializing Column.");
  }
  
  
  // NOTE: The Column shape is expected to be drawn with a command such as 'shape(s, 25, 25);' to let the user specify where he wants the column
  /* Draw a basic flow-diagram-distillation-column-esque thing */
  PShape drawColumn() {
    PShape column; // The PShape object that will be drawn to represent the entire column
    PShape colHead, colBody, colFoot; // The different parts that represent the column
    
    // Create the shape group for the column
    column = createShape(GROUP);
    
    noStroke(); // No outline on the column
    
    // Make the different parts of the column shape
    // Make the main body of the column
    rectMode(CENTER);
    colBody = createShape(RECT, 0, 0, width/3, 3*(height/5));
    colBody.setFill(color(255));
    
    // Make the top part of the column
    ellipseMode(CORNERS);
    colHead = createShape(ARC, -1*(width/3)/2, -2*(height/5), (width/3)/2, -1*(height/5), PI, 2*PI);
    colHead.setFill(color(255));
    
    //Make the bottom part of the column
    ellipseMode(CORNERS);
    colFoot = createShape(ARC, -1*(width/3)/2, 1*(height/5), (width/3)/2, 2*(height/5), 0, PI);
    colFoot.setFill(color(255));

    // Package the parts of the shape into one group shape
    column.addChild(colBody);
    column.addChild(colHead);
    column.addChild(colFoot);
    
    return column; // Return the shape to be drawn on screen
  }
  
  /* Fill the column according to the data at the specified timepoint */
  PShape drawColContentsConglomerate(int timepoint) {
    // Display the timepoint (We don't know the actual time. Just the timepoint)
    // TODO: Newer data files from the simulation do have the actual times at each timepoint. Need to incorporate this.
    textSize(32);
    fill(255);
    text("Timepoint: " + timepoint + " / " + stateMatrix.getRowCount(), 0, 30); // Display the current time point out of how many time points there are
    
    // Note: At this timepoint, we are looking at one row of the stateMatrix
    //       We are also assuming that there are 4 data columns for each CSTR
    
    TableRow concData = stateMatrix.getRow(timepoint); // Get current timepoint's concentration data from all CSTRs
    
    // The PShape object that, when drawn, represents the concentrations of the species in each CSTR
    PShape coloredCSTRs = new PShape(); // Array of CSTRs to draw
    coloredCSTRs = createShape(GROUP); // Each CSTR is a shape. Group them into this one shape.
    
    // TODO: You get a very different effect with noStroke, white stroke, and black stroke.
    //       They all show something different about the animation.
      noStroke();
    // stroke(0);
    
    for (int cstrIter = 0; cstrIter < numCSTR*numVarPerCSTR; cstrIter+=numVarPerCSTR) { // Iterate through all CSTR data
      // NOTE: The exact CSTR we are in is represented by cstrIter / numVarPerCSTR.
    
      // Calculate the total (fluid + solid phase) concentration of all components in this CSTR
      // Assuming the CSTR's data is structured as: (ThetaA, ThetaB, QA, QB) at positions (index of CSTR) + (0,1,2,3)
      //   Where Theta is fluid-phase conc and Q is solid-phase conc.
      // Also assuming we can look at just one component to determine the other component (xA + xB = 1).
      // Hard to come up with flexible way. Hard-coded 0,1,2,3 for now.
      double concA = concData.getDouble(cstrIter+0) + concData.getDouble(cstrIter+2);
      double concB = concData.getDouble(cstrIter+1) + concData.getDouble(cstrIter+3);
      
      // Factor to determine which color.
      // The more A there is, the closer the color should be to that side of the gradient.
      double colorScaleFactor1 = concA / (concA + concB);
      
      // Factor to determine how much color.
      // The color is scaled to a gradient determined by how close this concentration variable
      // is to the max concentration of any species at any timepoint in this system.
      // Find the ratio of (total sum concentration in this CSTR at this timepoint) to the (max total sum 
      //     concentration seen in the column at any timepoint).
      // The larger the ratio, the stronger the color (less faded (less white))
      double colorScaleFactor2 = (concA + concB) / maxConc;
      
      // The colors used to construct the gradient.
      color minColor = color(255); // White -- Provides a faded color appearance to construct a gradient out of
      color maxColorA = color(0,0,255); // Blue for Nitrogen
      color maxColorB = color(0); // Black for Methane (AKA Natural Gas)
     
      
      // Determine the color to use for this CSTR to represent its components
      // Looking at our scaling factor, No A means it's going to be the B color. No B means it's going to be the A color
      // Any values in between will be on a gradient that goes from blue to black.
      //                lerpColor(from,    , to       , factor between 0 and 1);
      color barColor1 = lerpColor(maxColorB, maxColorA, (float)colorScaleFactor1);
      // Looking at our scaling factor, we adjust how strong the color is based on how concentrated this CSTR is
      // relative to the most concentrated a CSTR ever is in this animation.
      // The paler the color (the less concentrated), the whiter it is on the gradient.
      color barColor2 = lerpColor(minColor, barColor1, (float)colorScaleFactor2);
      
      // Make this CSTR's contribution to the colorbar
      float colorBar_centerX = 0; // Position for center (left-to-right) of colorBar
      float colorBar_centerY = 4*(height/5) - (cstrIter/numVarPerCSTR)*(colorBar_height); // Position for center (top-to-bottom) of a colorBar
      rectMode(CENTER);
      
      PShape curCSTR = createShape(RECT, colorBar_centerX, colorBar_centerY, colorBar_width, colorBar_height); // Make the shape
      curCSTR.setFill(barColor2); // Apply the custom color
      coloredCSTRs.addChild(curCSTR); // Pack this CSTR shape into the overall list of CSTRs
    } // End iteration through all CSTR data
    return coloredCSTRs; // Return the shape to be drawn on screen
  }
  
  /* Calculate the max total concentration of all phases of all species seen in any CSTR at any timepoint. */
  private double calcMaxConc(Table stateMatrix) {
    double maxConc = 0;
    int numTimePts = stateMatrix.getRowCount();
    for (int timePt = 0; timePt < numTimePts; timePt++) { // Iterate through all rows (timepoints)
      for (int cstrIter = 0; cstrIter < numCSTR*numVarPerCSTR; cstrIter+=numVarPerCSTR) { // Iterate through all CSTRs
        double curTotalConc = 0; // Reset this value for each CSTR
        for (int comp = 0; comp < numVarPerCSTR; comp++) { // Iterate through all components / species in a CSTR
          curTotalConc += stateMatrix.getRow(timePt).getDouble(cstrIter+comp); // Sum up ThetaA, ThetaB, QA, QB
        } // End iteration through components
        if (curTotalConc > maxConc) {
          maxConc = curTotalConc;
        }
      } // End iteration through CSTRs
    } // End iteration through timepoints
    return maxConc;
  } // End calculation of max concentration
  
  /* Allow access to this instance variable from outside this class */
  public float getColorBarWidth() {
    return colorBar_width;
  }
  
  /* Allow access to this instance variable from outside this class */
  public float getColorBarHeight() {
    return colorBar_height;
  }
  
  /* Allow access to this instance variable from outside this class */
  public int getNumVarPerCSTR() {
    return numVarPerCSTR;
  }
}// End Column
