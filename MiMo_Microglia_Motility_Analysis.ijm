// Dialog box for user
Dialog.create("Image processing options");
Dialog.addDirectory("Channel 1 (red) images", "C:\\Users\\Juan\\Tonnesen Lab\\ImageJ processing\\Osmotic challenge\\11 month old hz shadow imaging\\Slice 1 - osmotic challenge\\UR");
Dialog.addDirectory("Channel 2 (green) images", "C:\\Users\\Juan\\Tonnesen Lab\\ImageJ processing\\Osmotic challenge\\11 month old hz shadow imaging\\Slice 1 - osmotic challenge\\UG");
Dialog.addNumber("Z-slices: ", 0);
Dialog.addNumber("Number of timepoints: ", 0);
Dialog.addNumber("Scale um per pixel: ", 1);
Dialog.addCheckbox("Make subset of hyperstack", false);
Dialog.addMessage("Note: if z-slices or timepoints = 0, all are processed");
Dialog.addChoice("Channel", newArray("Red", "Green", "Both"), "Both");
Dialog.addMessage(" PREPROCESSING:");
Dialog.addCheckbox("Open images from path and create hyperstack", true);
Dialog.addCheckbox("Spectral unmixing", false);
Dialog.addCheckbox("3D drift-correction", true);
Dialog.addCheckbox("Remove outliers", false);
Dialog.addCheckbox("Z-project", true);
Dialog.addCheckbox("Remove black edges", false);
//Dialog.addCheckbox("Subtract background", true);
Dialog.addCheckbox("Binarise image", false);
Dialog.addCheckbox("Draw ROIs", true);
Dialog.addMessage("Note: if either of the last two options is not selected, please make sure a processed stack (and no other image) is open \nand/or a ROI set saved to the \"Processed stack\" folder before the macro is run");
Dialog.addMessage("ANALYSIS:\n ");
Dialog.addCheckbox("ROI multimeasure", true);
Dialog.addCheckbox("Cumulative area swept", false);
Dialog.addCheckbox("First order differences", false);
Dialog.show();

redPath = Dialog.getString();
greenPath = Dialog.getString();

//Get user input values

s = Dialog.getNumber(); //Assign user input z planes
t = Dialog.getNumber(); //Assign user input to timepoints variable
pw = Dialog.getNumber(); //User-defined pixel width

scale = 1 / pw;

subset = Dialog.getCheckbox();

//mixingMatrixPath = "C:\\Users\\jonny\\Tonnesen Lab Data\\Fiji.app\\plugins\\Mixing matrix files\\Mixing Matrix_3pc-laser_80pc_UG_80pc_UR_1uM-luciferase.txt"
open_images = Dialog.getCheckbox();
spectralUnmixing = Dialog.getCheckbox();
drift_correction = Dialog.getCheckbox();
remove_outliers = Dialog.getCheckbox();
project = Dialog.getCheckbox();
rm_black_edges = Dialog.getCheckbox()
//subtract_bg = Dialog.getCheckbox();
binarise_analysis = Dialog.getCheckbox();
createROIs = Dialog.getCheckbox();

if (t == 0) {
  array = getFileList(redPath);
  array_filtered = Array.filter(array, ".tif");
  t = array_filtered.length;
}

channel = Dialog.getChoice(); //Assign user input to channel variable

//Analysis options

ROIMultimeasure = Dialog.getCheckbox();
cumulativeAreaSwept = Dialog.getCheckbox();
firstOrderDifferences = Dialog.getCheckbox();

if (ROIMultimeasure == false && cumulativeAreaSwept == false && firstOrderDifferences == false) {
  analysis = false;
} else {
  analysis = true;
}

//Create output folder and parse input folder
if (channel == "Red") {
  output_dir = redPath + "\\Processed stack\\";
} else {
  output_dir = greenPath + "\\Processed stack\\";
}

if (!File.exists(output_dir)) {
  File.makeDirectory(output_dir);
}

// Enable extraction of folder name from filename for purposes of file naming
folder = File.getParent(output_dir);
folder = File.getParent(folder);
folder = File.getParent(folder);
folder_name = File.getName(folder);

