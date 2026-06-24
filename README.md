# Soft Soil Random Field Workflow for Abaqus — Detailed Operation Guide

## Prerequisites
Three categories of required software must be installed on your computer before use:
- **Python 3**: Version 3.8 or above is recommended. Select the option to add Python to the system PATH during installation.
- **MATLAB**: Any recent official release with support for basic numerical computation and plotting functions.
- **Abaqus**: Equipped with Standard and Explicit solver modules for subsequent numerical analysis.

## File Organization
Create a working folder with an all-English name (e.g., `soft_soil_workflow`) on a non-system drive of your computer. Move all script files from the repository into this folder, including `randomfile2.py`, `midpoint_RF.m`, `importrandomdata_V4.m`, and `generateINP.m`.

Store all subsequent data files in this same folder. Ensure the folder path contains no Chinese characters or spaces to avoid file reading failures during script execution.

## Step 1: Run randomfile2.py to Generate Base Abaqus Input File Templates
This step builds the basic framework of the Abaqus model, presets fundamental information such as model dimensions and element meshing, and generates `.inp` format template files for use in subsequent steps.

### Operation procedure
1. Open the Command Prompt window. For Windows systems, press the `Win+R` key combination, enter `cmd` in the pop-up Run window, and press the Enter key.
2. In the command window, enter `cd` followed by a space and the full path of your working folder, then press Enter to switch to the working directory. For example, if the folder is located in the root directory of drive D:
3. When the command line prefix shows the current working folder path, run the script with:
4. The script will automatically complete preprocessing of random field parameters with no manual operation required. The run is successful if no red error messages appear in the window and a base template file with the `.inp` suffix is added to the folder.

### Notes
- To adjust basic model parameters, open `randomfile2.py` with a text editor in advance, modify the corresponding parameter values, save the file, then run the script.
- It is recommended to run the full workflow with default parameters first to confirm normal operation, then make adjustments as needed.

## Step 2: Run midpoint_RF.m to Generate Soft Soil Random Fields
This step generates 2D or 3D soft soil parameter random fields conforming to spatial distribution rules based on the input node coordinates and statistical values of mechanical parameters, and automatically generates contour plots for intuitive inspection of result rationality.

### Prepare input files in advance
- **`node.txt`**: Stores coordinate information of all nodes in the Abaqus model, which can be exported from a pre-built Abaqus model. Each line corresponds to one node, listing node number and x, y, z coordinate values in sequence.
- **`param1.txt`, `param2.txt`, `param3.txt`, `param4.txt`**: Four parameter files corresponding to the statistical characteristics of four soil mechanical parameters (such as mean value, variance, and fluctuation distance). Fill in the corresponding parameter values in each file according to the format required by the script.

### Operation procedure
1. Open MATLAB software, and in the working path bar at the top of the interface, select the newly created working folder and set it as the current working directory.
2. Confirm that `midpoint_RF.m`, the prepared `node.txt` and the four parameter files are visible in the file list on the left.
3. Enter `midpoint_RF` in the command line window at the bottom of MATLAB and press Enter to run the script.
4. The script will automatically read all input files and compute the corresponding soft soil random field. After the calculation is completed, a contour visualization plot will pop up automatically. You can check whether the spatial distribution of parameters is continuous and whether the value range meets expectations through the plot.
5. Close the plot to finish the script run, and the raw data file of the random field will be generated in the working folder.

### Notes
- Ensure the format of `node.txt` fully matches the script requirements, and the node numbering and coordinate order are correct; otherwise, misaligned random fields will be generated.
- The units of the four parameter files must be kept consistent to avoid magnitude deviation in subsequent calculations.

## Step 3: Run importrandomdata_V4.m to Match Element IDs and Property Data
This step maps the node-level random field data generated in the previous step to each element of the Abaqus model, and generates the mapping relationship between elements and material parameters to prepare for batch generation of cases in the subsequent step.

### Operation procedure
1. Keep the MATLAB working directory unchanged, and confirm that all output files generated in the first two steps are retained completely in the folder.
2. Run the script in the MATLAB command line window:
3. 3. The script will automatically read the random field data and model element information, and complete one-to-one matching between element IDs and parameter values.
4. After the run is completed, two files, `elementlist.txt` and `elelist.txt`, will be added to the folder. These two files store the number and corresponding material parameter values of all elements. The matching is successful if ordered element numbers and parameter values can be seen when opening the files and no error prompts appear during operation.

### Notes
- This step strictly depends on the output files generated in the previous two steps. Do not delete or modify previous result files, otherwise matching failure will occur.
- If the model has a large number of elements, the running time will increase accordingly; please wait patiently.

## Step 4: Run generateINP.m to Batch Generate Abaqus Input Files
This step combines the base model template and element parameter mapping files to batch generate multiple independent case files. Each file corresponds to a different random field distribution and can be directly used for batch calculation in Monte Carlo simulations.

### Operation procedure
1. Keep the MATLAB working directory unchanged. To adjust the total number of cases to be generated, open `generateINP.m` with a text editor in advance, modify the parameter corresponding to the case quantity, and save the file.
2. Run the script in the MATLAB command line window:3. The script will automatically read the base `.inp` template and element mapping files, and batch generate all case files from `Job-1.inp` to the set `Job-n.inp`.
4. All generated `.inp` files can be directly submitted to the Abaqus solver for use. You can open Abaqus software and read the `.inp` files through the import model function for inspection, or directly submit them to the Standard or Explicit solver for batch calculation via the Abaqus command line.

### Notes
- The larger the number of generated cases, the longer the running wait time and the larger the occupied hard disk space.
- For initial testing, it is recommended to generate 2 to 3 cases first to verify the full workflow, and then perform large-scale batch generation after confirmation.

## Troubleshooting
- **Script reports "file not found"**: Prioritize checking whether the working directory is switched correctly, whether the file name is spelled accurately, and whether the file path contains Chinese characters or spaces.
- **MATLAB prompts "function not defined" during operation**: Check whether the working folder is set as the current working directory of MATLAB.
- **Abnormal values in generated random fields**: Check whether the values in the four parameter files are filled in correctly and whether the parameter units are kept consistent.

## Contact
Professor Jun Wang  
College of Civil Engineering and Architecture, Wenzhou University  
Email: wangjunx9s@163.com
