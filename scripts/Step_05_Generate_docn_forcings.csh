#!/bin/csh

#SBATCH --job-name=step05               ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd                  ## project_name
#SBATCH --time=20:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout5            ## job_output_filename
#SBATCH --error=mat.stderr5             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab  -nodisplay -nosplash <Step_05_Generate_docn_forcings.m > Step_05_Generate_docn_forcings.log
