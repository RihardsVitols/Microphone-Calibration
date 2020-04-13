(
///////////////////////////// CONVOLVED SOURCE MIC CONVERSION TO B-FORMAT /////////////////////////////


// varaibles ...
var sourcePath, kernelPath, destPath, destFolderPath, delPreRecFiles;
var score, playBuf, sourceSf;
var filterKernelSf, kernelLoop, filterKernelBuf, kernelSize;
var sourceAtoBSynth, sampleRate, numbFrames, frameSize;
var breakTime, sourceSize;

// set the NRT vars here...
var headerFormat = "WAV";   // soundfile header format
var sampleFormat = "int24";    // soundfile sample format
var numOutputChannels = 4;    // one channel output


// Paths
sourcePath = "~/Desktop/MicCalibration/006_CorrectedSourceAFormat/convSourc.wav".standardizePath;  // path to recording taht we want to oconvert
destPath = "~/Desktop/MicCalibration/recordings/diyB.wav".standardizePath;  // place where the B format file will be saved
destFolderPath = PathName.new(destPath);
//
// sourcePath = "~/Desktop/IS_RV/MicCalibration/006_CorrectedSourceAFormat/convSourc.wav".standardizePath;  // path to recording taht we want to oconvert
// destPath = "~/Desktop/IS_RV/MicCalibration/recordings/diyB.wav".standardizePath;  // place where the B format file will be saved
// destFolderPath = PathName.new(destPath);


	"\n ------CONVERTING SOURCE A TO B FORMAT------ \n".postln;


	// The goal here is to take the diy (aka source) mic recording
	//
	// 1) convert to B-format
	sourceAtoBSynth = CtkSynthDef(\AtoB_conv, { arg playBuf, frameSize, filterKernelBuf;
		var inB;  // a-format
		var out, bus;
		var numChannes;
		var orientation = \flu;  // this should match the diy mic
		var weight = \car; // this should match the diy mic


		// default vals
		numChannes = 4;  // input playBuf channels: four - because it is A-format
		bus = 0;    // write out bus number

		out = FoaEncode.ar(
			PlayBuf.ar(  // the corrected source mic A format
				numChannels: numChannes,
				bufnum: playBuf
			),
			FoaEncoderMatrix.newAtoB(orientation, weight)
		);  // now B-format

		/*out = Convolution2.ar(
			in: inB,
			kernel: filterKernelBuf,
			framesize: frameSize
		);*/

		Out.ar(bus, out);
	});


	// read source sound file
	sourceSf = SoundFile.openRead(sourcePath);


	// condition to do a break between each convolution
	breakTime  =  Condition();

	fork {


			//create a score. each loop creats a new score
			score = CtkScore.new;


			// create (read in) recorded pink noise. one chanele once at a time
			playBuf = CtkBuffer.new(
				path: sourceSf.path,         // path set above
				startFrame: 0,                   // start from beginning
				numFrames: -1                // all frames
			);


			// add to score
			score.add(playBuf);  // playBuf declared above


		    //get Kernel size for Convolution
			sourceSize = sourceSf.numFrames;
			frameSize = sourceSize.nextPowerOfTwo;      // get FFT frameSize as >= pow2
			sampleRate = sourceSf.sampleRate;  // sample rate for the convolved soundfile


			////////////////////______RENDER THE SCORE______//////////////////
			score.add(
				sourceAtoBSynth.note(starttime: 0.0, duration:sourceSf.duration )
				.playBuf_(playBuf)
				//.filterKernelBuf_(filterKernelBuf)
				.frameSize_(frameSize)
			).write(
				path: destPath ++ ".wav",
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

		"\n------DONE------".postln;
	};
)