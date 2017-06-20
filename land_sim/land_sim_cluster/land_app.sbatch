#!/bin/bash
#
# job name:
#######SBATCH --job-name='Land_sim'
#
# Number of tasks (cores):
#
#SBATCH --ntasks=1
# this works on slurm 2.6 and up ony SBATCH --array=1-16 $SLURM_ARRAY_TASK_ID
#
#SBATCH --output=Land_sim_%j.log
#SBATCH --error=Land_sim_%j.err
#
# Load your modules
#
#
# Set up your environment 
cd /nfs/aqua-z0/giorgk/GNLM/land_sim
#
# Start your MPI job
octave -p /nfs/aqua-z0/giorgk/GNLM/land_sim --eval "Simulate_land_app_main($iyear)";
### SLURM_LOCALID for srun
### use isub for sbatch
