#!/bin/sh

if [ $# -lt 3 ]
then
	echo "<Usage:  $0  App  Server  Servant>"
	exit 0
fi

APP=$1
SERVER=$2
SERVANT=$3

if [ "$SERVER" == "$SERVANT" ]
then
	echo "Error!(ServerName == ServantName)"
	exit -1
fi

if [ ! -d $APP/$SERVER/src ]
then
	echo "[mkdir: $APP/$SERVER/src]"
	mkdir -p $APP/$SERVER/src
	echo "[mkdir: $APP/$SERVER/build]"
	mkdir -p $APP/$SERVER/build
fi

echo "[create server: $APP.$SERVER ...]"

DEMO_PATH=c:/tars/cpp/script/cmake_demo

cp -rf $DEMO_PATH/* $APP/$SERVER

SRC_FILE="DemoServer.h DemoServer.cpp DemoServantImp.h DemoServantImp.cpp DemoServant.tars CMakeLists.txt ../CMakeLists.txt"

cd $APP/$SERVER/src

for FILE in $SRC_FILE
do
	cat $FILE | sed "s/DemoServer/$SERVER/g" > $FILE.tmp
	mv $FILE.tmp $FILE

	cat $FILE | sed "s/DemoApp/$APP/g" > $FILE.tmp
	mv $FILE.tmp $FILE
	
	cat $FILE | sed "s/DemoServant/$SERVANT/g" > $FILE.tmp
	mv $FILE.tmp $FILE
done

mv DemoServer.h ${SERVER}.h
mv DemoServer.cpp ${SERVER}.cpp
mv DemoServantImp.h ${SERVANT}Imp.h
mv DemoServantImp.cpp ${SERVANT}Imp.cpp
mv DemoServant.tars ${SERVANT}.tars

cd ..\\build
cmake .. -DCMAKE_BUILD_TYPE=Release

echo "[done.]"
