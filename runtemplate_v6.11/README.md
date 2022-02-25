# Templates for Building and Running SAM v6.11

This folder is a template of all that is needed (except for the RUNDATA and UTIL files) to run the System of Atmospheric Modelling (SAM) v6.11 on the Harvard Cluster.

Below are the instructions:

## 0. Setup of Run Template Folder

A. Clone the `SAM` repository, unzip the `RUNDATA.zip` folder.
B. Create a symlink with the unzipped `RUNDATA` folder in the `runtemplate` folders
C. Run the Makefile in `SAM/UTIL`

## 1. Modify `Build.csh`:

In the file `Build.csh`, you need to set the variables `SAM_SCR` and `SAM_SRC` in the following lines:
Line 7:  `setenv SAM_SCR (point_to_your_data_directory_preferably_on_scratch)`
Line 46: `setenv SAM_SRC (point_to_the_SRC_dir_for_v6.10)`

As you can probably guess from the above:
* `SAM_SCR` is the scratch directory where your data (`OUT_*`) will be saved into
* `SAM_SRC` is the `SRC` directory containing the model codes for SAM v6.10(UW)

## 2. Run `Build`

Execute `./Build`

## 3. Modify files in `SAM/exp`

Inside the `SAM/exp` folder contains an organization template for `prm`, `snd` and `lsf` directories and files.  Options in `[]` brackets **_must_** be modified or commented out as needed depending on the names of the overall project, experiment name, and configuration.

## 4. Modify `modelrun.sh` and `ensemblexx.sh` as needed

Both `modelrun.sh` and `ensemblexx.sh` are SLURM submission scripts whose `#SBATCH` options should be modified as needed.

Options in `[]` brackets **_must_** also be modified or commented out as needed.

## 5. Submit the scripts `modelrun.sh`/`ensemblexx.sh` to the cluster