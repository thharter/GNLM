# GNLM to geotiff processing

## Setup

### Conda environment with gdal and pandas

Install anaconda, open anaconda prompt and create a copy of the development environment using `conda env create -f gdal.yml` with the yaml environment file included in the repo. The environment includes a version of gdal with python 2.7 that should reduce the number of conflicts trying to install gdal on windows machines.

source the env file using `activate gdal`


## Add model coordinates

The `.dat` files that are from Matlab do not contain the model coordinates. The model coordinates must be added manually in order to rasterize the results. The files are structured in a sequential order so it's possible to merge the .dat file with the gnlm results with a text file that contains the model coordinates (X,Y,R,C) where X Y are the coordinates in California Teale Albers (ESPG:3310) and R & C are the row/columns numbers of the grid.

```
usage: add_model_coords.py [-h] [-o OUTPUT_DIR] model_coordinates gnlm_dat

positional arguments:
  model_coordinates     Text file with GNLM model coordinates
  gnlm_dat              GNLM results without coordinates (.dat)

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT_DIR, --output_dir OUTPUT_DIR
                        Output directory for merged csv file. Default location
                        is current working directory. File will have the same
                        basename as gnlm_dat argument
```


## Rasterizing GNLM results from csv with model coordinates

The python script `rasterize_gnlm_results.py` uses gdal to rasterize the tabular model output that have coordinates. The script creates a virtual file (.vrt) for each variable which then can be rasterized in the gdal command line tool using `gdal_rasterize`. This script spawns a new console window for each variable and passes in the appropriate project settings to gdal. Running multiple instances of `gdal_rasterize` can take up a lot of cpu resources, if you are running locally then you might only want to rasterize one variable at a time.

To get help, `python rasterize_gnlm_results.py -h`

```
usage: rasterize_gnlm_results.py [-h] [-v VARIABLES [VARIABLES ...]]
                                 [-o OUTPUT_DIR] [-d]
                                 gnlm_csv

positional arguments:
  gnlm_csv              CSV file with GNLM results with coordinates

optional arguments:
  -h, --help            show this help message and exit
  -v VARIABLES [VARIABLES ...], --variables VARIABLES [VARIABLES ...]
                        GNLM variable column name to rasterize or defaults to
                        ALL variables if not provided. Try: Ndeposition,
                        Nirrigation, NgwDirect, NlandApplied, Nnorm,
                        Nfertilizer, NmanureSale, Nharvest, Nharvest_actual,
                        Nrunoff_actual, Ngw, NatmLosses, Ngw_nondirect,
                        Nseptic
  -o OUTPUT_DIR, --output_dir OUTPUT_DIR
                        output directory for rasters. Default location is
                        current working directory
  -d, --dryrun          Dry run. Creates vrt files but does not rasterize
```

### Example

This example rasterizes three of the variables (NgwDirect, Ngw, Nrunoff_actual) that are columns in the `example.csv` file (small test case that is included in this repository) and saves the rasters in a folder called example_geotiff (will create the output directory if it does not already exist).

```
python rasterize_gnlm_results.py example.csv -v NgwDirect Ngw Nrunoff_actual -o example_geotiff
```