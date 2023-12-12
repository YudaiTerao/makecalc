#!/bin/bash
CP=$(cd $(dirname $0); pwd); CP=${CP#*/calc/}; CP=${CP%%/*}
CONDITION_PATH="/home/terao/calc/$CP/condition"
if [ ! -e $CONDITION_PATH ]; then
echo "qe_calc.sh:condition not found"; exit; fi
source $CONDITION_PATH

function relaxCalc(){
    if [ `ls -1 | grep '\.scf\.in' | wc -l` == 1 ]; then
        MN=`ls | grep '\.scf\.in'`; MN=${MN/%\.scf\.in}
    else
        echo "relax.sh: MN not found"; exit 1
    fi

if [[ "$lc2" == false ]]; then
for ((i=${iter1[0]}*-1; i<=${iter1[1]}; i+=1)) do
    thislc1=`python -c "print('{:.10f}'.format($lc1+$step1*$i))"`
    echo $thislc1
    fn_pfx=${thislc1}

    sed "s/lc1/$thislc1/g" $MN.scf.in > ${fn_pfx}.scf.in
    $qePREFIX/pw.x < $fn_pfx.scf.in > $fn_pfx.scf.out &&
    mv ${fn_pfx}.scf.in  ${fn_pfx}_scf_in
    mv ${fn_pfx}.scf.out ${fn_pfx}_scf_out
done

else
for ((i=${iter1[0]}*-1; i<=${iter1[1]}; i+=1)) do
    thislc1=`python -c "print('{:.10f}'.format($lc1+$step1*$i))"`
for ((j=${iter2[0]}*-1; j<=${iter2[1]}; j+=1)) do
    thislc2=`python -c "print('{:.10f}'.format($lc2+$step2*$j))"`

    echo $thislc1,$thislc2
    fn_pfx=${thislc1}_${thislc2}

    sed "s/lc1/$thislc1/g" $MN.scf.in | sed "s/lc2/$thislc2/g" > ${fn_pfx}.scf.in
    $qePREFIX/pw.x < $fn_pfx.scf.in > $fn_pfx.scf.out &&
    mv ${fn_pfx}.scf.in  ${fn_pfx}_scf_in
    mv ${fn_pfx}.scf.out ${fn_pfx}_scf_out
done; done
fi
}


while read fl; do
    if [ ! -e $RESULT_PATH/$fl ]; then
        cp -r $INPUT_PATH/$fl $RESULT_PATH/ ; fi
done < <( ls -1 -F $INPUT_PATH | grep -v / )
cd $RESULT_PATH
relaxCalc


