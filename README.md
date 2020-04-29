# Microphone calibration
The NAME Project goal is to make a low cost ambisonic microphone. This repository contains 4 3D models for building a 1st order ambisonic mic and a collection of [SuperCollider](https://supercollider.github.io/) codes for microphone calibration. 
The 3D models are designed to be printed on a resin 3D printer. I used [Formlabs 2](https://formlabs.com/3d-printers/form-2/). Microphone consists of 4 parts - body, electronics cover, mesh screen and an adapter clamp for a microphone holder. Resoult folder contains recordings and images of calibartion that I did for testing codes.

This project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode)

### Overview
parts:
- 4 Unidirectional microphone capsules. I used this ones [Panasonic WM-55A103](https://media.digikey.com/pdf/Data%20Sheets/Panasonic%20Electronic%20Components/WM-55A103.pdf)
- audio cable
- 1/4 4 jacks
- male and female 5 pin XLR
- 4 680 ohm resistors
- 4 1 μF capacitors
- 3.3V battery
- on off toggle switch
- battery holder

equipment:
- 3D printer
- Ambisonic microphone, [I am using](https://en-us.sennheiser.com/microphone-3d-audio-ambeo-vr-mic)
- 4 channel audio recorder, [I am using](https://www.zoom-na.com/products/field-video-recording/field-recording/zoom-f4-multitrack-field-recorder)
- speaker array in a full spherical layout

software:
- [SuperCollider](https://supercollider.github.io/)
- [ATK](http://www.ambisonictoolkit.net/download/supercollider/)
- [Reaper](https://www.reaper.fm/download.php)

place for improvement:
- Panasonic WM-55A103 high noise level

### About building microphone
Before you start printing you will need to find and buy the required microphone capsules if you decide to use different ones you need to check if they fit the holder. Assembling the electronics requires soldering skill. For calibration you will need to have skills in SuperCollider and a sound source and a calibrated microphone for reference. The whole process takes around 14h ( including printing and recording ) some patience and the ability to perform tasks with precision and care.


### 3D models
The 3D models include a four capsule first order Ambisonics microphone and an adapter for a microphone holder designed by Rihards Vitols. The models will be expanded as testing proceeds.


### Electronics
At the moment there is no preamp and capsules that I used dosen not need phantom power. Electronic schematic for them I took from the capsule's datasheet and added all the necessary parts after that. 


### Calibration
The calibration contains 13 codes that need to be run one by one. Some of them may take some time to finish so be patient. The code will create folders that are necessary for saving results and will save them on your Desktop. To Change that edit Paths.txt.

1. install [SuperColider](https://supercollider.github.io/download)
2. install a git, I use this [one](https://git-scm.com/download/win)
3. restart your machine
4. open code named *Quarks-installation.scd* instruction are inside it
5. go to [ATK home page](http://www.ambisonictoolkit.net/download/supercollider/) and install plugins, reopen SuperCollider
6. open *paths.txt* edit paths if it is necessary. At given moment everything will be created in a folder *MicCalibration* on your Desktop
7. start to run SuperCollider codes starting with *000-....scd*. This creates a Pink noise recording in a folder *Desktop/MicCalibration/recordings*
8. Use the pink noise recording to do 2 recordings in a lab setting. One with a reference microphone and second with a target microphone (one you build). Make sure that both microphones are placed in exactly the same place and use the same settings when you do the recordings.
9. Convert reference microphone recording to B format through its softwear. In my case I was using Ambeo and its plugin with Reaper.
10. Put both recordings in the folder *Desktop/MicCalibration/recordings* then open *paths.txt* and in the lines 5, 8 after *.../recordings/...* change to your file names.
11. Now you can move one to code *001_....scd*. Some of the codes will take some time to process their tasks.

### Referneces
- [SpHEAR project](https://cm-gitlab.stanford.edu/ambisonics/SpHEAR/)
- [Calibration Approaches for HOA Microphone Arrays](https://www.researchgate.net/publication/338801738_Calibration_Approaches_for_HOA_Microphone_Arrays_Paper)
- [Calibration of Soundfield Microphones Using the Diffuse-Field Response](https://secure.aes.org/forum/pubs/conventions/?elib=16453)

### Acknowledgment
- [DxArts](https://dxarts.washington.edu/)
- [Joseph Anderson](https://dxarts.washington.edu/people/joseph-anderson)
- [Michael McCrea](https://github.com/mtmccrea)
- [Marcin Pączkowski](http://marcinpaczkowski.com/)
