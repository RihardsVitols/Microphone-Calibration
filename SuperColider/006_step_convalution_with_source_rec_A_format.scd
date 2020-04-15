
///////////////////////// SOURCE MIC A FORMAT CONVOLUTION WITH CORRECTION FILTERS ////////////////////////


(
// variables ...
var convSynth;
var correctionKernelsSf;
var kernelSize, frameSize, correctionKernelPath;
var headerFormat, sampleFormat, sampleRate, numOutputChannels;
var destPath, convolvedSempleFolder, sourceRecPath, pathsTxtFile;


// variables in loop
var playBuf, targetRecSf;
var channelLoop, kernelLoop;
var correctionKernelBuf0, correctionKernelBuf1, correctionKernelBuf2, correctionKernelBuf3;
var score, breakTime;


// set the NRT vars here...
headerFormat = "WAV";   // soundfile header format
sampleFormat = "int24";    // soundfile sample format
numOutputChannels = 4;    // one channel output


// all paths used in the code
pathsTxtFile  = "D:/TECHNOLOGY/Ambisonic_MIC/SuperColider/paths.txt".load; // path to the paths.txt file
destPath  = pathsTxtFile[14].standardizePath; // set the path for the destination of the convolved A format target mic
convolvedSempleFolder = PathName.new(destPath);
sourceRecPath = pathsTxtFile[6].standardizePath;  // path for build mic recording
correctionKernelPath = PathName.new(pathsTxtFile[15].standardizePath); // asigning folder of kernels


((File.exists(sourceRecPath))&&(File.exists(correctionKernelPath.fullPath))).if({


	// creates project folder on your Desktop where everything will be stored in next steps
	File.exists(convolvedSempleFolder.pathOnly).not.if({


		// message
		("Folder " ++ convolvedSempleFolder.folderName ++ " doesn't exist. \nFolder is being created!!").postln;


		//creates folder
		try({

			convolvedSempleFolder.pathOnly.mkdir
		}, {

			Error.new("Folder % could not be created!".format(convolvedSempleFolder.pathOnly)).throw;
		});

		("Folder " ++ convolvedSempleFolder.folderName ++ " created!!\n").postln
	});


	/////////////////______SYNTH DEF______//////////////////


	// Convolution happens here
	convSynth = CtkSynthDef(\record_conv, { arg playBuf, correctionKernelBuf0, correctionKernelBuf1, correctionKernelBuf2, correctionKernelBuf3, frameSize;

		var in, out, bus;
		var numChannes;


		// default vals
		numChannes = 4;
		bus = 0;

		in = PlayBuf.ar(
			numChannels: numChannes,
			bufnum: playBuf
		);

		out = Array.with(
			Convolution2.ar(
				in.at(0),  // channal number
				kernel: correctionKernelBuf0,
				framesize: frameSize
			),
			Convolution2.ar(
				in.at(1),  // channal number
				kernel: correctionKernelBuf1,
				framesize: frameSize
			),
			Convolution2.ar(
				in.at(2),  // channal number
				kernel: correctionKernelBuf2,
				framesize: frameSize
			),
			Convolution2.ar(
				in.at(3),  // channal number
				kernel: correctionKernelBuf3,
				framesize: frameSize
			),
		);

		Out.ar(bus, out);
	});


	// set up recorded sound file instancet
	targetRecSf = SoundFile.openRead(sourceRecPath);


	//creating an array for kernel SoundFile instances
	correctionKernelsSf = Array.new();


	// adding kernels to kernel array
	correctionKernelPath.entries.do({ arg path;
		correctionKernelsSf = correctionKernelsSf.add(SoundFile.openRead(path.fullPath));
	});

	// condition to do a break between each convolution
	breakTime  =  Condition();

	fork {


		//create a score. each loop creats a new score
		score = CtkScore.new;

		// create (read in) recorded target mic. one chanele once at a time
		playBuf = CtkBuffer.new(
			path: sourceRecPath,         // path set above
			startFrame: 0,                   // start from beginning
			numFrames: -1,                // all frames
		);


		// add to score
		score.add(playBuf);  // playBuf declared above


		// create (read in) filter kernels in to a buffer
		correctionKernelBuf0 = CtkBuffer.new(
			path: correctionKernelsSf[0].path,     // path set above
			startFrame: 0,                      // start from beginning
			numFrames: -1,                   // all frames
		);

		correctionKernelBuf1 = CtkBuffer.new(
			path: correctionKernelsSf[1].path,     // path set above
			startFrame: 0,                      // start from beginning
			numFrames: -1,                   // all frames
		);

		correctionKernelBuf2 = CtkBuffer.new(
			path: correctionKernelsSf[2].path,     // path set above
			startFrame: 0,                      // start from beginning
			numFrames: -1,                   // all frames
		);

		correctionKernelBuf3 = CtkBuffer.new(
			path: correctionKernelsSf[3].path,     // path set above
			startFrame: 0,                      // start from beginning
			numFrames: -1,                   // all frames
		);

		score.add(correctionKernelBuf0);  // add to score
		score.add(correctionKernelBuf1);  // add to score
		score.add(correctionKernelBuf2);  // add to score
		score.add(correctionKernelBuf3);  // add to score


		//get Kernel size for Convolution
		kernelSize = correctionKernelsSf[0].numFrames;
		frameSize = kernelSize.nextPowerOfTwo;      // get FFT frameSize as >= pow2
		sampleRate = correctionKernelsSf[0].sampleRate;  // sample rate for the convolved soundfile


		////////////////////______RENDER THE SCORE______//////////////////
		score.add(
			convSynth.note(starttime: 0.0, duration: targetRecSf.duration )
			.playBuf_(playBuf)
			.correctionKernelBuf0_(correctionKernelBuf0)
			.correctionKernelBuf1_(correctionKernelBuf1)
			.correctionKernelBuf2_(correctionKernelBuf2)
			.correctionKernelBuf3_(correctionKernelBuf3)
			.frameSize_(frameSize)
		).write(
			path: destPath ++ ".wav", // file destination with numbered title
			sampleRate: sampleRate,
			headerFormat: headerFormat,
			sampleFormat: sampleFormat,
			action:{  breakTime.test_(true).signal }, // tests if the file is finished and saved
			options: ServerOptions.new.numOutputBusChannels_(numOutputChannels),
		);

		breakTime.wait; // waits until file is created and saved
		breakTime.test_(false); // sets condition to flase for next loop


// clean up
SoundFile.closeAll;


// posts when done
"\n-----DONE-----\n".postln;
}
},{


	// Error will break and halt execution
	Error.new(
		"\nFile % and/or % could not be opened.\n\nCheck if you added the right path and if the file is in the folder!!!!\n".format(sourceRecPath, correctionKernelPath)
	).throw;
});
)