# adds the model coordinates to the gnlm results using pandas df. Writes result to a csv file.
import pandas as pd
import os
import argparse


def checkfiletype(value, extension):
    """
    https://stackoverflow.com/questions/12977628/filetype-checking-arguments-passed-to-python-script-using-argparse
    :param value: path to csv file
    :param extension: string containing the extension ie '.csv'
    :return:
    """
    if not value.endswith(extension):
        raise argparse.ArgumentTypeError(
            'argument filename must be of type *{}'.format(extension))
    return value

# full path to the current directory
wd = os.path.dirname(os.path.realpath(__file__))

# build the parser for the command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('model_coordinates', help='Text file with GNLM model coordinates', type=lambda f: checkfiletype(f,'.txt'))
parser.add_argument('gnlm_dat', help='GNLM results without coordinates (.dat)', type=lambda f: checkfiletype(f,'.dat'))

parser.add_argument('-o','--output_dir',
                    help='Output directory for merged csv file. Default location is current working directory. File will'
                         ' have the same basename as gnlm_dat argument', default=wd)
args = parser.parse_args()


# create output folder if it does not already exist
if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)


# parameters
out_dir = args.output_dir
base = os.path.splitext(os.path.basename(args.gnlm_dat))[0]
csv_output = os.path.join(out_dir, base + '.csv')
dat = args.gnlm_dat
model_coords = args.model_coordinates

# load in the two text files
print("Loading {} into a pandas dataframe....".format(model_coords))
model_coords_df = pd.read_table(model_coords, sep='\s+')

print("Loading {} into a pandas dataframe....".format(dat))
dat_df = pd.read_table(dat, sep='\s+')


# raise error if the two files are not the same length
if dat_df.shape[0] != model_coords_df.shape[0]:
    raise ValueError('The two data sets differ in the total number of rows. {} rows != {} rows'.format(model_coords_df.shape[0], dat_df.shape[0]))

# concatenate the two dataframes together
print("Merging the two dataframes together...")
smashed_together = pd.concat([model_coords_df, dat_df], axis=1)

# write the concatenated df to disk as a csv
print("Saving merged dataframe to {}".format(csv_output))
smashed_together.to_csv(csv_output, index=False)

