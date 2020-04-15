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
cmpPath = pathsTxtFile[21].standardizePath;
targetPath = pathsTxtFile[22].standardizePath;
targetConvPath = pathsTxtFile[23].standardizePath;

sourcPath = pathsTxtFile[24].standardizePath;
cmpHumanPath = pathsTxtFile[25].standardizePath;
sourcConvPath = pathsTxtFile[26].standardizePath;


// creating loop size
targetConvLoop = PathName.new(targetConvPath);  // folder with convolved samples
sourcConvLoop = PathName.new(sourcConvPath);  // folder with convolved samples

numChannels = 4;  // number of channels in micrephones
numSemples = sourcConvLoop.entries.size / numChannels;  //  this is stupid but i do not know other way at the moment


// if recorded target sample dosn't exists prints line and ands the code
((File.exists(targetConvPath))&&(File.exists(sourcConvPath))).if({


	// deletes the file if it exists allready and creats a new one
	File.exists(sourcPath).if({


		// if file dose exists, delete
		File.delete(sourcPath);

		("deleted pre-existing: " ++ sourcPath ++ "\n").postln;  // posts a message
	});

	sourcFile = File(sourcPath, "a");  // creating a updatable txt file


	// loop for calculating and saving ambio data to a file
	sourcDataCollection = sourcConvLoop.entries.collect({arg path, i;

		var sourcPower;

		i = i + 1; // starts i with one

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


	// deletes the file if it exists allready and creats a new one
	File.exists(targetPath).if({


		// if file dose exists, delete
		File.delete(targetPath);

		("deleted pre-existing: " ++ targetPath).postln;  // posts a message
	});

	targetFile = File(targetPath, "a");  // creatingf a updatable txt file


	// loop for calculating and saving self build mic  data to a file
	targetDataCollection  = targetConvLoop.entries.collect({arg path, i;

		var targetPower;

		i = i + 1; // starts i with one

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


	// colculating and recording comparison between bouth mic`s
	cmpHumanFile = TabFileWriter.new( cmpHumanPath, "w"); // creatingf a updatable tah human can read

	cmpFile = TabFileWriter.new( cmpPath, "w"); // creatingf a updatable file

	cmp = (sourcDataCollection / targetDataCollection).ampdb;  // measure comparison

	cmpFile.writeLine(cmp);    // write calculated number in a new line in the file


	// rearange array in human readable order by creating table of 1st, 2nd, 3th, 4th channel etc. dipending on number of channels in your recordings ( set this number in line 28)
	cmpHumanFile = TabFileWriter.new( cmpHumanPath, "w"); // creatingf a updatable tah human can read

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