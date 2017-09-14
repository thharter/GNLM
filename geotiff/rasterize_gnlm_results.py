import os
import xml.etree.cElementTree as ET
import argparse


def csvfile(value):
    """
    https://stackoverflow.com/questions/12977628/filetype-checking-arguments-passed-to-python-script-using-argparse
    :param value: path to csv file
    :return:
    """
    if not value.endswith('.csv'):
        raise argparse.ArgumentTypeError(
            'argument filename must be of type *.csv')
    return value


# default arguments
gnlm_columns = ['Ndeposition', 'Nirrigation', 'NgwDirect', 'NlandApplied', 'Nnorm', 'Nfertilizer', 'NmanureSale',
                'Nharvest', 'Nharvest_actual', 'Nrunoff_actual', 'Ngw', 'NatmLosses', 'Ngw_nondirect', 'Nseptic']

# full path to the current directory
wd = os.path.dirname(os.path.realpath(__file__))

# build the parser for the command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('gnlm_csv', help='CSV file with GNLM results with coordinates', type=csvfile)
parser.add_argument('-v', '--variables', nargs='+', help='GNLM variable column name to rasterize or defaults to ALL '
                                                         'variables if not provided. Try: {}'.format(', '.join(gnlm_columns)),
                    required=False, default=gnlm_columns)
parser.add_argument('-o', '--output_dir',
                    help='output directory for rasters. Default location is current working directory', default=wd)
parser.add_argument('-d', '--dryrun', help='Dry run. Creates vrt files but does not rasterize', action='store_true')
args = parser.parse_args()

# full path to the csv from the command line argument
csv_path = os.path.join(wd, args.gnlm_csv)

# create output folder if it does not already exist
if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)


def create_vrt(file, field, output_directory):
    """
    Creates a vrt file for a given field in the csv file -see https://gis.stackexchange.com/a/101994
    :param file: path to the csv file
    :param field: name of the field for the z value as a string
    :param output_directory: path to the output location
    :return: xml tree
    """
    # the basename of the csv file without the extension
    fn = os.path.splitext(os.path.basename(file))[0]

    # build the xml/vrt tree
    ds = ET.Element("OGRVRTDataSource")
    l = ET.SubElement(ds, "OGRVRTLayer", name=fn)

    ET.SubElement(l, "SrcDataSource").text = file
    ET.SubElement(l, "SrcLayer").text = fn
    ET.SubElement(l, "GeometryType").text = "wkbPoint"
    ET.SubElement(l, "LayerSRS").text = "EPSG:3310"
    ET.SubElement(l, "GeometryField", encoding="PointFromColumns", x="X", y="Y", z=field)

    # save the xml tree to disk
    tree = ET.ElementTree(ds)
    output_name = fn + "_" + field + ".vrt"  # output name is the filename + field
    out = os.path.join(output_directory, output_name)
    tree.write(out)
    return out


if args.dryrun:
    print("This is a dry run. Only .vrt files will be created.")
    print('Processing {} for the {} variable(s). Saving output at {}'.format(csv_path, args.variables, args.output_dir))
    for g in args.variables:
        vrt = create_vrt(csv_path, g, args.output_dir)

else:

    print('Processing {} for the {} variable(s). Saving output at {}'.format(csv_path, args.variables, args.output_dir))
    for g in args.variables:
        vrt = create_vrt(csv_path, g, args.output_dir)

        # construct the name for the ouptut geotiff
        fn = os.path.splitext(os.path.basename(csv_path))[0]
        output_tif = os.path.join(args.output_dir, fn + "_" + g + ".tif")

        # open command in a new window use /k to keep command windows open
        # os.system("start cmd /K gdal_rasterize --debug ON -a $field -tr 50 50 -ot Float32 $fn.vrt $output.tif -co BIGTIFF=YES")
        os.system(
            "start cmd /C gdal_rasterize --debug ON -a {} -tr 50 50 -ot Float32 {} {} -co BIGTIFF=YES -co COMPRESS=DEFLATE".format(
                g, vrt, output_tif))