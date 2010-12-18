#!/bin/sh
# $Id: tagfile_generator.sh,v 1.6 2009/05/04 13:13:25 root Exp root $
# Eric Hameleers <alien@slackware.com>
# ---------------------------------------------------------------------------
# Description:
#  Generate a set of Slackware tagfiles that reflects the state of packages
#  currently installed on your system.
#  You can use these tagfiles in a subsequent installation of Slackware to
#  install an identical set of packages.
# Credits:
#  Using Daniel de Kok's code he posted in the LQ forum post:
#  http://www.linuxquestions.org/questions/showthread.php?t=493159
# ---------------------------------------------------------------------------

# Parse the commandline options:
while getopts "hs:d:" Option
do
  case $Option in
    s ) SRCDIR=${OPTARG}
        ;;
    d ) DSTDIR=${OPTARG}
        ;;
    h|* ) echo "Parameters are:"
        echo "  -h              This help."
        echo "  -s <slackdir>   The slackware root directory, below which"
        echo "                  you find the package directories a,ap,....y"
        echo "  -d <destdir>    Destination directory for generating tagfiles"
        exit
        ;;   # DEFAULT
  esac
done

# End of option parsing.
shift $(($OPTIND - 1))

#  $1 now references the first non option item supplied on the command line
#  if one exists.
# ---------------------------------------------------------------------------

SRCDIR=${SRCDIR:-~ftp/pub/Linux/Slackware/slackware-current/slackware}
DSTDIR=${DSTDIR:-$(pwd)}

PKGLOGDIR=${PKGLOGDIR:-/var/log/packages}

if [ ! -d $SRCDIR ]; then
  echo "Slackware source '$SRCDIR' does not exist!"
  exit 1
else
  echo "Using Slackware source '$SRCDIR'"
fi
if [ ! -d $DSTDIR ]; then
  echo "Destination '$DSTDIR' is not a directory!"
  exit 1
elif [ -f $DSTDIR/a/tagfile ]; then
  echo "I will not overwrite existing tagfiles in '$DSTDIR'!"
  exit 1
else
  echo "Writing tagfiles below '$DSTDIR'"
fi

# Copy original tagfiles from a Slackware directory tree:

for tagfile in $SRCDIR/*/tagfile; do 
  setdir=$(echo ${tagfile} | egrep -o '\w+/tagfile$' | xargs dirname)
  mkdir -p $DSTDIR/${setdir}
  cp ${tagfile} $DSTDIR/${setdir}/tagfile.org
  cp ${tagfile} $DSTDIR/${setdir}
done

# Write customized tagfiles, based on the actual installed packages:

for tforg in $DSTDIR/*/tagfile.org ; do
  tf=${tforg%.org}
  rm -f ${tf}
  for package in $(grep -v '^#' ${tforg} | cut -d ':' -f 1) ; do
    if [ -n "$(ls ${PKGLOGDIR}/${package}-* 2>/dev/null | rev | cut -d- -f4- | rev | grep "${PKGLOGDIR}/${package}$")" ] 2>&1 ; then 
      echo "${package}: ADD" >> ${tf}
    else
      echo "${package}: SKP" >> ${tf}
    fi
  done
done

