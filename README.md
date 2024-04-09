# System Identification of a Quarter Car Model

## How to run the code?
The exploration considers various parameters to be swept to understand estimation method performance. The parameters include:
  1. The input road relative velocity
  2. The sampling time of the estimation data
  3. Simulation & Prediction Focus setting of the model
The script ```quarterCarIdParameterSweep``` runs the entire parameter sweep by calling the ```generateResponse``` and ```identifySystem``` functions.
The variables ```velRange``` , ```sampTimeRange``` and ```numExpPerInput``` define the range of experiments to be conducted. Currently, the code is set to perform estimation for ```velRange``` of 1 kmph to 20 kmph under ```sampTimeRange``` of 0.01s to 0.06s and running 20 experiments for each setting.

**Note that the code uses ```parfor``` and ```parsim``` functionality to speed up processing. Therefore, it is necessary to have MATLAB Parallel Computing Toolbox installed on your machine to run the code.**
On an octacore 9th gen Intel i9 workstation, this small sweep took almost 5 hours, so consider your machine bandwidth before running the whole range.

The results from the parameter sweep are stored in a separate ```qcmVariables.mat``` file for post-processing. All the plots are generated in the ```Plots``` live script.
