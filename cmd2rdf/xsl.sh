#!/bin/bash

JAVA="java"
READLINK="greadlink"

export LANG=en_US.UTF-8

# Do not assume the script is invoked from the directory it is located in; get
# the directory the script is located in
thisDir="$(dirname "$(${READLINK} -f "$0")")"

# Get Saxon
if [ ! -f ${thisDir}/saxon-he-10.5.jar ]; then
    wget -O SaxonHE10-5J.zip https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/SaxonHE10-5J.zip/download
    unzip SaxonHE10-5J.zip saxon-he-10.5.jar
    rm SaxonHE10-5J.zip
    if [ ! -f ${thisDir}/saxon-he-10.5.jar ]; then
        mv saxon-he-10.5.jar ${thisDir}/saxon-he-10.5.jar
    fi
fi
JAR=${thisDir}/saxon-he-10.5.jar

${JAVA} -jar ${JAR} $*

exit $?