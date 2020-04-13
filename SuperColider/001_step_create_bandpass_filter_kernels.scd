(
///////////////////  BUILDING BANDPASS FILTERS  ///////////////////


// variables ...
var size = 32768;
var sampleRate = 44100;
var headerFormat = "WAV";
var sampleFormat = "float";


// ploter variables
var plotArray, plotWindow;
var hue, numCols, colors;
var plotDbMin = -60, plotDbMax = 5;


// the kernels variables
var kernels, destPath, kernelFolderPath;
var kernel, fftResponse, fftMagnitude, fftMagnitudeDb;


// Octave calculcation variables
var upFreq, lowFreq, calculateFreqRatio, alpha;
var numOfDivisions, numOfOctaves, subFreqs, subFreqArraySize;
var delPreRecFiles;


// paths
destPath = "~/Desktop/MicCalibration/001_bandPassFilters/bandPass".standardizePath; // path where all the kernels will be writen
kernelFolderPath = PathName.new(destPath);

// // paths
// destPath = "~/Desktop/IS_RV/MicCalibration/001_bandPassFilters/bandPass".standardizePath; // path where all the kernels will be writen
// kernelFolderPath = PathName.new(destPath);


// set number of octaves
numOfDivisions = 10;
numOfOctaves = 12;


// filter s variables 10 max value giving a sharp resoult
// alpha = 1.0;  // ideal - use this
// alpha = 0.1;  // smooth - or, use this...
alpha = 2.sqrt.reciprocal;


// if the bandPassFilters folder doesn't exist - create it
File.exists(kernelFolderPath.pathOnly).not.if({


	// message
	("Folder " ++ kernelFolderPath.folderName ++ " dosn't exists. \nFolder is being created!!").postln;


	//creates folder for bandPass kernels
	try({

		kernelFolderPath.pathOnly.mkdir
	}, {

		Error.new("\nFolder % could not be created!".format(kernelFolderPath.pathOnly)).throw;
	});

	("\nFolder" ++ kernelFolderPath.folderName ++ " created!!").postln
},{


	// deletes all previous convalved wav files in folder
	delPreRecFiles = PathName.new(PathName.new(destPath).pathOnly).files;

	delPreRecFiles.do ({arg item;

		File.delete(item.fullPath);

		("deleted pre-existing kernel wav files: " ++ item.fullPath).postln;  // posts a message
	});
});


// freq ratio calculation
calculateFreqRatio = {arg interval;
	2.pow(interval / numOfDivisions);
};


// sub freq calculation
subFreqs = (numOfDivisions * numOfOctaves).collect({arg i;
	calculateFreqRatio.value(i, numOfDivisions).reciprocal * sampleRate / 2
});

subFreqs = subFreqs.drop(1);  // drop Nyquist....
("\neach sub frequency\n" ++ subFreqs ++ "\n").postln;


// use NEW! -gaussianBank
kernels = Signal.gaussianBank(size, subFreqs, alpha, sampleRate);


// write kernels
kernels.do({ arg kernel, i;


	//posts which bandpass filter is being recorded
	("writting kernel Nr " ++ i).postln;

	kernel.write(
		destPath ++ i.asString.padLeft(4, "0") ++ ".wav", // file destination with numbered title
		headerFormat,
		sampleFormat,
		sampleRate
	);
});


// prepare plot
plotArray = kernels.collect({ arg kernel, i;


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
	name: "band pass filters",
	bounds: Rect(0, 0, 1920, 800),
	minval: plotDbMin,
	maxval: plotDbMax
);

plotWindow.superpose_(true);
plotWindow.plots[0].plotColor_(colors);
plotWindow.refresh;

"\n------DONE------\n";

)