//folder = split(output_dir,"\\"); // Enable extraction of folder name from filename for purposes of file naming
//folder_name = "_"+folder[6]+"_"+folder[7];

function sc_raw_images(path) { //Single channel raw images
  run("Image Sequence...", "open=&path sort number=t starting=1 increment=1 scale=100 file=tif");
  if (s == 0) {

    s = nSlices / t;
  }
  run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=s frames=t display=Color");

  return s;
}

function dc_raw_images(red_path, green_path) { // Double channel raw images
  run("Image Sequence...", "open=&red_path sort number=t starting=1 increment=1 scale=100 file=tif");
  rename("red.tif");
  run("Image Sequence...", "open=&green_path sort number=t starting=1 increment=1 scale=100 file=tif");
  rename("green.tif");

  if (s == 0) {
    s = nSlices / t;
    print("z-slices: ", s);
    print("time points: ", t);
    print("nslices: ", nSlices);
  }
  return s;
}

function mixingMatrix() {
  mixingMatrixPath = File.openDialog("Select mixing matrix file");
  run("Unmix ", "ch_1=red.tif ch_2=green.tif open=[" + mixingMatrixPath + "]");
  run("Concatenate...", "  image1=[Fluor 1] image2=[Fluor 2] image3=[-- None --]");
}

function getResults(path) {
  run("Clear Results");
  selectWindow(path);
  run("Set Measurements...", "area mean min integrated area_fraction redirect=None decimal=3");
  roiManager("Select All");
  roiManager("Multi Measure");
}

function cumulative_stack(title) {
  Stack.getDimensions(width, height, channels, slices, frames);
  if (channels == 2) {
    run("Split Channels");
    close("*C1*");
  }
  title = getTitle();
  current_stack = title;
  for (i = 1; i <= frames; i++) {
    selectWindow(title);
    setSlice(i);
    img_1 = getTitle();
    imageCalculator("OR create", img_1, current_stack);
    rename("cumulative_" + i);
    current_stack = getTitle();
  }
  close(title);
  run("Images to Stack");
}

function first_order_differences(path) {
  open(path);
  Stack.getDimensions(width, height, channels, slices, frames);
  if (channels == 2) {
    run("Split Channels");
    close("C1*");
  }
  for (i = 1, j = 2; i < frames; i++, j++) {
    selectWindow(mask_stack);
    setSlice(i);
    run("Duplicate...", " ");
    tp_1 = getTitle();
    selectWindow(mask_stack);
    setSlice(j);
    run("Duplicate...", " ");
    tp_2 = getTitle();

    imageCalculator("XOR create", tp_2, tp_1);
    rename("fod_" + i);
    close(tp_1);
    close(tp_2);
  }

  close(mask_stack);
  run("Images to Stack");
}

if (createROIs == true) {
  ROIpath = output_dir + "MASK_drift_corrected_MAX_stack_" + folder_name + "_ROIset.zip";
} else if (analysis == true) {
  ROIpath = File.openDialog("Select a ROI set");
}

//Open images from path and create hyperstack
if (open_images == true) {
  if (channel == "Both") {
    s = dc_raw_images(redPath, greenPath);
    getPixelSize(unit, pw, ph, pd);
    scale = 1 / pw;

    if (spectralUnmixing == true) {
      mixingMatrix();
    }
    else {
      run("Concatenate...", "  image1=[red.tif] image2=[green.tif] image3=[-- None --]");
    }

    run("Stack to Hyperstack...", "order=xyztc channels=2 slices=s frames=t display=Color");
    close("\\Others");
  }
  else {
    if (channel == "Red") {
      s = sc_raw_images(redPath);
    }

    if (channel == "Green") {
      s = sc_raw_images(greenPath);
    }

    getPixelSize(unit, pw, ph, pd);
    scale = 1 / pw;
  }
}

//Set Z range
if (subset) {
  run("Make Subset...");
  close("\\Others");
}

