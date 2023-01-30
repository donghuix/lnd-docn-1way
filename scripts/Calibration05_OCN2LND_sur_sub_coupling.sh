RES=ELM_USRDAT
COMPSET=GTSM2ELM
MACH=compy
COMPILER=intel
PROJECT=esmd

SRC_DIR=~/e3sm_lnd_ocn_two_way
CASE_DIR=${SRC_DIR}/cime/scripts


cd ${SRC_DIR} # make sure get correct hash of e3sm

GIT_HASH=`git log -n 1 --format=%h`
CASE_NAME=Calibration05_OCN2LND_sur_sub_coupling_${GIT_HASH}.`date "+%Y-%m-%d-%H%M%S"`

cd ${SRC_DIR}/cime/scripts

####create a case 
./create_newcase \
-case ${CASE_NAME} \
-res ${RES} \
-mach ${MACH} \
-compiler ${COMPILER} \
-compset ${COMPSET} --project ${PROJECT}

cd ${CASE_DIR}/${CASE_NAME}

./xmlchange --file env_run.xml --id DOUT_S             --val FALSE
./xmlchange --file env_run.xml --id INFO_DBUG          --val 2

./xmlchange LND_DOMAIN_FILE=domain_global_coastline_merit_90m.nc
./xmlchange ATM_DOMAIN_FILE=domain_global_coastline_merit_90m.nc
./xmlchange LND_DOMAIN_PATH=/compyfs/xudo627/lnd-docn-1way/inputdata
./xmlchange ATM_DOMAIN_PATH=/compyfs/xudo627/lnd-docn-1way/inputdata

./xmlchange DOCN_GTSM_FILENAME=domain_global_coastline_merit_90m.nc

# Setup GTSM inundation and SLR forcings
./xmlchange --file env_run.xml --id SSTICE_YEAR_START     --val 1951
./xmlchange --file env_run.xml --id SSTICE_YEAR_END       --val 2014
./xmlchange --file env_run.xml --id SSTICE_YEAR_ALIGN     --val 1951

./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val 1951
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END   --val 2014
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_ALIGN --val 1951

./xmlchange --file env_run.xml --id RUN_STARTDATE         --val 1951-01-01

./xmlchange PIO_BUFFER_SIZE_LIMIT=67108864
./xmlchange PIO_TYPENAME_OCN=netcdf # pnetcdf doesn't support NETCDF4
./xmlchange NTASKS=600
./xmlchange STOP_N=128,STOP_OPTION=nyears
./xmlchange JOB_WALLCLOCK_TIME=48:00:00
./xmlchange REST_N=32,REST_OPTION=nyears
./xmlchange JOB_QUEUE="slurm"

cat >> user_nl_cpl << EOF
ocn_lnd_one_way = .true.
EOF
cat >> user_nl_elm << EOF
fsurdat = '/compyfs/xudo627/lnd-docn-1way/inputdata/surfdata_global_coastline_merit_90m_fd1.0_c221109.nc'
flndtopo = '/compyfs/xudo627/lnd-docn-1way/inputdata/surfdata_global_coastline_merit_90m_fd2.5_c221109.nc'
EOF

./case.setup
./case.build
./case.submit
















