#!/bin/bash

CP=$(cd $(dirname $0); pwd)
CONDITION_PATH="$CP/cifcalc_condition"
if [ ! -e $CONDITION_PATH ]; then 
echo "cifcalc_save.sh:condition not found"; exit 1; fi
source $CONDITION_PATH

flag=0
case $# in
'1'     ) New_Calc_Name=$1 ;;
*       ) echo "NewCalc: argument false"; flag=1 ;;
esac
if [ $flag -eq 1 ] ; then echo "fafa"; exit 1; fi

NP=$CALC_PATH/$New_Calc_Name
TP=$CALCTEMP_PATH

if [ -e $NP ]; then
    $MP/cifcalc_backup.sh "calc" $NP
    if [ $? -eq 1 ]; then echo 'backup failed'; exit 1; fi
fi

mkdir $NP
cp -r $TP/condition $TP/exe.sh $TP/qe_calc $NP/ 
mkdir $NP/result $NP/input

np=${NP//\//\\\/}
tp="calc_path_str"
cat $NP/condition | sed -e "s/$tp/$np/g" > $NP/tmp 
mv $NP/tmp $NP/condition

chmod u+x $NP/condition
chmod u+x $NP/exe.sh
chmod u+x $NP/qe_calc/qe_calc.sh


