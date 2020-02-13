//////////////  CONVOLVES SOURC MIC WITH BANDPASS FILTERS  //////////////
(


// variables ...
var rawAconvSynth;
var filterKernelSf;
var sourceRecSf, sourceRecPath;
var kernelSize, frameSize, kernelPath;
var outputPath, headerFormat, sampleFormat, sampleRate, numOutputChannels;
var delPreRecFiles;


// variables in loop
var playBuf;
var channelLoop, kernelLoop;
var filterKernelBuf, score, breakTime;
var destPath, destFolderPath;


// set the NRT vars here...
headerFormat = "WAV";   // soundfile header format
sampleFormat = "int24";    // soundfile sample format
numOutputChannels = 4;    // one channel output


// all paths used in the code
destPath  = "~/Desktop/MicCalibration/003_AFormatSourceConvolvedSamples/conv".standardizePath; // set the path for the destination of the convolved semples of reference mic and our own
destFolderPath = PathName.new(destPath);
sourceRecPath = "~/Desktop/MicCalibration/recordings/diy_mic.wav".standardizePath;  // path for build mic recording
kernelPath = PathName.new("~/Desktop/MicCalibration/001_bandPassFilters".standardizePath); // asigning folder of kernels

// // all paths used in the code
// destPath  = "~/Desktop/IS_RV/MicCalibration/003_AFormatSourceConvolvedSamples/conv".standardizePath; // set the path for the destination of the convolved semples of reference mic and our own
// destFolderPath = PathName.new(destPath);
// sourceRecPath = "~/Desktop/IS_RV/MicCalibration/recordings/diy_mic.wav".standardizePath;  // path for build mic recording
// kernelPath = PathName.new("~/Desktop/IS_RV/MicCalibration/001_bandPassFilters".standardizePath); // asigning folder of kernels


// if recorded target sample dosn't exists prints line and ands the code
((File.exists(sourceRecPath))&&(File.exists(kernelPath.fullPath))).if({


	// creating folder if it dosn't exist and deleting convovled audio files that will be created by the end of this code
	File.exists(destFolderPath.pathOnly).not.if({

		("Folder " ++ destFolderPath.folderName ++ " doesn't exists. \nFolder is being created!!").postln; // message


		//creates folder for convolved semple kernels
		try({

			destFolderPath.pathOnly.mkdir
		}, {

			Error.new("Folder % could not be created!".format(destFolderPath.pathOnly)).throw;
		});

		("Folder" ++ destFolderPath.folderName ++ " created!!").postln
	});


	// deletes all previous convalved wav files in folder
	delPreRecFiles = PathName.new(PathName.new(destPath).pathOnly).files;

	delPreRecFiles.do ({arg item;

		File.delete(item.fullPath);

		("deleted pre-existing wav file: " ++ item.fullPath).postln;  // posts a message
	});

	"\n ------CREATING FILES------ \n".postln;

	/////////////////______SYNTH DEF______//////////////////


	// SynthDef for source mic - aka, my diy
	// The source is in a raw A-format, i.e., directly off the mic capsules
	rawAconvSynth = CtkSynthDef(\rawA_conv, { arg playBuf, filterKernelBuf, frameSize;
		var out, bus;
		var numChannes;


		// default vals
		numChannes = 4;  // input playBuf channels: four
		bus = 0;

		out = Convolution2.ar(
			in: PlayBuf.ar(
				numChannels: numChannes,
				bufnum: playBuf
			),
			kernel: filterKernelBuf,
			framesize: frameSize
		);

		Out.ar(bus, out);
	});


	// set up recorded sound file instancet
	sourceRecSf = SoundFile.openRead(sourceRecPath);


	//creating an array for kernel SoundFile instances
	filterKernelSf = Array.new();


	// adding kernels to kernel array
	kernelPath.entries.do({ arg path;
		filterKernelSf = filterKernelSf.add(SoundFile.openRead(path.fullPath));
	});


	// loop sizes for the process
	channelLoop = sourceRecSf.numChannels;
	kernelLoop = filterKernelSf.size;


	// condition to do a break between each convolution
	breakTime  =  Condition();

	fork {

		kernelLoop.do({ arg kernelNr;

			("\nconvolving with " + kernelNr + " kernel out of " + filterKernelSf.size).postln;


			//create a score. each loop creats a new score
			score = CtkScore.new;


			// create (read in) recorded pink noise. one chanele once at a time
			playBuf = CtkBuffer.new(
				path: sourceRecSf.path,         // path set above
				startFrame: 0,                   // start from beginning
				numFrames: -1,                // all frames

			);


			// add to score
			score.add(playBuf);  // playBuf declared above


			// create (read in) filter kernels in to a buffer
			filterKernelBuf = CtkBuffer.new(
				path: filterKernelSf[kernelNr].path,     // path set above
				numFrames: -1,                   // all frames
				numChannels: 1,                // only one for buffer
			);

			score.add(filterKernelBuf);  // add to score


			//get Kernel size for Convolution
			kernelSize = filterKernelSf[kernelNr].numFrames;
			frameSize = kernelSize.nextPowerOfTwo;      // get FFT frameSize as >= pow2
			sampleRate = filterKernelSf[kernelNr].sampleRate;  // sample rate for the convolved soundfile



			////////////////////______RENDER THE SCORE______//////////////////
			score.add(
				rawAconvSynth.note(starttime: 0.0, duration:sourceRecSf.duration )
				.playBuf_(playBuf)
				.filterKernelBuf_(filterKernelBuf)
				.frameSize_(frameSize)
			).write(
				path: destPath ++ kernelNr.asString.padLeft(3, "0") ++ ".wav", // file destination with numbered title
				sampleRate: sampleRate,
				headerFormat: headerFormat,
				sampleFormat: sampleFormat,
				action:{  breakTime.test_(true).signal }, // tests if the file is finished and saved
				options: ServerOptions.new.numOutputBusChannels_(numOutputChannels),
			);
			breakTime.wait; // waits until file is created and saved
			breakTime.test_(false); // sets condition to flase for next loop
		});


		// clean up
		SoundFile.closeAll;

		"\n------DONE------\n".postln;

	}
}, {  // False - file doesn't exist!!


	// Error will break and halt execution
	Error.new(
		"\nFile % and/or % could not be opened.\n\nCheck if you added the right path and if the file is in the folder!!!!\n".format(sourceRecPath, kernelPath)
	).throw

});
)