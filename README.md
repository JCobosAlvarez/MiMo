# MiMo: an open source package for Microglia Motility

**MiMo** is an open-source ImageJ macro designed as part of a comprehensive package for analyzing microglia motility. This package facilitates the preprocessing and analysis of multi-channel image stacks obtained from experiments related to microglial responses.

**Features**

- User-friendly Dialog Box: MiMo starts with a dialog box allowing users to specify input directories, processing parameters, and analysis options.
- Preprocessing Steps: Options include drift correction, spectral unmixing, removing outliers, Z-projecting, and more.
- Analysis Options: Choose from ROI multimeasure, cumulative area swept, and first-order differences analysis.
- Output: Results are saved in a structured output folder, including processed stacks, ROI sets, and analysis results.

**How to Use**

- Download and Install Fiji/ImageJ: Make sure you have Fiji or ImageJ installed on your system.
- Run MiMo: Open Fiji/ImageJ and run MiMo. The dialog box will guide you through the necessary input.
- Specify Input Directories: Provide paths for the red and green channel images, set parameters like Z-slices, timepoints, and pixel scale.
- Choose Processing Options: Select preprocessing and analysis options based on your experimental setup.
- Review Output: Processed stacks, ROIs, and analysis results are saved in an output folder.

**Further Analysis**

MiMo is designed to seamlessly integrate with additional scripts and analyses. Feel free to upload and combine MiMo's output results with other scripts for a more in-depth investigation into microglia motility.

**Dependencies**

- Fiji or ImageJ software
- Necessary plugins for spectral unmixing and drift correction

**Contributors**

- Juan Cobos
- Jonathan Draffin

**License**

This project is licensed under the MIT License - see the LICENSE.md file for details.
