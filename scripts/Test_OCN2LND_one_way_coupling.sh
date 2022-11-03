RES=ELM_USRDAT
COMPSET=GTSM2ELM
MACH=compy
COMPILER=intel
PROJECT=esmd

SRC_DIR=~/e3sm_lnd_ocn_two_way
CASE_DIR=${SRC_DIR}/cime/scripts

cd ${SRC_DIR}/cime/scripts

GIT_HASH=`git log -n 1 --format=%h`
CASE_NAME=Test_OCN2LND_one_way_coupling_${GIT_HASH}.`date "+%Y-%m-%d-%H%M%S"`

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
./xmlchange LND_DOMAIN_PATH=/compyfs/xudo627/Land_Ocean_Coupling/inputdata
./xmlchange ATM_DOMAIN_PATH=/compyfs/xudo627/Land_Ocean_Coupling/inputdata

./xmlchange DOCN_GTSM_FILENAME=domain_global_coastline_merit_90m.nc

# Setup GTSM inundation and SLR forcings
./xmlchange --file env_run.xml --id SSTICE_YEAR_START --val 1981
./xmlchange --file env_run.xml --id SSTICE_YEAR_END --val 1981
./xmlchange --file env_run.xml --id SSTICE_YEAR_ALIGN --val 1981

./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val 1981
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END --val 1981
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_ALIGN --val 1981

./xmlchange --file env_run.xml --id RUN_STARTDATE --val 1981-01-01

./xmlchange NTASKS=400
./xmlchange STOP_N=10,STOP_OPTION=nyears
./xmlchange JOB_WALLCLOCK_TIME=20:00:00
./xmlchange JOB_QUEUE="slurm"

cat >> user_nl_cpl << EOF
ocn_lnd_one_way = .true.
EOF
cat >> user_nl_elm << EOF
fsurdat = '/compyfs/xudo627/Land_Ocean_Coupling/inputdata/surfdata_global_coastline_merit_90m_c220913.nc'
EOF

./case.setup
./case.build
./case.submit
















