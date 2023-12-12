#!/bin/bash
CP=$(cd $(dirname $0); pwd); CP=${CP#*/calc/}; CP=${CP%%/*}
CP=/home/terao/calc/$CP/condition
if [ ! -e $CONDITION_PATH ]; then 
echo "exe.sh:condition not found"; exit; fi
source $CP

if $relax ; then
    bsub -e $RESULT_PATH/err.dat -n $Cores_num -m "aries$Aries_num" $RELAXSH_PATH
else 
    bsub -e $RESULT_PATH/err.dat -n $Cores_num -m "aries$Aries_num" $CALCSH_PATH

