
for t in $(ls $PWD/test_*.sh); do 
    ls -l $t;
    (
        TESTDIR=${TMPDIR:-/tmp}/${t//\//_}
        mkdir -pv $TESTDIR
        cd $TESTDIR
        bash $t
    )
done
