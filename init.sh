
for fn in $(ls /init.d/* | sort); do
    echo "found init file: $fn"
    source $fn
done



