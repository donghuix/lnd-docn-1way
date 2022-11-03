#!/bin/csh

#SBATCH --job-name=fut   ## job_name
#SBATCH --partition=slurm
#SBATCH --account=esmd       ## project_name
#SBATCH --time=20:00:00                 ## time_limit
#SBATCH --nodes=1                       ## number_of_nodes
#SBATCH --ntasks-per-node=1             ## number_of_cores
#SBATCH --output=mat.stdout2            ## job_output_filename
#SBATCH --error=mat.stderr2             ## job_errors_filename

ulimit -s unlimited

python download_fut.py