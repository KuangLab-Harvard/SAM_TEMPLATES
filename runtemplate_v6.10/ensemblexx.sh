#!/bin/sh 

##SBATCH -p test         # short jobs, time limit 8 hours
##SBATCH -p huce_intel   # cheap, slower, no time limit
#SBATCH -p huce_cascade # expensive, faster, no time limit
##SBATCH -p shared       # longer jobs, 7 days, use only when needed

#SBATCH -N 1 # number of nodes
#SBATCH -n 32 # number of cores
#SBATCH --mem-per-cpu=3GB # memory pool for each core
#SBATCH --hint=compute_bound
#SBATCH -t 2-00:00 # time (D-HH:MM)

#SBATCH -J "SAM_run"
#SBATCH --mail-user=[email]
#SBATCH --mail-type=ALL
#SBATCH -o ./LOGS/samrun.%j.out # STDOUT
#SBATCH -e ./LOGS/samrun.%j.err # STDERR

module purge
module load intel/23.0.0-fasrc01 intelmpi/2021.8.0-fasrc01 netcdf-c/4.9.2-fasrc01

case=RCE
project=[project]
experiment=[experiment]
config=[config]
sndname=[sndname]
lsfname=[lsfname]
ensemblemember=member[xx]

exproot=[directory]/[user]/$project/exp
prmfile=$exproot/prm/$experiment/$config/${ensemblemember}.prm
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

cd ./OUT_3D

for fbin3D in *$ensemblemember*.bin3D
do
    rm "$fbin3D"
done

for fbin2D in *$ensemblemember*.bin2D
do
    rm "$fbin2D"
done

cd ../OUT_2D

for f2Dbin in *$ensemblemember*.2Dbin
do
    rm "$f2Dbin"
done

cd ../OUT_STAT

for fstat in *$ensemblemember*.stat
do
    rm "$fstat"
done

cd ..

cd $scriptdir 
export OMPI_MCA_btl="self,openib"
time srun -n $SLURM_NTASKS --mpi=pmi2 --cpu_bind=cores --hint=compute_bound $SAMname > ./LOGS/samrun.${SLURM_JOBID}.log

exitstatus=$?
echo SAM stopped with exit status $exitstatus

cd ./OUT_3D

for fbin3D in *$ensemblemember*.bin3D
do
    if bin3D2nc "$fbin3D" >& /dev/null
    then
        echo "Processing SAM bin3D output file $fbin3D ... done"
        rm "$fbin3D"
    else
        echo "Processing SAM bin3D output file $fbin3D ... failed"
    fi
done

for fbin2D in *$ensemblemember*.bin2D
do
    if bin2D2nc "$fbin2D" >& /dev/null
    then
        echo "Processing SAM bin2D output file $fbin2D ... done"
        rm "$fbin2D"
    else
        echo "Processing SAM bin2D output file $fbin2D ... failed"
    fi
done

cd ../OUT_2D

for f2Dbin in *$ensemblemember*.2Dbin
do
    if 2Dbin2nc "$f2Dbin" >& /dev/null
    then
        echo "Processing SAM 2Dbin output file $f2Dbin ... done"
        rm "$f2Dbin"
    else
        echo "Processing SAM 2Dbin output file $f2Dbin ... failed"
    fi
done

cd ../OUT_STAT

for fstat in *$ensemblemember*.stat
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
