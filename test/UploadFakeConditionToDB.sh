#!/bin/sh

#Script to upload in the DB the Fake Conditions
# please edit the connectsting and the DB tags (if needed)


export connectstring

connectstringA="sqlite_file:dbfile.db"
connectstringB="oracle://cms_orcoff_int2r/CMS_COND_STRIP"

tag_cabling=SiStripFedCabling_18X

tag_Noise=CSA07_SiStrip_Noise_v2


tag_Gain_Ideal=CSA07_SiStrip_Ideal_Gain_v2
tag_Gain_10invpb=CSA07_SiStrip_10invpb_Gain_v2
tag_Gain_100invpb=CSA07_SiStrip_100invpb_Gain_v2

tag_LA_Ideal=CSA07_SiStrip_Ideal_LAngle_v2
tag_LA_10invpb=CSA07_SiStrip_10invpb_LAngle_v2
tag_LA_100invpb=CSA07_SiStrip_100invpb_LAngle_v2
       



#--------------------------------------------------

[ "c$1" == "c" ] && echo -e "Please specify a DB connect string through command line, using the syntax\n\n\t $0 connectString  \n\n possible connect strings are \n\tsqlite: \t ${connectstringA} \n\toracle: \t ${connectstringB}"&& exit 

connectstring=$1

IsSqlite=0
if [ `echo ${connectstring} | grep -c sqlite` -ne 0 ]; then
    IsSqlite=1
    rm `echo ${connectstring} | sed -e "s@sqlite_file:@@"`
    cmscond_bootstrap_detector.pl --offline_connect ${connectstring} --auth /afs/cern.ch/cms/DB/conddb/authentication.xml STRIP
fi

[ ! -e log ] && mkdir log
[ ! -e cfg ] && mkdir cfg


# sed -e "s@insert_tag_cabling@${tag_cabling}@g" -e "s@insert_tag_Gain_100invpb@${tag_Gain_100invpb}@g" -e "s@insert_tag_Gain_10invpb@${tag_Gain_10invpb}@g" -e "s@insert_tag_Gain_Ideal@${tag_Gain_Ideal}@g" -e "s@insert_tag_Noise@${tag_Noise}@g" -e "s@insert_tag_LA_100invpb@${tag_LA_100invpb}@g" -e "s@insert_tag_LA_10invpb@${tag_LA_10invpb}@g" -e "s@insert_tag_LA_Ideal@${tag_LA_Ideal}@g"              



for file in `ls templateCFG/*template.cfg`
  do
  echo -e "\n template file $file"
  cfgfile=`basename $file | sed -e "s@_template.cfg@.cfg@"`
  cat $file | sed -e "s@insert_connectstring@${connectstring}@"  -e "s@insert_tag_cabling@${tag_cabling}@g" -e "s@insert_tag_Gain_100invpb@${tag_Gain_100invpb}@g" -e "s@insert_tag_Gain_10invpb@${tag_Gain_10invpb}@g" -e "s@insert_tag_Gain_Ideal@${tag_Gain_Ideal}@g" -e "s@insert_tag_Noise@${tag_Noise}@g" -e "s@insert_tag_LA_100invpb@${tag_LA_100invpb}@g" -e "s@insert_tag_LA_10invpb@${tag_LA_10invpb}@g" -e "s@insert_tag_LA_Ideal@${tag_LA_Ideal}@g" > cfg/$cfgfile

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