// Correct 3D drift
if (drift_correction == true) {

  Stack.getDimensions(width, height, channels, slices, frames);
  run("Correct 3D drift", "channel=" + channels + " only=0 lowest=1 highest=slices max_shift_x=300.000000000 max_shift_y=300.000000000 max_shift_z=30.000000000");
  Stack.getDimensions(width, height, channels, slices, frames);

  saveAs("Tiff", output_dir + "drift_corrected_hyperstack_RAW");

  // Remove any z-slices containing blank frames introduced by Correct 3D Drift
  for (i = 1; i < slices; i++) {
    Stack.setPosition(1, i, 0);
    for (j = 1; j <= frames; j++) {
      Stack.setPosition(1, i, j);
      run("Measure");
      intensity = getResult("Max", 0);
      if (intensity == 0) {
        run("Delete Slice", "delete=slice");
        i = i - 1;
        run("Clear Results");
        break;
      }
      run("Clear Results");
    }
  }
  saveAs("Tiff", output_dir + "drift_corrected_hyperstack");
}

close("\\Others");

// Remove noise
if (remove_outliers) {
  run("Remove Outliers...", "radius=2 threshold=50 which=Bright stack");
}

// Z project
if (project) {
  run("Z Project...", "projection=[Max Intensity] all");

  MAX_drift_corrected_hyperstack = getTitle();
  saveAs("Tiff", output_dir + MAX_drift_corrected_hyperstack);
  close("\\Others");

}

// Remove black edges
if (rm_black_edges) {
  run("Autocrop Black Edges");
  close(MAX_drift_corrected_hyperstack);
}

// Remove background
//if (subtract_bg){
//run("Subtract Background...", "rolling=50 stack");
//}

// Save with this name only when cleaning the image
//clean_MAX_drift_corrected_hyperstack = "clean_MAX_drift_corrected_hyperstack"+folder_name+".tif";
//saveAs("Tiff", output_dir+clean_MAX_drift_corrected_hyperstack);
//print("Clean drift-corrected MAX hyperstack saved!");

//Binarise
if (binarise_analysis) {
  //selectWindow(MAX_drift_corrected_hyperstack);
  run("Threshold...");
  run("Convert to Mask", "method=Li background=Dark calculate create");
  mask_hyperstack = getTitle();
  saveAs("Tiff", output_dir + mask_hyperstack);
  close("\\Others");
}

if (analysis == true) {
  run("ROI Manager...");
  n = roiManager("count");

  if (n != 0) {
    run("Select All");
    roiManager("Delete");
  }


  if (!createROIs) {

    roiManager("Open", ROIpath);
    roiManager("Select", 1);
    run("Select All");
  }
  else {

    //Ask user to define ROIs
    title = "ROI Selection";
    msg = "Please select and add all desired ROIs, then click \"OK\".";
    waitForUser(title, msg);
    roiManager("Select", 0);
    run("Select All");
    roiManager("Save", ROIpath);
  }
}

//Analysis
mask_hyperstack = getTitle();
run("Set Scale...", "distance=" + scale + " known=1 unit=um global");


mask_stack = getTitle();
stack_path = output_dir + mask_stack;
saveAs("Tiff", stack_path);

//Measure timestack for all ROIs
if (ROIMultimeasure) {
  getResults(mask_hyperstack);
  timestack_results = output_dir + "timestack_multimeasure_" + folder_name + ".csv";
  saveAs("Results", timestack_results);
  print("ROI multimeasure results saved!");
}

// Cumulative area
if (cumulativeAreaSwept) {
  cumulative_stack(mask_stack);

  cumulative_path = output_dir + "cumulative_Area_" + folder_name + ".tif";
  saveAs("Tiff", cumulative_path);
  cumulative_area = getTitle();

  // Cumulative area results
  getResults(cumulative_area);
  cumulative_results = output_dir + "cumulative_" + folder_name + ".csv";
  saveAs("Results", cumulative_results);
  print("Cumulative ROI multimeasure results saved!");
  close("*"); // Close all images windows
}

// First order differences stack
if (firstOrderDifferences) {
  first_order_differences(stack_path);
  fods_path = output_dir + "fods_" + mask_stack;
  saveAs("Tiff", fods_path);
  fods_stack = getTitle();

  // First order differences results
  getResults(fods_stack);
  fods_results = output_dir + "firstorderdifferences_" + folder_name + ".csv";
  saveAs("Results", fods_results);
  print("First order differences ROI multimeasure results saved!");
  close("*"); // Close all images windows
}
