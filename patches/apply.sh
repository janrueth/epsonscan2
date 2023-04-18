for patch in $(ls | grep ".patch$" | sort -t"-" -k1,1 -n)
do
    echo "Patching $patch"
    patch --verbose -d ../epsonscan2 -p1 < $patch
done