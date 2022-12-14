#!/bin/csh

#SBATCH --job-name=step02               ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd                  ## project_name
#SBATCH --time=10:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout2            ## job_output_filename
#SBATCH --error=mat.stderr2             ## job_errors_filename

ulimit -s unlimited

module load matlab

matlab -nodisplay -nosplash <Step_02_Caculate_land_frac.m > Step_02_Caculate_land_frac.log
