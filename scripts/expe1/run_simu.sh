#!/bin/bash
home=$(eval echo ~$user);

codeDir="${home}/Project/Kool/scripts/expe"
matlab_script="recovery_sim"
matlabSubmit="${home}/Project/Kool/scripts/expe/matlab_run.sh"


# Loop over subjects
	#codeDir="~/Kool_2018/data/${expe}/model"
	#echo ${codeDir}
	#prep for each session's data

qsub -o ${home}/ClusterOutput -j oe -l walltime=20:40:00,pmem=8GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N simu -F "${codeDir} ${matlab_script}" ${matlabSubmit}
