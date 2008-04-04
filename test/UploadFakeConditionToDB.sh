#!/bin/sh

#Script to upload in the DB the Fake Conditions
# please edit the connectsting and the DB tags (if needed)


export connectstring

connectstringA="sqlite_file:dbfile.db"
connectstringB="oracle://cms_orcoff_int2r/CMS_COND_STRIP"

USER=CMS_COND_STRIP
PASSWD=SSWDC3MCAI8HQHTC

tag_cabling=SiStripFedCabling_20X_mc

tag_Noise=SiStripNoise_Fake_PeakMode_20X_mc

tag_Gain_Ideal=SiStripGain_Ideal_20X
tag_Gain_10invpb=SiStripGain_10invpb_20X_mc
tag_Gain_100invpb=SiStripGain_100invpb_20X_mc
tag_Gain_1invpb=SiStripGain_1invpb_20X_mc
tag_Gain_StartUp=SiStripGain_StartUp_20X_mc

tag_LA_Ideal=SiStripLorentzAngle_Ideal_20X
tag_LA_10invpb=SiStripLorentzAngle_10invpb_LAngle_20X
tag_LA_100invpb=SiStripLorentzAngle_100invpb_20X_mc
tag_LA_1invpb=SiStripLorentzAngle_1invpb_20X_mc
tag_LA_StartUp=SiStripLorentzAngle_StartUp_20X_mc
       

#--------------------------------------------------

[ "c$1" == "c" ] && echo -e "Please specify a DB connect string through command line, using the syntax\n\n\t $0 connectString  \n\n possible connect strings are \n\tsqlite: \t ${connectstringA} \n\toracle: \t ${connectstringB}"&& exit 

[ "c$2" == "c" ] && echo -e "Please specify what object you want to upload: Cabling, Noise, Gain, LorentzAngle or all\n to concatenate more then one object please use the regular expression \(A\)\|\(B\)\|\(C\)" && exit 

connectstring=$1
what=$2
[ "$what" == "all" ] && what="."

eval `scramv1 runtime -sh`

IsSqlite=0

[ `echo ${connectstring} | grep -c sqlite` -ne 0 ]  && IsSqlite=1 && rm `echo ${connectstring} | sed -e "s@sqlite_file:@@"`

if [ `echo ${connectstring} | grep -c sqlite` -ne 0 ]  || [[ `echo ${connectstring} | grep -c oracle` -ne 0  &&  "c$3" == "cforce" ]] ; then

echo -e "\n-----------\nCreating tables for db ${connectstring} \n-----------\n"
	cvs co CondTools/SiStrip/scripts/CreatingTables.sh
	CondTools/SiStrip/scripts/CreatingTables.sh $connectstring $USER  $PASSWD
fi


[ ! -e log ] && mkdir log
[ ! -e cfg ] && mkdir cfg


# sed -e "s@insert_tag_cabling@${tag_cabling}@g" -e "s@insert_tag_Gain_100invpb@${tag_Gain_100invpb}@g" -e "s@insert_tag_Gain_10invpb@${tag_Gain_10invpb}@g" -e "s@insert_tag_Gain_Ideal@${tag_Gain_Ideal}@g" -e "s@insert_tag_Noise@${tag_Noise}@g" -e "s@insert_tag_LA_100invpb@${tag_LA_100invpb}@g" -e "s@insert_tag_LA_10invpb@${tag_LA_10invpb}@g" -e "s@insert_tag_LA_Ideal@${tag_LA_Ideal}@g"              

for file in `ls templateCFG/*template.cfg | grep -i "$what"`
  do
  echo -e "\n template file $file"
  cfgfile=`basename $file | sed -e "s@_template.cfg@.cfg@"`
  #cat $file | sed -e "s@insert_connectstring@${connectstring}@"  -e "s@insert_tag_cabling@${tag_cabling}@g" -e "s@insert_tag_Gain_100invpb@${tag_Gain_100invpb}@g" -e "s@insert_tag_Gain_10invpb@${tag_Gain_10invpb}@g" -e "s@insert_tag_Gain_Ideal@${tag_Gain_Ideal}@g" -e "s@insert_tag_Noise@${tag_Noise}@g" -e "s@insert_tag_LA_100invpb@${tag_LA_100invpb}@g" -e "s@insert_tag_LA_10invpb@${tag_LA_10invpb}@g" -e "s@insert_tag_LA_Ideal@${tag_LA_Ideal}@g" > cfg/$cfgfile
  cat $file | sed -e "s@insert_connectstring@${connectstring}@"  -e "s@insert_tag_cabling@${tag_cabling}@g" -e "s@insert_tag_Gain_100invpb@${tag_Gain_100invpb}@g"  -e "s@insert_tag_Gain_1invpb@${tag_Gain_1invpb}@g"  -e "s@insert_tag_Gain_StartUp@${tag_Gain_StartUp}@g"  -e "s@insert_tag_Gain_10invpb@${tag_Gain_10invpb}@g" -e "s@insert_tag_Gain_Ideal@${tag_Gain_Ideal}@g" -e "s@insert_tag_Noise@${tag_Noise}@g" -e "s@insert_tag_LA_100invpb@${tag_LA_100invpb}@g" -e "s@insert_tag_LA_10invpb@${tag_LA_10invpb}@g" -e "s@insert_tag_LA_Ideal@${tag_LA_Ideal}@g" -e "s@insert_tag_LA_1invpb@${tag_LA_1invpb}@g" -e "s@insert_tag_LA_StartUp@${tag_LA_StartUp}@g"> cfg/$cfgfile

  echo -e "\n\n-----------------------\n... processing cmsRun cfg/$cfgfile \n-----------------------\n\n\n"
  cmsRun cfg/$cfgfile
  [ $? -ne 0 ] && echo -e "\n\nProblems processing $cfgfile \n\t please fix it and restart the script" && exit
  mv `ls -1 *.log | tail -1` log
done


echo -e "\n\nlist of tags in ${connectstring}\n---------------------------------\n"
if [ $IsSqlite -eq 1 ];
    then
    echo "select name from metadata;" | sqlite3 `echo ${connectstring} | sed -e "s@sqlite_file:@@"`
else
    echo "query to the oracle DB still to be implemented"
fi

echo -e "\n---------------------------------\n"
