# ZOOM Evaluation Scripts
The scripts and data provided with this repository have been used to evaluate the ODL implementation of the [ZOOM ODL Module](https://github.com/lsinfo3/zoom-odl) using [Matlab 2016](http://de.mathworks.com/products/matlab/).

# Usage
The main functionality of this set of scripts is to process results obtained by the ZOOM ODL Module (*./results_ISPDSL-II*) and asses their quality by comparing them to extracted flow information provided in *./data/ispdsl/*.

**start.m** -- This script processes the data and generates a result struct (**final_struct.mat**) that containes all the information required to reproduce the evaluation.

**plotZoomFigures.m** -- This script plots all figures (and some additional ones) used in the evaluation of the ZOOM algorithm.

# Authors
Steffen Gebert -- steffen.gebert at informatik.uni-wuerzburg.de

Stefan Geißler -- stefan.geissler at informatik.uni-wuerzburg.de

# License
This work is published under the [MIT License](https://opensource.org/licenses/MIT)
