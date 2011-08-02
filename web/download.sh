DEPARTMENTS=( "ACCT" "ANTH" "ARTH" "ARTS" "ASTR" "BIOL" "BLKS" "COMN" "CDSC" "DANC" "EDUC" "ENVR" "CHEM" "ECON" "ENGL" "CSCI" "GEOG" "GSCI" "HIST" "H&PE" "HONR" "HUMN" "INTD" "MATH" "PHYS" "THEA" "WRIT" "SOCI" "PLSC" "SPAN" "FREN" "JAPN" "GERM" "LATN" "ITAL" "RUSS" "CHIN" "ARBC" "MGMT" "MUSC" "PHIL" "PSYC" "WMST" )

URL="https://knightweb.geneseo.edu/banweb/owsocc.P_GetCrse"

for SUBJECT in "${DEPARTMENTS[@]}"
do
	POST="TERM=201109&sel_subj=dummy&sel_day=dummy&sel_schd=dummy&sel_camp=dummy&sel_sess=dummy&sel_instr=dummy&sel_ptrm=dummy&sel_attr=dummy&sel_subj=$SUBJECT&sel_crse=&sel_title=&sel_schd=%25&sel_crslvl=%25&sel_ptrm=%25&sel_instr=%25&sel_sess=%25&sel_attr=%25&begin_hh=0&begin_mi=0&begin_ap=a&end_hh=0&end_mi=0&end_ap=a"

	curl --sslv3 -d "$POST" $URL > "$SUBJECT.html"
done
