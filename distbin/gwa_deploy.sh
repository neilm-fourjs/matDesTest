
#!/bin/bash

GENVER=${GENVER:-501}

GWA=${1:-matDesTest$GENVER}

if [ ! -e ${GWA}.gwa ]; then
	echo "Missing ${GWA}.gwa !"
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

CMD="$FGLASDIR/bin/gasadmin gwa -E res.appdata.path=$APPDATA"

echo "$CMD --undeploy-archive $GWA"
$CMD --undeploy-archive $GWA

#$CMD --list-archives

echo "$CMD --deploy-archive $GWA.gwa"
$CMD --deploy-archive $GWA.gwa

if [ $? -eq 0 ]; then
	echo "Deployed GWA $GWA"
else
	echo "Deploy Failed!"
fi

