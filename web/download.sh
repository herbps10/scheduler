#!/bin/bash

DEPARTMENTS=( "ACCT" "ANTH" "ARTH" "ARTS" "ASTR" "BIOL" "BLKS" "COMN" "CDSC" "DANC" "EDUC" "ENVR" "CHEM" "ECON" "ENGL" "CSCI" "GEOG" "GSCI" "HIST" "H&PE" "HONR" "HUMN" "INTD" "MATH" "PHYS" "THEA" "WRIT" "SOCL" "PLSC" "SPAN" "FREN" "JAPN" "GERM" "LATN" "ITAL" "RUSS" "CHIN" "ARBC" "MGMT" "MUSC" "PHIL" "PSYC" "WMST" )

URL="https://knightweb.geneseo.edu/banweb/owsocc.P_GetCrse"
DETAILS_URL="https://knightweb.geneseo.edu/banweb/bwckctlg.p_display_courses"

TIME=`date +"%m-%d-%y;%T"`
mkdir "data/$TIME/"

rm ./data/most-recent
ln -s "data/$TIME/" ./data/most-recent

for SUBJECT in "${DEPARTMENTS[@]}"
do
	echo $SUBJECT

	POST="TERM=201201&sel_subj=dummy&sel_day=dummy&sel_schd=dummy&sel_camp=dummy&sel_sess=dummy&sel_instr=dummy&sel_ptrm=dummy&sel_attr=dummy&sel_subj=$SUBJECT&sel_crse=&sel_title=&sel_schd=%25&sel_crslvl=%25&sel_ptrm=%25&sel_instr=%25&sel_sess=%25&sel_attr=%25&begin_hh=0&begin_mi=0&begin_ap=a&end_hh=0&end_mi=0&end_ap=a"

	DETAILS_POST="term_in=201201&sel_subj=dummy&sel_levl=dummy&sel_schd=dummy&sel_coll=dummy&sel_divs=dummy&sel_dept=dummy&sel_attr=dummy&sel_subj=$SUBJECT&sel_crse_strt=&sel_crse_end=&sel_title=&sel_levl=%25&sel_schd=%25&sel_coll=%25&sel_divs=%25&sel_dept=%25&sel_from_cred=&sel_to_cred=&sel_attr=%25"

	echo "Course Data"
	curl --sslv3 -d "$POST" $URL > "data/$TIME/$SUBJECT.html"

	echo "Details"
	curl --sslv3 -d "$DETAILS_POST" $DETAILS_URL > "data/$TIME/$SUBJECT-details.html"
done
