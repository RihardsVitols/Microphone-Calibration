# mic_calibration_SC


The NAME Project is a collection of 3 3D models for bulding a 1st order ambisonic mic and a collection of SuperColider codes for mic calibration. 
The 3D models are almost completely parametric and are designed to be printed on a resin 3D printer. I used Formlabs 2. Mic consists out of 3 parts - body, electronics cover and mesh screen.


### About building microphone
Before you start printing you will need to find and buy the required microphone capsules if you decide to use different ones you need to check if they fit the holder. Assembling the electronics requires soldering skill. For calibration you will need to have skills in supercolider and a sound source and a calibrated microphone for reference.The whole process takes around 14h ( including printing and recording ) some patience and the ability to perform tasks with precision and care.


### 3D models
The 3D models includes a four capsule first order Ambisonics microphone designed by Rihards Vitols. The models will be expanded as testing proceeds.


### Electronics
dir -> electronic_componnents
At the moment there is no preamp and capsules that I used dosen not need phantom power. Electronic schematic for them I took from capsules datasheet and added all the neccery parts after that.


### Calibration
The calibration/src directory contains the Octave files for the current calibration software. The CALIBRATION.md file in there has a very brief description of usage, but currently is out of date with the current source code. Look into the individual files for more guidance. Hopefully this will be fixed soon.
