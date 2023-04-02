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
CASE_NAME=OCN2LND_sur_sub_${FORCING}_${SCENARIO}_spinup_${GIT_HASH}.`date "+%Y-%m-%d-%H%M%S"`

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
./xmlchange --file env_run.xml --id SSTICE_YEAR_START     --val 1951
./xmlchange --file env_run.xml --id SSTICE_YEAR_END       --val 1985
./xmlchange --file env_run.xml --id SSTICE_YEAR_ALIGN     --val 1951

./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val 1951
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END   --val 1985
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_ALIGN --val 1951

./xmlchange --file env_run.xml --id RUN_STARTDATE         --val 1951-01-01

./xmlchange PIO_BUFFER_SIZE_LIMIT=67108864
./xmlchange PIO_TYPENAME_OCN=netcdf # pnetcdf doesn't support NETCDF4
./xmlchange NTASKS=600
./xmlchange STOP_N=105,STOP_OPTION=nyears
./xmlchange JOB_WALLCLOCK_TIME=48:00:00
./xmlchange REST_N=5,REST_OPTION=nyears
./xmlchange JOB_QUEUE="slurm"

./preview_namelists

cat >> user_nl_cpl << EOF
ocn_lnd_one_way = .true.
EOF
cat >> user_nl_elm << EOF
fsurdat = '/compyfs/xudo627/lnd-docn-1way/inputdata/surfdata_global_coastline_merit_90m_calibrated_c221109.nc'
flndtopo = '/compyfs/xudo627/lnd-docn-1way/inputdata/surfdata_global_coastline_merit_90m_fd2.5_c221109.nc'
EOF
#finidat = '/compyfs/xudo627/e3sm_scratch/Calibration11_OCN2LND_sur_sub_coupling_463c45d.2023-01-13-102340/run/Calibration11_OCN2LND_sur_sub_coupling_463c45d.2023-01-13-102340.elm.r.2079-01-01-00000.nc'
#finidat = '/compyfs/xudo627/e3sm_scratch/Calibration09_OCN2LND_sur_sub_coupling_22493fc.2022-11-28-144612/run/Calibration09_OCN2LND_sur_sub_coupling_22493fc.2022-11-28-144612.elm.r.2079-01-01-00000.nc'

cat >> user_nl_datm << EOF
tintalgo = 'coszen', 'nearest', 'linear', 'linear', 'lower'
dtlimit=2.0e0,2.0e0,2.0e0,2.0e0,2.0e0
EOF

./case.setup
# ---------------------------------------------------------------------------- #
# **************************************************************************** #
# ---------------------------------------------------------------------------- #
files1=""
for i in {1951..1985}
do
   for j in {1..12}
   do
      if [ $j -lt 10 ]
      then
         files1="${files1}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.Prec.$i-0$j.nc\n"
      else
         if [ $i == 1985 ] && [ $j == 12 ]
         then
             files1="${files1}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.Prec.$i-$j.nc"
         else
             files1="${files1}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.Prec.$i-$j.nc\n"
         fi
      fi
   done
done

cp ${CASE_DIR}/${CASE_NAME}/CaseDocs/datm.streams.txt.CLMGSWP3v1.Precip ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip2
chmod +rw ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip2
sed '30,448d' ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip2 > ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip
rm ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip2
chmod +rw ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip

perl -w -i -p -e "s@/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/Precip@/compyfs/icom/xudo627/lnd-rof-2way-fut/data/forcings/${FORCING}/${SCENARIO}/Prec@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip
perl -w -i -p -e "s@/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516@/compyfs/xudo627/inputdata@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip
perl -w -i -p -e "s@domain.lnd.360x720_gswp3.0v1.c170606.nc@domain.lnd.360x720_isimip.3b.c211109.nc@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip
perl -w -i -p -e "s@clmforc.GSWP3.c2011.0.5x0.5.Prec.1951-01.nc@${files1}@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip
sed -i '/ZBOT/d' ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Precip
# ---------------------------------------------------------------------------- #
# **************************************************************************** #
# ---------------------------------------------------------------------------- #
files2=""
for i in {1951..1985}
do
   for j in {1..12}
   do
      if [ $j -lt 10 ]
      then
         files2="${files2}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.Solr.$i-0$j.nc\n"
      else
         if [ $i == 1985 ] && [ $j == 12 ]
         then
             files2="${files2}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.Solr.$i-$j.nc"
         else
             files2="${files2}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.Solr.$i-$j.nc\n"
         fi
      fi
   done
done

cp ${CASE_DIR}/${CASE_NAME}/CaseDocs/datm.streams.txt.CLMGSWP3v1.Solar ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar2
chmod +rw ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar2
sed '30,448d' ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar2 > ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar
rm ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar2
chmod +rw ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar

perl -w -i -p -e "s@/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/Solar@/compyfs/icom/xudo627/lnd-rof-2way-fut/data/forcings/${FORCING}/${SCENARIO}/Solr@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar
perl -w -i -p -e "s@/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516@/compyfs/xudo627/inputdata@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar
perl -w -i -p -e "s@domain.lnd.360x720_gswp3.0v1.c170606.nc@domain.lnd.360x720_isimip.3b.c211109.nc@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar
perl -w -i -p -e "s@clmforc.GSWP3.c2011.0.5x0.5.Solr.1951-01.nc@${files2}@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar
sed -i '/ZBOT/d' ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.Solar
# ---------------------------------------------------------------------------- #
# **************************************************************************** #
# ---------------------------------------------------------------------------- #
files3=""
for i in {1951..1985}
do
   for j in {1..12}
   do
      if [ $j -lt 10 ]
      then
         files3="${files3}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.TPQWL.$i-0$j.nc\n"
      else
         if [ $i == 1985 ] && [ $j == 12 ]
         then
             files3="${files3}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.TPQWL.$i-$j.nc"
         else
             files3="${files3}clmforc.${FORCING}.${SCENARIO}.c2107.0.5x0.5.TPQWL.$i-$j.nc\n"
         fi
      fi
   done
done

cp ${CASE_DIR}/${CASE_NAME}/CaseDocs/datm.streams.txt.CLMGSWP3v1.TPQW ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW2
chmod +rw ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW2
sed '27d' ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW2 > ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW3
rm ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW2
chmod +rw ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW3
sed '33,451d' ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW3 > ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW
rm ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW3
chmod +rw ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW

perl -w -i -p -e "s@/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/TPHWL@/compyfs/icom/xudo627/lnd-rof-2way-fut/data/forcings/${FORCING}/${SCENARIO}/TPQWL@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW
perl -w -i -p -e "s@/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516@/compyfs/xudo627/inputdata@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW
perl -w -i -p -e "s@domain.lnd.360x720_gswp3.0v1.c170606.nc@domain.lnd.360x720_isimip.3b.c211109.nc@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW
perl -w -i -p -e "s@clmforc.GSWP3.c2011.0.5x0.5.TPQWL.1951-01.nc@${files3}@" ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW
sed -i '/ZBOT/d' ${CASE_DIR}/${CASE_NAME}/user_datm.streams.txt.CLMGSWP3v1.TPQW
# ---------------------------------------------------------------------------- #
# **************************************************************************** #
# ---------------------------------------------------------------------------- #


./case.setup

./case.build

./case.submit