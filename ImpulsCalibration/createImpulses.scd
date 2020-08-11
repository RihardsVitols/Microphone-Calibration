(
/*
Test each A-format channel of the Ambeo encoder with an impluse response

LFU [1] --> [ impulse, zeros, zeros, zeros] --> Ambeo-Enc --> [ response1_W, response1_X, response1_Y, response1_Z,]
RFD [2] --> [ zeros, impulse, zeros, zeros] --> Ambeo-Enc --> [ response2_W, response2_X, response3_Y, response2_Z,]
LBD [3] --> [ zeros, zeros, impulse, zeros] --> Ambeo-Enc --> [ response3_W, response3_X, response4_Y, response3_Z,]
RBU [4] --> [ zeros, zeros, zeros, impulse] --> Ambeo-Enc --> [ response4_W, response4_X, response5_Y, response4_Z,]

*/


// variables
var size, impulse, zeros, numChans, soundFile;
var lfuData, rfdData, lbdData, rbuData;
var lfuPath, rfdPath, lbdPath, rbuPath, impulsePath;
var delPreRecFiles;


// path
lfuPath = "~/Desktop/ImpulseRecordings/lfu.wav".standardizePath;
rfdPath = "~/Desktop/ImpulseRecordings/rfd.wav".standardizePath;
lbdPath = "~/Desktop/ImpulseRecordings/lbd.wav".standardizePath;
rbuPath = "~/Desktop/ImpulseRecordings/rbu.wav".standardizePath;
impulsePath = PathName.new(rbuPath); // any one above would work here


// make an impulse
//size = 8192
//size = 16384
size = 32768;

impulse = Signal.zeroFill(size); // fill w/ zeros
// impulse.put(0, 1.0); // put impulse at front!
impulse.put((size / 2).asInteger, 1.0); // put impulse at middle!

zeros = Signal.zeroFill(size);
//
// impulse = [zeros, impulse].flatten; // SET IMPULS IN MIDDLE


// if the ImpulseRecordings folder doesn't exist - create it
File.exists(impulsePath.pathOnly).not.if({

	// message
	("Folder " ++ impulsePath.folderName ++ " dosn't exists. \nFolder is being created!!").postln;

	//creates folder for impulses recordings
	try({

		impulsePath.pathOnly.mkdir
	}, {

		Error.new("\nFolder % could not be created!".format(impulsePath.pathOnly)).throw;
	});

	("\nFolder" ++ impulsePath.folderName ++ " created!!").postln
},{


	// deletes all previous impulses wav files in folder
	delPreRecFiles = PathName.new(PathName.new(rbuPath).pathOnly).files;

	delPreRecFiles.do ({arg item;

		File.delete(item.fullPath);

		("deleted pre-existing kernel wav files:\n" ++ item.fullPath).postln;  // posts a message
	});
});


//render it in sound file
numChans = 4;


// LFU-recording
soundFile = SoundFile.new.headerFormat_("WAV").sampleFormat_("int24").numChannels_(numChans);
soundFile.openWrite(lfuPath);
lfuData = [ impulse, zeros, zeros, zeros ];
soundFile.writeData(lfuData.flop.flatten.as(FloatArray));
soundFile.close;


// RFD-recording
soundFile = SoundFile.new.headerFormat_("WAV").sampleFormat_("int24").numChannels_(numChans);
soundFile.openWrite(rfdPath);
rfdData = [ zeros, impulse, zeros, zeros ];
soundFile.writeData(rfdData.flop.flatten.as(FloatArray));
soundFile.close;


// LBD-recording
soundFile = SoundFile.new.headerFormat_("WAV").sampleFormat_("int24").numChannels_(numChans);
soundFile.openWrite(lbdPath);
lbdData = [ zeros, zeros, impulse, zeros ];
soundFile.writeData(lbdData.flop.flatten.as(FloatArray));
soundFile.close;


// RBU-recording
soundFile = SoundFile.new.headerFormat_("WAV").sampleFormat_("int24").numChannels_(numChans);
soundFile.openWrite(rbuPath);
rbuData = [ zeros, zeros, zeros, impulse ];
soundFile.writeData(rbuData.flop.flatten.as(FloatArray));
soundFile.close;


"\n-----DONE----"
)