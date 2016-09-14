#!/bin/sh
#
# Make an IPP Everywhere Printer self-certification package.
#
# Copyright 2014-2016 by the ISTO Printer Working Group.
# Copyright 2007-2013 by Apple Inc.
# Copyright 1997-2007 by Easy Software Products, all rights reserved.
#
# These coded instructions, statements, and computer programs are the
# property of Apple Inc. and are protected by Federal copyright
# law.  Distribution and use rights are outlined in the file "LICENSE.txt"
# which should have been included with this file.  If this file is
# file is missing or damaged, see the license at "http://www.cups.org/".
#

# Make sure we are running in the right directory...
if test ! -f scripts/make-ippeveselfcert.sh; then
        echo "Run this script from the top-level source directory, e.g.:"
        echo ""
        echo "    scripts/make-ippeveselfcert.sh $*"
        echo ""
        exit 1
fi

if test $# -gt 2; then
	echo "Usage: everywhere/make-ippeveselfcert.sh [yyyymmdd] [platform]"
	exit 1
fi

pkgname="ippeveselfcert10"
if test $# -gt 0; then
	fileversion="$1"
else
	fileversion="`date +%Y%m%d`"
fi
if test $# = 2; then
	platform="$2"
else
	case `uname` in
		Darwin)
			platform="macos"
			;;

		Linux)
			if test -x /usr/bin/dpkg; then
				platform="ubuntu"
			else
				platform="rhel"
			fi
			;;

		*)
			platform=`uname`
			;;
	esac
fi

echo Creating package directory...
pkgdir="sw-$pkgname-$fileversion"

test -d $pkgdir && rm -r $pkgdir
mkdir $pkgdir || exit 1

echo Copying package files
cp LICENSE.txt $pkgdir
cp doc/man-ipp*.html $pkgdir
cp tests/README.txt $pkgdir
cp tests/*.jpg $pkgdir
cp tests/*.pdf $pkgdir
cp tests/*.sh $pkgdir
cp tests/*.test $pkgdir
cp tools/ippfind $pkgdir/ippfind
cp tools/ippserver $pkgdir
cp tools/ipptool $pkgdir/ipptool
cp tools/printer.png $pkgdir

chmod +x $pkgdir/*.sh

if test x$platform = xosx; then
	# Sign executables...
	if test "x$CODESIGN_IDENTITY" = x; then
		CODESIGN_IDENTITY="IEEE INDUSTRY STANDARDS AND TECHNOLOGY ORGANIZATION"
	fi

	codesign -s "$CODESIGN_IDENTITY" -fv $pkgdir/ippfind
	codesign -s "$CODESIGN_IDENTITY" -fv $pkgdir/ippserver
	codesign -s "$CODESIGN_IDENTITY" -fv $pkgdir/ipptool

	# Make ZIP archive...
	pkgfile="$pkgdir-osx.zip"
	echo Creating ZIP file $pkgfile...
	test -f $pkgfile && rm $pkgfile
	zip -r9 $pkgfile $pkgdir || exit 1
else
	# Make archive...
	pkgfile="$pkgdir-$platform.tar.gz"
	echo Creating archive $pkgfile...
	tar czf $pkgfile $pkgdir || exit 1
fi

echo Removing temporary files...
rm -r $pkgdir

echo Done.
