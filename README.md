# Microphone calibration


The NAME Project is a collection of 3 3D models for bulding a 1st order ambisonic mic and a collection of SuperColider codes for mic calibration. 
The 3D models are almost completely parametric and are designed to be printed on a resin 3D printer. I used Formlabs 2. Mic consists out of 3 parts - body, electronics cover and mesh screen.

### Overwie

### About building microphone
Before you start printing you will need to find and buy the required microphone capsules if you decide to use different ones you need to check if they fit the holder. Assembling the electronics requires soldering skill. For calibration you will need to have skills in supercolider and a sound source and a calibrated microphone for reference. The whole process takes around 14h ( including printing and recording ) some patience and the ability to perform tasks with precision and care.


### 3D models
The 3D models includes a four capsule first order Ambisonics microphone designed by Rihards Vitols. The models will be expanded as testing proceeds.


### Electronics
At the moment there is no preamp and capsules that I used dosen not need phantom power. Electronic schematic for them I took from capsules datasheet and added all the neccery parts after that. 


### Calibration
The calibration containts 13 codes that need to be run one by one. Some of the may take some time to finish so be pattiont. The code will create folders that are neccery for saving resoults and will save them on your Desktop. to Chnage that edit Paths.txt.

1. install [SuperColider](https://supercollider.github.io/download)
2. install a git, I use this [one](https://git-scm.com/download/win)
3. restart your machine
4. open code named *Quarks-installation.scd* instruction are inside it
5. go to [ATK home page](http://www.ambisonictoolkit.net/download/supercollider/) and install plugins, reopen SuperCollider
6. open *paths.txt* edit paths if it is neccery. At given moment everything will be created in a folder *MicCalibration* on your Desktop
7. start to run SuperCollider codes starting with *000-....scd*. This creates a Pink noise recording in a folder *Desktop/MicCalibration/recordings*
8. Use the pink noise recording to do 2 recordings in a lab setting. One with a reference micrephone and second one with target micrephone (one you bild). Make sure that both micrephones are place in exectly the same place and uses same settings when you do the recordings.
9. Convert reference microphone recording to B format trough its softwear.
10. Put both recodrings in the folder *Desktop/MicCalibration/recordings* then open *paths.txt* and in the lines 5, 8 after *.../recordings/...* change to your file names.
11. Now you can move one to code *001_....scd*. Some of the codes will take some time to process their tasks.

### Referneces
[SpHEAR project](https://cm-gitlab.stanford.edu/ambisonics/SpHEAR/)
