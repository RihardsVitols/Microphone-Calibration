(
//////////////  CONVOLVES TARGET MIC WITH BANDPASS FILTERS  //////////////


// variables ...
var optBconvSynth;
var filterKernelSf;
var kernelSize, frameSize, kernelPath;
var headerFormat, sampleFormat, sampleRate, numOutputChannels;
var delPreRecFiles;


// variables in loop
var playBuf, targetRecSf, targetRecPath;
var channelLoop, kernelLoop;
var filterKernelBuf, score, breakTime;
var destPath, destFolderPath, pathsTxtFile;


// set the NRT vars here...
headerFormat = "WAV";   // soundfile header format
sampleFormat = "int24";    // soundfile sample format
numOutputChannels = 4;    // one channel output


// all paths used in the code
pathsTxtFile  = "D:/TECHNOLOGY/Ambisonic_MIC/SuperColider/paths.txt".load; // path to the paths.txt file
destPath = pathsTxtFile[2].standardizePath;
destFolderPath = PathName.new(destPath);
targetRecPath = pathsTxtFile[3].standardizePath;  // path for your source mic B format recording
kernelPath = PathName.new(pathsTxtFile[4].standardizePath); // asigning folder of kernels


// if recorded target sample dose not exists prints line and ands the code
((File.exists(targetRecPath))&&(File.exists(kernelPath.fullPath))).if({


	// creating folder if it dosn't exist and deleting convovled audio files that will be created by the end of this code
	File.exists(destFolderPath.pathOnly).not.if({

		("Folder " ++ destFolderPath.folderName ++ " doesn't exist. \nFolder is being created!!").postln; // message


		//creates folder for convolved sample kernels
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


// The goal here is to take the reference (aka target) ambeo recording
// which is in Sennheiser optimized B-format and:
//
// 1) convert to A-format
// 2) convolve with bandpass filters
	optBconvSynth = CtkSynthDef(\optB_conv, { arg playBuf, filterKernelBuf, frameSize;
		var inA;  // a-format
		var out, bus;
		var numChannes;
		var orientation = \flu;  // this should match the target mic
		var weight = \car; // this should match the target mic


		// default vals
		numChannes = 4;  // input playBuf channels: four - because it is b-format
		bus = 0;    // write out bus number

		inA = FoaDecode.ar(
			PlayBuf.ar(  // the optimized ambeo b-format
				numChannels: numChannes,
				bufnum: playBuf
			),
			FoaDecoderMatrix.newBtoA(orientation, weight)
		);  // now a-format

		out = Convolution2.ar(
			in: inA,
			kernel: filterKernelBuf,
			framesize: frameSize
		);

		Out.ar(bus, out);
	});


	// set up recorded sound file instance
	targetRecSf = SoundFile.openRead(targetRecPath);


	//creating an array for kernel SoundFile instances
	filterKernelSf = Array.new();


	// adding kernels to kernel array
	kernelPath.entries.do({ arg path;
		filterKernelSf = filterKernelSf.add(SoundFile.openRead(path.fullPath));
	});


	// loop sizes for the process
	kernelLoop = filterKernelSf.size;


	// condition to do a break between each convolution
	breakTime  =  Condition();

	fork {


		// just loop through kernels, convolve in A-format
		kernelLoop.do({ arg kernelNr;

			("\nconvolving with " + kernelNr + " kernel out of " + filterKernelSf.size).postln;


			//create a score, each loop creat a new score
			score = CtkScore.new;


			// create (read in) recorded pink noise, one channel once at a time
			playBuf = CtkBuffer.new(
				path: targetRecSf.path,         // path set above
				startFrame: 0,                   // start from beginning
				numFrames: -1                // all frames
			);


			// add to score
			score.add(playBuf);  // playBuf declared above


			// create (read in) filter kernels in to a buffer
			filterKernelBuf = CtkBuffer.new(
				path: filterKernelSf[kernelNr].path,     // path set above
				startFrame: 0,                      // start from beginning
				numFrames: -1,                   // all frames
				numChannels: 1                // only one for buffer
			);

			score.add(filterKernelBuf);  // add to score


			//get Kernel size for Convolution
			kernelSize = filterKernelSf[kernelNr].numFrames;
			frameSize = kernelSize.nextPowerOfTwo;      // get FFT frameSize as >= pow2
			sampleRate = filterKernelSf[kernelNr].sampleRate;  // sample rate for the convolved sound file



			////////////////////______RENDER THE SCORE______//////////////////
			score.add(
				optBconvSynth.note(starttime: 0.0, duration:targetRecSf.duration )
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

		"\n ------DONE------\n".postln;
	}
}, {  // False - file doesn't exist!!


	// Error will break and halt execution
	Error.new(
		"\nFile % could not be opened.\n\nCheck if you added the right path and if the file is in the folder!!!!\n".format(targetRecPath)
	).throw

});
)