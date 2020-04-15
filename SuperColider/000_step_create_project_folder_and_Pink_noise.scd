(
////////////// CREATES 24 CHANNEL PINK NOISE FILE FOR CALIBRATION //////////////


// variables
var projectFolder;
var score, note, synthDef, destPath, breakTime, pathsTxtFile;
var headerFormat, sampleFormat, sampleRate, numOutputChannels;


// set the NRT vars here...
headerFormat = "WAV";    // sound file header format
sampleFormat = "int24";   // sound file sample format
sampleRate = 44100;   // sample rate
numOutputChannels = 24;   // 24 channels for an ambisonic recording


// path
pathsTxtFile = "D:/TECHNOLOGY/Ambisonic_MIC/SuperColider/paths.txt".load; // path to the paths.txt file
destPath = pathsTxtFile[0].standardizePath;
projectFolder = PathName.new(destPath);


// creates a project folder on your Desktop
File.exists(projectFolder.fullPath).not.if({


	// message
	("Folder " ++ projectFolder.folderName ++ " doesn't exist. \nFolder is being created!!").postln;


	//creates folder for bandPass kernels
	try({

		projectFolder.pathOnly.mkdir
	}, {
		Error.new("Folder % could not be created!".format(projectFolder.pathOnly)).throw;
	});


	// message
	("Folder " ++ projectFolder.folderName ++ " created!! \n").postln
});


// condition to do a break between each score writing
breakTime  =  Condition();

fork {


	// create a score
	score = CtkScore.new;


	// synth that creat pink noise
	synthDef = CtkSynthDef.new(\pink, {

		arg gain, dur, ris = 0.5, dec = 0.5;
		var sig, env, amp, envGen;

		amp = gain.dbamp;   // turn gain in to the db amplitude

		env = Env.new([0, 1, 1, 0], [ris, dur - (dec + ris), dec]);   // envelope for beginning and end of the sound file

		envGen = EnvGen.kr(env, levelScale: amp, timeScale: 1);

		sig = {PinkNoise.ar(envGen)}!24;   // sets 24 independent Pink noise generators and spreds them out trough 24 channels

		Out.ar(0, sig);    // outputs signal to speakers
	});

	score.add(
		synthDef.note(starttime: 0.01, duration: 30)
		.dur_(30)
		.gain_(-6);
	);

	score.write(
		path: destPath.standardizePath,
		sampleRate: sampleRate,
		headerFormat: headerFormat,
		sampleFormat: sampleFormat,
		action:{  breakTime.test_(true).signal }, // tests if the file is finished and saved
		options: ServerOptions.new.numOutputBusChannels_(numOutputChannels)
	);
	breakTime.wait; // waits until file is created and saved
	breakTime.test_(false); // sets condition to flase for next loop


	"\n------DONE------\n".postln;
};

)