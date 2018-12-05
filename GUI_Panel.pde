/* GUI_Panel
 * Author: Jack Tabb
 * Date: 20181015
 * Purpose: To handle the drawing and event-listening for the Graphical User Interface (GUI) Elements
*/

import g4p_controls.*; // Import library For GUI elements: buttons, label, slider

// Declare the GUI Elements:
// Sliders for dragging to select values
GCustomSlider timeSldr,
              // Note: Too low of a speed value makes it hard to use the GUI because this speed also effects how fast the GUI responds to input.
              speedSldr; 
// Button to pause or play the animation.
GButton playPauseBtn;
// Labels for the sliders
GLabel timeLbl,
       speedLbl;

class GUI_Panel {
  
  // Construct the GUI_Panel in the Parent PApplet
  GUI_Panel(PApplet parent) {
    setupGUI(parent);
  }

  public void setupGUI(PApplet parent) {
    // Setup GUI
    //=============================================================
    // 'Parent applet', x-coord of top left corner, y-coord of top left corner, width, height
    speedSldr = new GCustomSlider(parent, 0, 2*height/3, width/3, 50, null);    
    // show                opaque  ticks value limits
    speedSldr.setShowDecor(false, true, true, true);
    speedSldr.setNbrTicks(5);
    speedSldr.setLimits(10, 1, 300);
    speedSldr.setLocalColorScheme(15); // white color scheme
    speedLbl = new GLabel(parent, 0, 2*height/3-30, width/3, 50);
    speedLbl.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    speedLbl.setText("Speed [FPS]");
    speedLbl.setOpaque(false);
    speedLbl.setLocalColorScheme(15);
    
    timeSldr = new GCustomSlider(parent, 0, 2*height/3 + 60, width/3, 50, null);
    timeSldr.setShowDecor(false, true, true, true);
    timeSldr.setNbrTicks(5);
    timeSldr.setLimits(0, 0, numTimePts-1);
    timeSldr.setLocalColorScheme(15);
    timeLbl = new GLabel(parent, 0, 2*height/3 + 60-30, width/3, 50);
    timeLbl.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    timeLbl.setText("Timepoint");
    timeLbl.setOpaque(false);
    timeLbl.setLocalColorScheme(15);
    
    playPauseBtn = new GButton(parent, 0, 2*height/3 + 2*60, width/3, 50, "Pause");
    playPauseBtn.tag = "Pause";
    playPauseBtn.setLocalColorScheme(15); // White theme
    playPauseBtn.setLocalColor(2, color(0)); //Black Text
    //=============================================================
  }
}

public void handleButtonEvents(GButton button, GEvent event) {
  if (button == playPauseBtn) {
    // If the user clicked on the play button, meaning the animation was paused
    if (playPauseBtn.tag == "Play") {
      loop();
      playPauseBtn.tag = "Pause";
      playPauseBtn.setText("Pause");
    } else { // If the user clicked on the pause button, meaning the animation was playing
      noLoop();
      playPauseBtn.tag = "Play";
      playPauseBtn.setText("Play");
    }
  } else {
    println("ERROR: Unrecognized button event detected.");
  }
  redraw();
}

public void handleSliderEvents(GValueControl slider, GEvent event) {
  if (slider == speedSldr) {
    frameRate(slider.getValueI());
  } else if (slider == timeSldr) {
    timepoint = slider.getValueI();
  } else {
    println("ERROR: Unrecognized slider event detected.");
  }
  redraw();
}
