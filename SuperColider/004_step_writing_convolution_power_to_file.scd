(
///////////////////////////////  CALCULATING POWER OF BOTH CONVOLUTIONS  ///////////////////////////////
///////////////////////////////  COMPARES POWERS AND WRITES THEM OUT AS DB  ///////////////////////////////



// variables for calculations
var targetRawArray;
var sourcRawArray;
var numChannels, numSemples;
var sourcDataCollection, targetDataCollection;
var cmp, cmpPath, cmpFile, cmpHumanPath, cmpHumanFile;
var sourcPath, sourcFile, targetPath, targetFile;
var sourcConvLoop, targetConvLoop, sourcConvPath, targetConvPath, pathsTxtFile;


// all the paths in the code
pathsTxtFile  = "D:/TECHNOLOGY/Ambisonic_MIC/SuperColider/paths.txt".load; // path to the paths.txt file
cmpPath = pathsTxtFile[7].standardizePath;
targetPath = pathsTxtFile[8].standardizePath;
targetConvPath = pathsTxtFile[9].standardizePath;

sourcPath = pathsTxtFile[10].standardizePath;
cmpHumanPath = pathsTxtFile[11].standardizePath;
sourcConvPath = pathsTxtFile[12].standardizePath;


// creating loop size
targetConvLoop = PathName.new(targetConvPath);  // folder with convolved samples
sourcConvLoop = PathName.new(sourcConvPath);  // folder with convolved samples

numChannels = 4;  // number of channels in micrephones
numSemples = sourcConvLoop.entries.size / numChannels;  //  this is stupid but i do not know other way at the moment


// if recorded target sample dose not exists prints line and end the code
((File.exists(targetConvPath))&&(File.exists(sourcConvPath))).if({


	// deletes the file if it exists already and creat a new one
	File.exists(sourcPath).if({


		// if file dose exists, delete
		File.delete(sourcPath);

		("deleted pre-existing: " ++ sourcPath ++ "\n").postln;  // posts a message
	});

	sourcFile = File(sourcPath, "a");  // creating a updatable txt file


	// loop for calculating and saving ambio data to a file
	sourcDataCollection = sourcConvLoop.entries.collect({arg path, i;

		var sourcPower;

		numChannels.collect({ arg channelNr;

			("analyzing source mic band " ++ i ++ " out of " ++ sourcConvLoop.entries.size ++ " from channel " ++ ( channelNr )) .postln;

			sourcRawArray = Signal.read(
				path: path.fullPath,
				channel: channelNr
			);

			sourcPower = sourcRawArray.rms; // math to get power - Root Mean Squared

			sourcFile.write(sourcPower.asCompileString ++ "\n");    // write calculated number in a new line in the file

			sourcPower;  // this is added to the array collection
		});
	}).flat;


	// clean up
	sourcFile.close;

	"__________________________ \n".postln;


	// deletes the file if it exists already and creat a new one
	File.exists(targetPath).if({


		// if file dose exists, delete
		File.delete(targetPath);

		("deleted pre-existing: " ++ targetPath).postln;  // posts a message
	});

	targetFile = File(targetPath, "a");  // creating a updatable txt file


	// loop for calculating and saving self build mic  data to a file
	targetDataCollection  = targetConvLoop.entries.collect({arg path, i;

		var targetPower;

		numChannels.collect({ arg channelNr;

			("analyzing target mic band " ++ i ++ " out of " ++ targetConvLoop.entries.size ++ " from channel " ++ ( channelNr )) .postln;

			targetRawArray = Signal.read(
				path: path.fullPath,
				channel: channelNr
			);

			targetPower = targetRawArray.rms;  // math to get power - Root Mean Squared

			targetFile.write(targetPower.asCompileString ++ "\n");    // write calculated number in a new line in the file

			targetPower;   // this is added to the array collection
		});
	}).flat;


	// clean up
	targetFile.close;

	"__________________________ \n".postln;


	// calculating and recording comparison between both microphones
	cmpHumanFile = TabFileWriter.new( cmpHumanPath, "w"); // creating a updatable file that human can read

	cmpFile = TabFileWriter.new( cmpPath, "w"); // creating a updatable file for calculation in upcoming steps

	cmp = (sourcDataCollection / targetDataCollection).ampdb;  // measure comparison between both microphones

	cmpFile.writeLine(cmp);    // write calculated results in a new line in the file


	// rearange array in human readable order by creating table of 1st, 2nd, 3rd, 4th channel etc. depending on number of channels in your recordings ( set this number in line 28)
	cmpHumanFile = TabFileWriter.new( cmpHumanPath, "w"); // creating a updatable file that human can read

	cmpHumanFile.writeLine(["channel 0", "channel 1", "channel 2", "channel 3"]);

	cmp.clump(numChannels).do({ arg item;
		cmpHumanFile.writeLine(item)
	});


	// clean up
	cmpFile.close;
	cmpHumanFile.close;

	"\n------DONE------\n";

},{ // False - file doesn't exist!!


	// Error will break and halt execution
	Error.new(
		"\nFile % and/or % could not be opened.\n\nCheck if you added the right path and if the file is in the folder!!!!\n".format(targetConvPath, sourcConvPath)
	).throw

});

)