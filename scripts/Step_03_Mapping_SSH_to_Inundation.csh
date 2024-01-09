#!/bin/csh

#SBATCH --job-name=step03               ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd                  ## project_name
#SBATCH --time=30:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout3            ## job_output_filename
#SBATCH --error=mat.stderr3             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab -nodisplay -nosplash <Step_03_Mapping_SSH_to_Inundation.m > Step_03_Mapping_SSH_to_Inundation.log
