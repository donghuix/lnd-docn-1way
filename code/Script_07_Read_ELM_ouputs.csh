#!/bin/csh

#SBATCH --job-name=read                 ## job_name
#SBATCH --partition=short
#SBATCH --account=esmd                  ## project_name
#SBATCH --time=02:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout5            ## job_output_filename
#SBATCH --error=mat.stderr5             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab  -nodisplay -nosplash <Script_07_Read_ELM_ouputs.m > Script_07_Read_ELM_ouputs.log
