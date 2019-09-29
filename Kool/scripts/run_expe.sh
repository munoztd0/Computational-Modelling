#!/bin/bash


#matlab_script="wrapper"
matlabSubmit="/home/davidM/Project/Kool/Kool/scripts/matlab_run.sh"
#codeDir="/home/davidM/Project/Kool/Kool/scripts/expe1"

# Loop over subjects
#for expe in experiment_1 experiment_2 experiment_3 experiment_4  #
#do

	#codeDir="~/Kool_2018/data/${expe}/model"
	#echo ${codeDir}
	#prep for each session's data
qsub -o /home/davidM/ClusterOutput -j oe -l walltime=50:40:00,pmem=8GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N ${matlabSubmit}

#done
