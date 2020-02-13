(
///////////////////////////// BUILDS B FORMAT CORRECTION FILLTER LIBRARY /////////////////////////////


// variables for calling in the calculation data
var kernelPath, kernelSf;
var cmpData, cmpDataPath, correctionData;
var destPath, correctionKernel, correctionKernelLoop, correctionKernelSignals, correctionKernelFolderPath;
var correctionSampleRate, correctionKernelsCollection, correctionkernelSize;
var numChannels;

var delPreRecFiles;

var headerFormat = "WAV";
var sampleFormat = "float";
var newKernelSize = 4096;
var oversample = 2;  // minimum phase oversampling

// ploter variables
var size = 4096; // auto figure it out sam as line 16??
var plotArray, plotWindow;
var hue, numCols, colors;
var fftMagnitude, fftMagnitudeDb, fftResponse;
var plotDbMin = -20, plotDbMax = 12;  // auto size

numChannels = 4;    // set the channel nr


// all the paths in the code
cmpDataPath = "~/Desktop/MicCalibration/BFormat_cmp_in_db.txt".standardizePath;
kernelPath = PathName.new("~/Desktop/MicCalibration/001_bandPassFilters".standardizePath);
destPath = "~/Desktop/MicCalibration/011_BFormatCorectionFilters/Bcorfil".standardizePath;
correctionKernelFolderPath =  PathName.new(destPath);

// // all the paths in the code
// cmpDataPath = "~/Desktop/IS_RV/MicCalibration/BFormat_cmp_in_db.txt".standardizePath;
// destPath = "~/Desktop/IS_RV/MicCalibration/011_BFormatCorectionFilters/Bcorfil".standardizePath;
// correctionKernelFolderPath =  PathName.new(destPath);
// kernelPath = PathName.new("~/Desktop/IS_RV/MicCalibration/001_bandPassFilters".standardizePath);


// create an array for correction
correctionKernelSignals = Array.new(numChannels);


((File.exists(cmpDataPath))&&(File.exists(kernelPath.fullPath))).if({


	// if the bandPassFilters folder doesn't exist - create it
	File.exists(correctionKernelFolderPath.pathOnly).not.if({


		// message
		("Folder " ++ correctionKernelFolderPath.folderName ++ " dosn't exists. \nFolder is being created!!").postln;


		//creates folder for bandPass kernels
		try({

			correctionKernelFolderPath.pathOnly.mkdir
		}, {

			Error.new("Folder % could not be created!".format(correctionKernelFolderPath.pathOnly)).throw;
		});

		("Folder" ++ correctionKernelFolderPath.folderName ++ " created!! \n").postln
	});


	// get soundfile info
	kernelSf = kernelPath.entries.collect({ arg path, i;
		SoundFile.openRead(path.fullPath);  // reads each kernel from the folder
	});

	("\n" ++ kernelSf ++ "\n").postln; //check kernel array

	"sampleRate: ".post;
	correctionSampleRate = kernelSf.at(0).sampleRate.postln; // read sample rate from one of the band pass filters. all of them have the same sample rate

	"kernel size: ".post;
	correctionkernelSize = kernelSf.at(0).numFrames.postln; // kernel zise for correction filters. all of them have the same size


	// creats an array for the correction data. size = band pas filter count
	correctionData = Array.new(kernelSf.size * numChannels);

	cmpData = TabFileReader.new(cmpDataPath);// opens the txt file - outside the loop

	correctionData = cmpData.read.at(0).asFloat;

	cmpData.close;  // cleanup. closes the txt file


	// normalize
	correctionData = correctionData - correctionData.mean; // creats an avarage nr and subtructs from corraction data
	correctionData = correctionData.clump(numChannels); // group channels together....


	// inspect correction data
	("\n Array of correction data " ++ correctionData).postln;
	("\n Shape of correction data " ++ correctionData.shape).postln;


	// kernel loop - create and collect kernels
	correctionData.flop.do({ arg chanBandData, j;

		// inner loop
		correctionKernelSignals.add(
			chanBandData.collect({ arg dbVal, i;

				dbVal.neg.dbamp * Signal.read(kernelSf.at(i).path);  // flip

			}).sum.as(Signal).minimumPhase(oversample: oversample).keep(newKernelSize) * Signal.hanningWindow(2 * newKernelSize).keep(newKernelSize.neg)
		)
	});


	// write kernels
	correctionKernelSignals.do({ arg kernel, j;
		kernel.write(
			path: destPath ++ j.asString.padLeft(4, "0") ++ ".wav", // file destination with numbered title
			headerFormat: headerFormat,
			sampleFormat: sampleFormat,
			//numFrames: correctionSampleRate
		)
	});


	// collect magnitude responses for display
	plotArray = correctionKernelSignals.collect({ arg kernel, i;


		// FFT analysis here!
		fftResponse = fft(
			kernel,
			Signal.newClear(kernel.size),
			Signal.fftCosTable(kernel.size)
		);


		// find (& trim magnitude)
		fftMagnitude = fftResponse.magnitude;
		fftMagnitude = fftMagnitude.copyFromStart((size/2).asInteger);
		fftMagnitudeDb = fftMagnitude.ampdb;

	});


	//Plots filter collection in one graph
	numCols = plotArray.size;
	colors = numCols.collect{ arg i;
		hue = (numCols-1).reciprocal * i;
		hue = hue * 0.95; // scales within valid range
		Color.hsv(hue, 1,1,1)
	};

	plotWindow = plotArray.plot(
		name: "CORRECTION FILLTERS",
		bounds: Rect(0, 0, 1920, 800),
		minval: plotDbMin,
		maxval: plotDbMax
	);

	plotWindow.superpose_(true);
	plotWindow.plots[0].plotColor_(colors);
	plotWindow.refresh;

	"\n ------DONE------";
},{


	// Error will break and halt execution
	Error.new(
		"\nFile % and/or % could not be opened.\n\nCheck if you added the right path and if the file is in the folder!!!!\n".format(cmpDataPath, kernelPath)
	).throw
});
)