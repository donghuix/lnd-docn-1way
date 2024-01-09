#!/bin/csh

#SBATCH --job-name=step04               ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd                  ## project_name
#SBATCH --time=10:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout1            ## job_output_filename
#SBATCH --error=mat.stderr1             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab  -nodisplay -nosplash <Step_04_Caculate_Inundation_projection.m > Step_04_Caculate_Inundation_projection.log
