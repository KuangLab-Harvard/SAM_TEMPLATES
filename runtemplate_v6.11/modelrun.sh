#!/bin/sh 

##SBATCH -p test         # short jobs, time limit 8 hours
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

prmfile=[dirname]/SAMexp/prm/[prmname].prm
sndfile=[dirname]/SAMexp/snd/[sndname].snd
lsffile=[dirname]/SAMexp/lsf/[lsfname].lsf

cp $prmfile ./[csename]/prm
cp $sndfile ./[csename]/snd
cp $lsffile ./[csename]/lsf

cp $prmfile $prmloc
cp $sndfile $sndloc
cp $lsffile $lsfloc

scriptdir=$SLURM_SUBMIT_DIR
SAMname=`ls $scriptdir/SAM_*`
echo $case > CaseName

cd $scriptdir 
export OMPI_MCA_btl="self,openib"
unset I_MPI_PMI_LIBRARY
export I_MPI_JOB_RESPECT_PROCESS_PLACEMENT=0
mpirun -np $SLURM_NTASKS $SAMname > ./LOGS/samrun.${SLURM_JOBID}.log

exitstatus=$?
echo SAM stopped with exit status $exitstatus

exit 0
