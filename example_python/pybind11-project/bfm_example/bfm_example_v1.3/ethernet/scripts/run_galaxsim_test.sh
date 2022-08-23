#!/bin/bash

env_set()
{
    SCRIPT_PATH=$(dirname $(readlink -f "$0"))
    export OUTPUT_PATH=${SCRIPT_PATH}/../output/galaxsim
    export SOURCE_PATH=${SCRIPT_PATH}/../src
    export LOG_PATH=${SCRIPT_PATH}/../log/galaxsim
}

check_env()
{
    if [ ! -n "$XSIM_HOME" ]; then
        echo "env \"XSIM_HOME\" not defined"
        exit 2;
    fi

    if [ ! -f "$XSIM_HOME/bin/galaxsim" ]; then
        echo "file $XSIM_HOME/bin/galaxsim not exist"
        exit 2;
    fi
}

remove()
{
    if [ -d $1 ]; then
        rm -Rf $1
    fi

    if [ -f $1 ]; then
        rm $1
    fi
}

fi_assert()
{
    ret=$1

    if [ "$ret" -ne "0" ]; then
        echo "error ret($ret)"
        exit $ret
    fi
}

pre_compile()
{
    check_env

    remove $OUTPUT_PATH
    mkdir -p $OUTPUT_PATH
    remove $LOG_PATH
    mkdir -p $LOG_PATH
}

compile()
{
    env_set
    pre_compile
    local compile_rtl="-F $SOURCE_PATH/bench/run-rtl.flist"
    local compile_all="-F $SOURCE_PATH/bench/run.flist"
    pushd $OUTPUT_PATH > /dev/null
    $XSIM_HOME/bin/galaxsim -O $OUTPUT_PATH/xsim $1 +incdir+$SOURCE_PATH/bench +incdir+$SOURCE_PATH/rtl $compile_all > $LOG_PATH/compile.log 2>&1
    fi_assert $ret
    popd > /dev/null
    echo "compile finish"
    echo "log_path:$LOG_PATH/compile.log"
}

run()
{
    env_set
    local ret=0
    pushd $OUTPUT_PATH > /dev/null
    $OUTPUT_PATH/xsim $1 >> $LOG_PATH/run.log 2>&1
    ret=$?
    fi_assert $ret
    popd > /dev/null
    echo "run finish"
    echo "log_path:$LOG_PATH/run.log"
}

case $1 in
compile)
    compile "${@:2}"
    ;;
run)
    run "${@:2}"
    ;;
*)
    echo "$0 (compile|run)"
    exit 1
    ;;
esac

exit 0
