#!/bin/bash

##### USAGE ######
# ./main.sh N
# where N = [1,5]
#1->1945, 2->1960, 3->1975, 4->1990, 5->2005
#

iyear=$1

export iyear
sbatch -n1 land_app.sbatch
