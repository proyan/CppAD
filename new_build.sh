# ! /bin/bash 
# $Id: build.sh 1705 2010-09-23 11:46:10Z bradbell $
# -----------------------------------------------------------------------------
# CppAD: C++ Algorithmic Differentiation: Copyright (C) 2003-10 Bradley M. Bell
#
# CppAD is distributed under multiple licenses. This distribution is under
# the terms of the 
#                     Common Public License Version 1.0.
#
# A copy of this license is included in the COPYING file of this distribution.
# Please visit http://www.coin-or.org/CppAD/ for information on other licenses.
# -----------------------------------------------------------------------------
# These values can be changed.
CPPAD_DIR=$HOME/prefix/cppad
BOOST_DIR=/usr/include
ADOLC_DIR=$HOME/prefix/adolc
FADBAD_DIR=$HOME/prefix/fadbad
SACADO_DIR=$HOME/prefix/sacado
IPOPT_DIR=$HOME/prefix/ipopt
#
# library path for the ipopt and adolc
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ADOLC_DIR/lib:$IPOPT_DIR/lib"
# -----------------------------------------------------------------------------
# exit on error
set -e
# -----------------------------------------------------------------------------
# run multiple options in order
if [ "$2" != "" ]
then
     for option in $*
     do
          ./build.sh $option
     done
     exit 0
fi
# -----------------------------------------------------------------------------
# change version to current date
if [ "$1" = "version" ]
then
	echo "=================================================================="
	echo "begin: build.sh version"
	#
	# Today's date in yyyy-mm-dd decimal digit format where 
	# yy is year in century, mm is month in year, dd is day in month.
	yyyy_mm_dd=`date +%F`
	#
	# Version of cppad that corresponds to today.
	version=`echo $yyyy_mm_dd | sed -e 's|-||g'`
	#
	# automatically change version for certain files
	# (the [.0-9]* is for using build.sh in CppAD/stable/* directories)
	#
	# libtool does not seem to support version by date
	# sed < cppad_ipopt/src/makefile.am > cppad_ipopt/src/makefile.am.$$ \
	#	-e "s/\(-version-info\) *[0-9]\{8\}[.0-9]*/\1 $version/"
	#
	echo "sed -i.old AUTHORS ..."
	sed -i.old AUTHORS \
		-e "s/, [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} *,/, $yyyy_mm_dd,/"
	#
	echo "sed -i.old configure.ac ..."
	sed -i.old configure.ac \
		-e "s/(CppAD, [0-9]\{8\}[.0-9]* *,/(CppAD, $version,/" 
	#
	echo "sed -i.old configure ..."
	sed -i.old configure \
		-e "s/CppAD [0-9]\{8\}[.0-9]*/CppAD $version/g" \
		-e "s/VERSION='[0-9]\{8\}[.0-9]*'/VERSION='$version'/g" \
		-e "s/configure [0-9]\{8\}[.0-9]*/configure $version/g" \
		-e "s/config.status [0-9]\{8\}[.0-9]*/config.status $version/g" \
		-e "s/\$as_me [0-9]\{8\}[.0-9]*/\$as_me $version/g" \
        	-e "s/Generated by GNU Autoconf.*$version/&./"
	#
	echo "sed -i.old cppad/config.h ..."
	sed -i.old cppad/config.h \
		-e "s/CppAD [0-9]\{8\}[.0-9]*/CppAD $version/g" \
		-e "s/VERSION \"[0-9]\{8\}[.0-9]*\"/VERSION \"$version\"/g"
	#
	list="
		AUTHORS
		configure.ac
		configure
		cppad/config.h
	"
	for name in $list
	do
		echo "-------------------------------------------------------------"
		echo "build.sh: diff $name.old $name"
		if diff $name.old $name
		then
			echo "	no difference was found"
		fi
		#
		echo "build.sh: rm $name.old"
		rm $name.old
	done
	echo "-------------------------------------------------------------"
	#
	echo "end: build.sh version"
	exit 0
fi
# -----------------------------------------------------------------------------
# report build.sh usage error
if [ "$1" != "" ]
then
     echo "$1 is not a valid option"
fi
cat << EOF
usage: build.sh option_1 option_2 ...

options
-------
version:   update version in AUTHORS, configure.ac, configure, config.h
EOF
exit 1
