## foci2D
##### Adam Tyson | 2018-05-08 | adam.tyson@icr.ac.uk

#### Takes a two channel .lsm image. Channel 1 (nuclei) is maximum projected, and segmented. The nuclear segmentation is used to estimate cytoplasmic boundaries (midpoints between nuclei). Foci in the 2nd channel are then quantified on a cell by cell basis.

##### N.B. needs a recent version of MATLAB and the Image Processing Toolbox. Also required biformats toolbox (included). Should work on Windows/OSX/Linux.

## Instructions:

1. Save images as .lsm, nuclear marker in channel 1, foci in 2nd channel.
2. Clone or download repository (e.g. **Clone or download -> Download ZIP**, then unzip **foci2D-master.zip**).
3. Place whole directory in the MATLAB path (e.g. C:\\Users\\User\\Documents\\MATLAB).
4. Open foci2D\\foci2D and run (F5 or the green "Run" arrow under the "EDITOR" tab). Alternatively, type *foci2D* into the Command Window and press ENTER.
5. Choose a directory that contains the images.
6. Choose various options:
    * **Save results as csv** - all the results will be exported as a .csv for plotting and statistics
    * **Display segmentation** - displays segmentation of nuclei, estimation of cytoplasmic boundaries and the segmented foci.

7. Confirm or change options: (the defaults can be changed under *function vars=getVars* in cell_coloc_3D.m
    * **Nuclear segmentation threshold** -  increase to be more stringent on what is a cell (and vice versa)
    * **Foci segmentation threshold** -  increase to be more stringent on what are foci (and vice versa)
    * **Maximum hole size** - how big a "hole" inside a cell should be filled
    * **Largest object to remove** - how big can bright spots outside the main mass of cells be and still be ignored by the analysis
    * **Smoothing sigma (nucleus)** - how much to smooth before thresholding
    * **Smoothing sigma (foci)** - how much to smooth before thresholding

8. The script will then loop through all the images in the chosen folder. Each image will be processed in turn, and a number of parameters will be saved (if specified):

  * **fociNumbers_TIMESTAMP.csv** - number of foci per cell, per image
  * **fociTotalInten_TIMESTAMP.csv** - total intensity of all pixels in foci, per cell, image
  * **summaryResults.csv** - includes various parameters per image (but not per cell). These include:
    * Mean foci number per cell
    * Mean total foci area per cell
    * Mean total foci intensity per cell
    * Number of cells

Once the first image has been analysed, the progress bar will give an estimate of the remaining time.
