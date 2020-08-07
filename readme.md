# TouchMime - Biomimetic Encoding Model GUI

This software provides a graphical user interface (GUI) to generate a model that
computes the firing rate and area of afferent activation from a dynamic stimulus
applied to a localized patch of skin. Parameters of the model can be used to
create biomimetic stimulation protocols of the residual nerve for providing
real-time tactile feedback.

The approach used in this software is described in detail in the following
reference: [Okorokova E.V., He Q., Bensmaia S.J. “Biomimetic encoding model for
restoring touch in bionic hands through a nerve interface”. Journal of Neural
Engineering](http://iopscience.iop.org/article/10.1088/1741-2552/aae398/pdf)

## Getting Started

Before using the code, make sure you have an up-to-date version of TouchSim
(available at http://bensmaialab.org/) and all the relevant folders are added
to the Matlab directory.

To call the GUI interface, type 'TouchMime' in the command line.

### Dependencies

* MATLAB
    * Signal Processing Toolbox
    * Image Processing Toolbox
    * Statistics and Machine Learning Toolbox
    * Fuzzy Logic Toolbox
    * Curve Fitting Toolbox
    * Bioinformatics Toolbox
    * Econometrics Toolbox
    * Parallel Computing Toolbox
    * MATLAB Distributed Computing Server


## Choosing Parameters

1. MODEL TYPE - you can compute 'Firing Rate' and 'Area' models together or
separately, depending on your requirements. If you pick both options,
coefficients for each model will write in separate files. Note that the 'Area'
model takes significantly more time to compute and might involve a different set
of parameters than the 'FR' model. 
1. SAMPLING RATE - or frame rate of your recording device (number of samples
per second your sensor can provide). In the paper cited above, we show that
100 Hz is the minimum sampling rate, but prediction accuracy improves with
resolution.
1. NUMBER OF LAGS - is the number of lags of position, speed and acceleration
that the model will include (see the paper for details).
    * Depending on your sampling rate, you should pick an optimal time window for
accumulation of lags. For example, at 500 Hz and with 5 lags, stimulus
information will accumulate over 10 ms of the stimulus. 
    * We do not recommend more than 7 lags since more lags involve more
  computational complexity and thus may impair real time performance. 
    * We do not recommend using multiple lags with very low sampling rates. 
    * 'Area' and 'FR' models might require a different number of lags.
1. CONTACT AREA RADIUS – this corresponds to the size of the projection field
at the selected location. The selected contact area is displayed on the hand
diagram once 'Pick Contact Area' is clicked
1. PICK CONTACT AREA 
    * Option 1 - 'Centered on pad' will pick a circular area centered on a finger
  or palmar pad.
    * Option 2 - 'Manual pick' will place the contact exactly where you click on
  the hand figure. Caution: avoid placing contacts at boundaries between pads.
1. SAVE MODEL - pick a location to save your models. By default, model
coefficients, variable names, model performance (R-squared) and all
GUI-specified input parameters to the model will be saved. 

### Best Practices

For sampling rates above 100 Hz, we resample the area estimate and stimulus
parameters to 100 Hz and provide coefficients for a resampled model. For
stimulation protocols, make sure you sum sensor values in each 10 ms time
window before feeding them into the model. The output of your model will
provide an estimate of area of activation for the next 10 ms.

We do not rescale output to Hz. Output of the 'Firing Rate' model will be in
spikes/bin, where bin is (1000/samp_rate) ms, of 'Area' model in mm^2. Make
sure you take your units of measurement into account given your chosen
resolution of the sensor.

## Errors and Questions

The code was written with Matlab v2017a. Earlier versions might lead to inconsistencies. 

For questions or to report errors, go to https://groups.google.com/forum/#!forum/touchmime  

## Authors

Copyright 2018.

Liza Okorokova - lizok@uchicago.edu 
Qinpu He - qinpuhe@uchicago.edu 
Sliman Bensmaia - sliman@uchicago.edu 

## History

* Version 1.01 - September 24, 2018
