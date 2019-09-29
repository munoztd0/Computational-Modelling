#!/bin/bash

echo "Bash version ${BASH_VERSION}..."

#PBS -q default
#PBS -l nodes=1
#PBS -l walltime=4:00:00
#PBS -m ae
#PBS -M david.munoz@etu.unige.ch

#MATLAB=/usr/local/MATLAB/R2017a/bin/matlab

#PBS_O_WORKDIR=$1

#echo Working directory is '/home/davidM/Project/Kool/Kool/scripts/expe1
cd /home/davidM/Project/Kool/scripts/expe1

NPROCS=`wc -l < $PBS_NODEFILE`

#echo /usr/local/MATLAB/R2017a/bin/matlab -nojvm -nodisplay -nosplash -r "wrapper(); exit"
/usr/local/MATLAB/R2017a/bin/matlab -nojvm -nodisplay -nosplash -r "B_recovery_sim(); exit"
