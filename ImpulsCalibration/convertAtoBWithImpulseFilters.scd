// RUN  THIS BEFORE REUSSING THE CODE
currentEnvironment.clear; // cleare all environmental variables


(
//// --- (Ambeo) A to B converter

// hand code a mono signal to a decorrelated soundfield in B-format
// NOTE: the demonstrated kernel is not ideal for this task

var ambeoLFUPath, ambeoRFDPath, ambeoBLDPath, ambeoBRUPath, paths, aFormat, destPath;
var aFormatSf, aFormatPath, kernelsSf, playBuf;
var kernelSize;
var kernel, numChannels, buffer, score, mySynthDef;

// set the NRT vars here...
var sampleRate;                  // decleared lower in the code before score write
var headerFormat = "WAV";       // soundfile header format
var sampleFormat = "int24";    // soundfile sample format
var numOutputChannels = 4;    // one channel output


// paths to impulse filters
ambeoLFUPath = "~/Desktop/ImpulseRecordings/impulsesConvertedWithAmbeo/lfuConv.wav".standardizePath;
ambeoRFDPath = "~/Desktop/ImpulseRecordings/impulsesConvertedWithAmbeo/rfdConv.wav".standardizePath;
ambeoBLDPath = "~/Desktop/ImpulseRecordings/impulsesConvertedWithAmbeo/lbdConv.wav".standardizePath;
ambeoBRUPath = "~/Desktop/ImpulseRecordings/impulsesConvertedWithAmbeo/rbuConv.wav".standardizePath;

// aFormatPath = "~/Desktop/MicCalibration/recordings/diyAFormatWithMeshGuard.wav".standardizePath;
aFormatPath = "~/Desktop/MicCalibration/recordings/SLI-A.wav".standardizePath;

destPath = "~/Desktop/ImpulseRecordings/calibSLI-B".standardizePath;

paths = [ambeoLFUPath, ambeoRFDPath, ambeoBLDPath, ambeoBRUPath];


//create a score, each loop create a new score
score = CtkScore.new;


// kernel collection of filters
kernel = paths.collect({ arg path, i;
	numChannels = 4; // could check with SoundFile, instead!!

	numChannels.collect({ arg channel;
		var kernelBuffer;

		path.postln;

		// read / load buffer
		kernelBuffer = CtkBuffer.new(
			path: path,
			numChannels: 4,
			channels: [channel]
		);


		// add to score
		score.add(kernelBuffer);


		// collect (return) buffer
		kernelBuffer
	})
});


kernel.postln; // posts content of kernel array


// convolution happens here
mySynthDef = CtkSynthDef.new(\synthDef, { arg playBuf;

	var sig, out, bus;

	bus = 0;

	// play buff
	sig = PlayBuf.ar(
		numChannels: 4,
		bufnum: playBuf
	);

	out = AtkKernelConv.ar(sig, kernel);
	// );
	// }));

	out.postln;
	// out = sig;

	Out.ar(bus, out);
});
// });

// read source sound file
aFormatSf = SoundFile.openRead(aFormatPath);


// create read in. one chanele once at a time // add 3 more for each single chanel  name by capsule location
playBuf = CtkBuffer.new(
	path: aFormatPath,            // path set above
	numChannels: 4,              // channel count
);


// add to score
score.add(playBuf);  // playBuf declared above

sampleRate = aFormatSf.sampleRate.postln; // sample rate for the convolved soundfile


////////////////////______RENDER THE SCORE______//////////////////
score.add(
	mySynthDef.note(starttime: 0.0, duration:aFormatSf.duration )
	.playBuf_(playBuf)
).write(
	path: destPath ++ ".wav",
	sampleRate: sampleRate,
	headerFormat: headerFormat,
	sampleFormat: sampleFormat,
	options: ServerOptions.new.numOutputBusChannels_(numOutputChannels).memSize_(65000),
);
)