#!/bin/bash
home=$(eval echo ~$user);

codeDir="${home}/Project/Mael"
matlab_script="RUN_simu_model_recovery"
matlabSubmit="${home}/Project/Mael/scripts/matlab_run.sh"


# Loop over subjects
	#codeDir="~/Kool_2018/data/${expe}/model"
	#echo ${codeDir}
	#prep for each session's data

qsub -o ${home}/ClusterOutput -j oe -l walltime=24:40:00,pmem=8GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N simu -F "${codeDir} ${matlab_script}" ${matlabSubmit}
