#!/bin/csh

#SBATCH --job-name=modify               ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd                  ## project_name
#SBATCH --time=40:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout10            ## job_output_filename
#SBATCH --error=mat.stderr10             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab  -nodisplay -nosplash <Script_10_Modify_inundation.m > Script_10_Modify_inundation.log
