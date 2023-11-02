#!/bin/bash
CP=$(cd $(dirname $0); pwd); CP=${CP#*/calc/}; CP=${CP%%/*}
CONDITION_PATH="/home/terao/calc/$CP/condition"
if [ ! -e $CONDITION_PATH ]; then
echo "qe_calc.sh:condition not found"; exit; fi
source $CONDITION_PATH

function ExecuteCalc(){
#CM: Calc Method  MN: Material Name
#scf.in or hr.datの名前からMNを取得
    if [ `ls -1 | grep '\.scf\.in' | wc -l` == 1 ]; then
        MN=`ls | grep '\.scf\.in'`; MN=${MN/%\.scf\.in}
    elif [ `ls -1 | grep '_hr\.dat' | wc -l` == 1 ]; then
        MN=`ls | grep '_hr\.dat'`; MN=${MN/%_hr\.dat}
    else
        echo "ExecuteCalc: MN not found"; exit 1
    fi

    for CM in "${Calc[@]}"; do
case $CM in
    'scf'     ) $qePREFIX/pw.x < $MN.$CM.in > $MN.$CM.out ;;
    'nscf'    ) $qePREFIX/pw.x < $MN.$CM.in > $MN.$CM.out ;;
    'dos'     ) $qePREFIX/dos.x < $MN.$CM.in > $MN.$CM.out ;;
    'projwfc' ) $qePREFIX/projwfc.x < $MN.$CM.in > $MN.$CM.out ;;
    'band'    ) $qePREFIX/bands.x < $MN.$CM.in > $MN.$CM.out ;;
    'pw2wan'  ) $qePREFIX/pw2wannier90.x < $MN.$CM.in > $MN.$CM.out ;;
    'nnkp'    ) $QE_PATH/$Wannier/wannier90.x -pp $MN ;;
    'w90'     ) $w9PREFIX/wannier90.x $MN ;;
    'pw90'    ) $w9PREFIX/postw90.x $MN ;;
    'wt'      ) $wtPREFIX/wt.x ;;
    'cp'[0-9] | 'cp'[1-9][0-9] | 'cp'[1-9][0-9][0-9] | 'cp'[1-9][0-9][0-9][0-9])
                Ncp=${CM##cp}
                if [ -n "${srfile[$Ncp]}" ] && [ -n "${cpfile[$Ncp]}" ]; then
                    cp $RESULT_PATH/${srfile[$Ncp]} $RESULT_PATH/${cpfile[$Ncp]}
                fi ;;
    *    )  exit ;;
esac
    done
}

InputDirList=$( ls -1 -F $INPUT_PATH | grep / | grep -v work) > /dev/null
ResultDirList=$( ls -1 -F $RESULT_PATH | grep / | grep -v work) > /dev/null

#InputにもResultにもdirがなければinputのファイルをresultにコピー
#dirが一つもないときはresultdirで直接計算する
#どちらかに1つでもdirがあればresultdirでwhile文を回し直下のdir全てに対し計算を行う

if [ "$InputDirList" = "" ] && [ "$ResultDirList" = "" ]; then
    while read fl; do
        if [ ! -e $RESULT_PATH/$fl ]; then
            cp -r $INPUT_PATH/$fl $RESULT_PATH/ ; fi
    done < <( ls -1 -F $INPUT_PATH | sed -e "s/work\//work/g" | grep -v / )
    cd $RESULT_PATH
    ExecuteCalc
else
    while read Dir; do
        if [ ! -e $RESULT_PATH/$Dir ]; then
            cp -r $INPUT_PATH/$Dir $RESULT_PATH/ ; fi
    done < <( ls -1 -F $INPUT_PATH | grep / )
    while read Dir; do
        if [ ${Dir:0:1} = "_" ]; then  continue; fi
        cd $RESULT_PATH/$Dir
        ExecuteCalc
    done < <( ls -1 -F $RESULT_PATH | grep / )
fi

