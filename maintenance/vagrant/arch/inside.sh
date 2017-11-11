#!/bin/bash

set -e

branch="$1"
if [ -z "$branch" ]; then
    branch=master
fi

thetest="$2"
if [ -z "$thetest" ]; then
    thetest="test"
fi

pyrockodir="pyrocko-$branch"
outfile_py3="/vagrant/test-$branch.py3.out"
outfile_py2="/vagrant/test-$branch.py2.out"

rm -f "$outfile_py3"
rm -f "$outfile_py2"

cd $HOME
sudo pacman -Syu --noconfirm --needed git python-setuptools python2-setuptools

if [ -e "$pyrockodir" ] ; then
    sudo rm -rf "$pyrockodir"
fi
git clone -b $branch "/vagrant/pyrocko.git" "$pyrockodir"
cd "$pyrockodir"
ln -s "/pyrocko-test-data" "test/data"

python setup.py install_prerequisites --force-yes && \
    sudo python setup.py install -f && \
    echo -n "Python Version: " >> "$outfile_py3" && \
    python --version >> "$outfile_py3" && \
    python -m pyrocko.print_version >> "$outfile_py3" && \
    nosetests "$thetest" > >(tee -a "$outfile_py3") 2> >(tee -a "$outfile_py3" >&2) || \
    /bin/true

prerequisites/prerequisites_arch_python2.sh && \
    sudo python2 setup.py install -f && \
    echo -n "Python Version: " >> "$outfile_py2" && \
    python2 --version 2>> "$outfile_py2" && \
    python2 -m pyrocko.print_version >> "$outfile_py2" && \
    nosetests2 "$thetest" > >(tee -a "$outfile_py2") 2> >(tee -a "$outfile_py2" >&2) || \
    /bin/true