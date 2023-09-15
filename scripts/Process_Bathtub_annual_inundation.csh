#!/bin/csh

#SBATCH --job-name=annual               ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd                  ## project_name
#SBATCH --time=30:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout3            ## job_output_filename
#SBATCH --error=mat.stderr3             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab  -nodisplay -nosplash <Process_Bathtub_annual_inundation.m > Process_Bathtub_annual_inundation.log
