# kakathic

checkYT(){
for Tkvi in $( find /data/app | grep com.google.android.youtube | grep 'base.apk' ); do
[ "$Tkvi" ] && su -mm -c umount -l "$Tkvi"
done
for Vhkdd in $(find /data/app -name *com.google.android.youtube*); do
[ "$Vhkdd" ] && rm -fr "$Vhkdd"
done
}

installYT(){
chcon u:object_r:apk_data_file:s0 $1
[ $(pm install -r $1 | grep -cm1 'Success') == 1 ] && inYT="done" || inYT="failure"
[ "$inYT" == "failure" ] && pm uninstall com.google.android.youtube >&2
[ $(pm install -r $1 | grep -cm1 'Success') == 1 ] && inYT="done" || inYT="failure"
[ "$inYT" == "done" ] || abort "- Error cannot install apk"; }

linkAPK(){ pm path com.google.android.youtube | grep base | cut -d : -f2; }

cpLIB(){ cp -af $1 ${2%/*}; }

mountYT(){
chcon u:object_r:apk_data_file:s0 "$1"
su -mm -c mount -o bind "$1" "$2"
cmd package compile -m speed com.google.android.youtube >&2; }

offCH(){
Sqlite3=$MODPATH/sqlite3
PS=com.android.vending
DB=/data/data/$PS/databases
LDB=$DB/library.db
LADB=$DB/localappstate.db
PK=com.google.android.youtube
GET_LDB=$($Sqlite3 $LDB "SELECT doc_id,doc_type FROM ownership" | grep $PK | head -n 1 | grep -o 25)
if [ "$GET_LDB" != "25" ]; then
cmd appops set --uid $PS GET_USAGE_STATS ignore
pm disable $PS >&2
sqlite3 $LDB "UPDATE ownership SET doc_type = '25' WHERE doc_id = '$PK'";
sqlite3 $LADB "UPDATE appstate SET auto_update = '2' WHERE package_name = '$PK'";
rm -rf /data/data/$PS/cache/*
pm enable $PS >&2
fi; }