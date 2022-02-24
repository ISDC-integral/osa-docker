echo -e "\033[35mrunning test suit\033[0m"

echo "OSA_TESTS_EXCLUDE=${OSA_TESTS_EXCLUDE:=slow}"
echo "OSA_TESTS_LIMIT=${OSA_TESTS_LIMIT:=test}"

for t in $(ls $PWD/test_*.sh); do 
    echo -e "running \033[33m$t\033[0m"
    echo $t | grep $OSA_TESTS_EXCLUDE > /dev/null && { echo -e "\033[36mskipping test $t as we exclude $OSA_TESTS_EXCLUDE\033[0m"; continue;}
    echo $t | grep $OSA_TESTS_LIMIT > /dev/null || { echo -e "\033[36mskipping test $t as we limit to $OSA_TESTS_LIMIT\033[0m"; continue;}
    (
        TESTDIR=${TMPDIR:-/tmp}/${t//\//_}
        mkdir -pv $TESTDIR
        cd $TESTDIR
        bash $t
    )
done
