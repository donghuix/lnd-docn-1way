#!/bin/sh

RES=ELM_USRDAT
COMPSET=GTSM2ELM
MACH=compy
COMPILER=intel
PROJECT=esmd

FORCING=gfdl-esm4
SCENARIO=historical

SRC_DIR=~/e3sm_lnd_ocn_two_way
CASE_DIR=${SRC_DIR}/cime/scripts

cd ${SRC_DIR}

GIT_HASH=`git log -n 1 --format=%h`
CASE_NAME=OCN2LND_sur_sub_${FORCING}_${SCENARIO}_ssp585_SLR0.25_${GIT_HASH}.`date "+%Y-%m-%d-%H%M%S"`

cd ${SRC_DIR}/cime/scripts

./create_newcase -case ${CASE_DIR}/${CASE_NAME} \
-res ${RES} -mach ${MACH} -compiler ${COMPILER} -compset ${COMPSET} --project ${PROJECT}


cd ${CASE_DIR}/${CASE_NAME}

./xmlchange -file env_run.xml -id DOUT_S             -val FALSE
./xmlchange -file env_run.xml -id INFO_DBUG          -val 2

./xmlchange DATM_MODE=CLMGSWP3v1
./xmlchange CLM_USRDAT_NAME=test_r05_r05
./xmlchange LND_DOMAIN_FILE=domain_global_coastline_merit_90m.nc
./xmlchange ATM_DOMAIN_FILE=domain_global_coastline_merit_90m.nc
./xmlchange LND_DOMAIN_PATH=/compyfs/xudo627/lnd-docn-1way/inputdata
./xmlchange ATM_DOMAIN_PATH=/compyfs/xudo627/lnd-docn-1way/inputdata

./xmlchange DOCN_GTSM_FILENAME=domain_global_coastline_merit_90m.nc

# Setup GTSM inundation and SLR forcings
./xmlchange --file env_run.xml --id SSTICE_YEAR_START     --val 2016
./xmlchange --file env_run.xml --id SSTICE_YEAR_END       --val 2050
./xmlchange --file env_run.xml --id SSTICE_YEAR_ALIGN     --val 2016

./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val 1971
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END   --val 2005
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_ALIGN --val 1971

./xmlchange --file env_run.xml --id RUN_STARTDATE         --val 1971-01-01

./xmlchange PIO_BUFFER_SIZE_LIMIT=67108864
./xmlchange PIO_TYPENAME_OCN=netcdf # pnetcdf doesn't support NETCDF4
./xmlchange NTASKS=600
./xmlchange STOP_N=64,STOP_OPTION=nyears
./xmlchange JOB_WALLCLOCK_TIME=24:00:00
./xmlchange REST_N=32,REST_OPTION=nyears
./xmlchange JOB_QUEUE="slurm"

./preview_namelists

cat >> user_nl_cpl << EOF
ocn_lnd_one_way = .true.
EOF
cat >> user_nl_elm << EOF
fsurdat = '/compyfs/xudo627/lnd-docn-1way/inputdata/surfdata_global_coastline_merit_90m_calibrated_c221109.nc'
finidat = '/compyfs/xudo627/e3sm_scratch/OCN2LND_sur_sub_gfdl-esm4_historical_39b1f87.2022-12-05-220419/run/OCN2LND_sur_sub_gfdl-esm4_historical_39b1f87.2022-12-05-220419.elm.r.2015-01-01-00000.nc'
slr_offset = 0.25
hist_fincl2='QRUNOFF','QOVER','QDRAI'
hist_nhtfrq = 0,-24
hist_mfilt = 1,1
EOF

#finidat = '/compyfs/xudo627/e3sm_scratch/Calibration09_OCN2LND_sur_sub_coupling_22493fc.2022-11-28-144612/run/Calibration09_OCN2LND_sur_sub_coupling_22493fc.2022-11-28-144612.elm.r.2079-01-01-00000.nc'

cat >> user_nl_datm << EOF
tintalgo = 'coszen', 'nearest', 'linear', 'linear', 'lower'
dtlimit=2.0e0,2.0e0,2.0e0,2.0e0,2.0e0
EOF

./case.setup

./case.build

./case.submit