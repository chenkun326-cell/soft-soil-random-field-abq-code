Soft Soil Random Field Workflow for Abaqus

This repository contains a complete, reproducible pipeline for generating, visualizing, and batch-importing soil random fields into Abaqus for geotechnical numerical analysis.

Step-by-Step Workflow

1. randomfile2.py: Preprocesses random field parameters and generates base Abaqus input (.inp) file templates.

2. midpoint_RF.m: Reads Abaqus node data (node.txt) and mechanical property files (param1-4.txt) to simulate 2D/3D soft soil random fields, with built-in contour visualization for result verification.

3. importrandomdata_V4.m: Matches random field data to Abaqus element IDs, outputs elementlist.txt and elelist.txt for property mapping.

4. generateINP.m: Uses the mapping files to batch-generate job-specific Abaqus input files (Job-1.inp to Job-n.inp) ready for direct submission to Abaqus/Standard or Abaqus/Explicit solvers.

Key Notes

• The batch generation feature allows efficient running of Monte Carlo simulations with varying soil property distributions.

• All intermediate mapping files and parameter inputs are retained to ensure full reproducibility of the numerical results.
