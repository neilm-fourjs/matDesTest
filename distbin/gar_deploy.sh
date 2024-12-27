#!/bin/bash

GENVER=${GENVER:-500}

GAR=${1:-matDesTest$GENVER}

if [ ! -e ${GAR}.gar ]; then
	echo "Missing ${GAR}.gar !"
	exit 1
fi

# default
APPDATA=$FGLASDIR/appdata
# common alternatives
if [ -e /opt/Genero/gas${GENVER}_appdata ] ; then
	APPDATA=/opt/Genero/gas${GENVER}_appdata
fi
if [ -e /opt/Genero/gas${GENVER}_appdata ] ; then
	APPDATA=/opt/fourjs/gas${GENVER}_appdata
fi

CMD="$FGLASDIR/bin/gasadmin gar -E res.appdata.path=$APPDATA"

echo "$CMD --disable-archive $GAR"
$CMD --disable-archive $GAR
if [ $? -eq 0 ]; then
	echo "$CMD --undeploy-archive $GAR"
	$CMD --undeploy-archive $GAR
fi

#$CMD --list-archives

echo "$CMD --clean-archives"
$CMD --clean-archives --yes

echo "$CMD --deploy-archive $GAR.gar"
$CMD --deploy-archive $GAR.gar

if [ $? -eq 0 ]; then
	echo "$CMD --enable-archive $GAR"
	$CMD --enable-archive $GAR
else
	echo "Deploy Failed!"
fi
