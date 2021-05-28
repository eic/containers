#!/bin/bash

CONTAINER="jug_dev"
VERSION="testing"
ODIR="$PWD"

function print_the_help {
  echo "USAGE:  ./install_dev.sh [-o DIR] [-v VERSION]"
  echo "OPTIONAL ARGUMENTS:"
  echo "          -o,--outdir     Directory to download the container to (D: $ODIR)"
  echo "          -v,--version    Version to install (D: $VERSION)"
  echo "          -h,--help       Print this message"
  echo ""
  echo "  Download development container into an output directory"
  echo ""
  echo "EXAMPLE: ./install.sh" 
  exit
}

while [ $# -gt 0 ]; do
  key=$1
  case $key in
    -o|--outdir)
      ODIR=$2
      shift
      shift
      ;;
    -v|--version)
      VERSION=$2
      shift
      shift
      ;;
    -h|--help)
      print_the_help
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $key"
      echo "use --help for more info"
      exit 1
      ;;
  esac
done

mkdir -p $ODIR || exit 1

if [ ! -d $ODIR ]; then
  echo "ERROR: not a valid directory: $ODIR"
  echo "use --help for more info"
  exit 1
fi

echo "Deploying development container for eicweb/$CONTAINER:$VERSION to $ODIR"

## Simple setup script that installs the container
## in your local environment under $ODIR/local/lib
## and creates a simple top-level launcher script
## that launches the container for this working directory
## with the $ATHENA_ODIR variable pointing
## to the $ODIR/local directory

mkdir -p local/lib || exit 1

## Always deploy the SIF image using the python installer, 
## as this is for experts only anyway
SIF=

## work in temp directory
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
pushd $tmp_dir
wget https://eicweb.phy.anl.gov/containers/eic_container/-/raw/master/install.py
chmod +x install.py
./install.py -f -c $CONTAINER -v $VERSION .

SIF=`ls lib/$CONTAINER.sif.* | head -n1`

## That's all
if [ -z $SIF -o ! -f $SIF ]; then
  echo "ERROR: no singularity image found"
else
  echo "Container download succesfull"
fi

## move over the container to our output directory
mv $SIF $ODIR
## cleanup
popd
rm -rf $tmp_dir
