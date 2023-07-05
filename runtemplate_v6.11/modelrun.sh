#!/bin/sh 

##SBATCH -p test         # short jobs, time limit 8 hours
##SBATCH -p huce_intel   # cheap, slower, no time limit
#SBATCH -p huce_cascade # expensive, faster, no time limit
##SBATCH -p huce_ice     # more expensive, much faster, no time limit
##SBATCH -p shared       # longer jobs, 7 days, use only when needed

#SBATCH -N 2 # number of nodes
#SBATCH -n 64 # number of cores
#SBATCH --mem-per-cpu=500 # memory pool for each core
#SBATCH -t 1-00:00 # time (D-HH:MM)

#SBATCH -J "SAM_run"
#SBATCH --mail-user=[email]
#SBATCH --mail-type=ALL
#SBATCH -o ./LOGS/samrun.%j.out # STDOUT
#SBATCH -e ./LOGS/samrun.%j.err # STDERR

module purge
module load intel/23.0.0-fasrc01 intelmpi/2021.8.0-fasrc01 netcdf-fortran/4.6.0-fasrc03

case=RCE
project=[project]
experiment=[experiment]
config=[config]
sndname=[sndname]
lsfname=[lsfname]

exproot=[directory]/[user]/$project/exp
prmfile=$exproot/prm/$experiment/${config}.prm
sndfile=$exproot/snd/$sndname
lsffile=$exproot/lsf/$lsfname

prmloc=./$case/prm
sndloc=./$case/snd
lsfloc=./$case/lsf

cp $prmfile $prmloc
cp $sndfile $sndloc
cp $lsffile $lsfloc

scriptdir=$SLURM_SUBMIT_DIR
SAMname=`ls $scriptdir/SAM_*`
echo $case > CaseName

cd $scriptdir 
export OMPI_MCA_btl="self,openib"
mpirun -np $SLURM_NTASKS $SAMname > ./LOGS/samrun.${SLURM_JOBID}.log

exitstatus=$?
echo SAM stopped with exit status $exitstatus

cd ./OUT_3D

for fcom3D in *.com3D
do
    if com3D2nc "$fbin3D" >& /dev/null
    then
        echo "Processing SAM com3D output file $fcom3D ... done"
        rm "$fcom3D"
    else
        echo "Processing SAM com3D output file $fcom3D ... failed"
    fi
done

for fcom2D in *.com2D
do
    if com2D2nc "$fbin2D" >& /dev/null
    then
        echo "Processing SAM com2D output file $fcom2D ... done"
        rm "$fcom2D"
    else
        echo "Processing SAM bin2D output file $fcom2D ... failed"
    fi
done

cd ../OUT_2D

for f2Dcom in *.2Dcom
do
    if 2Dcom2nc "$f2Dcom" >& /dev/null
    then
        echo "Processing SAM 2Dcom output file $f2Dcom ... done"
        rm "$f2Dcom"
    else
        echo "Processing SAM 2Dcom output file $f2Dcom ... failed"
    fi
done

cd ../OUT_STAT

for fstat in *.stat
do
    if stat2nc "$fstat" >& /dev/null
    then
        echo "Processing SAM STAT  output file $fstat ... done"
        rm "$fstat"
    else
        echo "Processing SAM STAT  output file $fstat ... failed"
    fi
done

cd ..

exit 0
