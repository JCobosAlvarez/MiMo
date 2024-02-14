# MiMo: an open-source package for Microglia Motility

**MiMo** is an open-source ImageJ/Fiji macro designed as part of a comprehensive package for analyzing microglia motility. This package facilitates the preprocessing and analysis of multi-channel image stacks obtained from experiments related to microglial dynamics.

**Features**

- User-friendly dialog box: MiMo starts with a dialog box allowing users to specify input directories, processing parameters, and analysis options.
- Preprocessing Steps: Options include drift correction, spectral unmixing, removing outliers, Z-projecting, and more.
- Analysis Options: Choose from ROI multimeasure, cumulative area swept, and first-order differences analysis.
- Output: Results are saved in a structured output folder, including processed stacks, ROI sets, and analysis results.

**How to Use**

- Download and install Fiji/ImageJ: Make sure you have Fiji or ImageJ installed on your system.
- Run MiMo: Open Fiji/ImageJ and run MiMo. The dialog box will guide you through the necessary input.
- Specify Input Directories: Provide paths for the red and green channel images, set parameters like Z-slices, timepoints, and pixel scale.
- Choose Processing Options: Select preprocessing and analysis options based on your experimental setup.
- Review Output: Processed stacks, ROIs, and analysis results are saved in an output folder.

**Further Analysis**

MiMo seamlessly integrates with Python scripts designed to traverse through folders and automatically detect output filenames. This streamlined process facilitates the creation and analysis of comprehensive Excel sheets containing all the results. By combining MiMo's output with the attached Python script, you can generate correspondent results ready to plot.

**Dependencies**

- Fiji or ImageJ software
- Necessary plugins for spectral unmixing and drift correction

**Contributors**

- Juan Cobos
- Jonathan Draffin

**License**

This project is licensed under the MIT License - see the LICENSE.md file for details.
