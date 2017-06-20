# GNLM
Groundwater Nitrogen Loading Model (GNLM)

## Overview



## Steps to run GNLM
 
### Prepare the data:
 
All input data are defined at the beginning of code under the section Read Input data.

There are two types of data.

 * **Pre-processed data** such as the ones that come from the model_in file which contain spatially distributed information. These types of data have been processed once and saved as matlab data type. 
 
* **Excel spreadsheets**. To use an updated spreadsheet simply change the correct filename inside the code. Note that the structure of the spreadsheet should not change and the code is not going to make any checks whatsoever about the validity of the input data. 

*The spreadsheets are expected in the folder Input_data, while the model input data in the folder model_in* 
 
### Run the code
Although one could write a loop to repeat the runs for each year without user intervention we choose not to do so because in the early days alot of things used to go wrong and the computer memory was not enough to load such large matrices.

To run the code specify the i_year variable at the first section of the code and simply press run. Repeat this for each year
(it is advisable also to check the path and the name of the output file to avoid overwriting existing data)
 
### Post process
The script *Output_stat.m* contains snippets of code for various post processing tasks.
To create a summary one need to run the first 3 code sections. (Make sure that you have enabled the Cell view mode in Matlab editor to be able to run independently code sections).



## Who do I talk to?
* thharter@ucdavis.edu


## Developers
* Thomas Harter
* ...
* ...

## References
1. Reference 1
1. Reference 2
1. etc
