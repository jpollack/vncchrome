#!/bin/bash

VNC_PORT=5900
CRD_PORT=9222
GEOMETRY="1280x1024"
FULLSCREEN=
DATA_DIR=

while getopts 'fv:c:g:d:h' opt ; do
    case "$opt" in
	d)
	    DATA_DIR="$OPTARG"
	    ;;
	
	f)
	    FULLSCREEN="--start-fullscreen"
	    ;;
	
	v)
	    VNC_PORT="$OPTARG"
	    ;;

	c)
	    CRD_PORT="$OPTARG"
	    ;;

	g)
	    GEOMETRY="$OPTARG"
	    ;;

	?|h)
	    echo "Usage: $0 [-f] [-d DATA_DIR] [-v VNC_PORT] [-c CRD_PORT] [-g GEOMETRY]"
	    exit 1
	    ;;
	esac
    done

IMGNAME=vncchrome

podman image exists $IMGNAME || podman image build --jobs 6 --tag $IMGNAME --file vncchrome.containerfile .
CNTNAME=$(podman container create --env GEOMETRY=$GEOMETRY --rm --quiet -p $VNC_PORT:5900 -p $CRD_PORT:9222 $IMGNAME)
exec podman start --interactive --attach $CNTNAME
