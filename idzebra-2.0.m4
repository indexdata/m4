## $Id: idzebra-2.0.m4,v 1.1 2006-08-14 12:18:49 adam Exp $
## 
# Use this m4 function for autoconf if you use ID Zebra in your own
# configure script.

AC_DEFUN([IDZEBRA_2_0_INIT],
[
	AC_SUBST(IDZEBRA_LIBS)
	AC_SUBST(IDZEBRA_LALIBS)
	AC_SUBST(IDZEBRA_CFLAGS)
	AC_SUBST(IDZEBRA_VERSION)
	idzebraconfig=NONE
	idzebrapath=NONE
	AC_ARG_WITH(idzebra, [  --with-idzebra=DIR      use idzebra-config in DIR (example /home/idzebra-2.0.0)], [idzebrapath=$withval])
	if test "x$idzebrapath" != "xNONE"; then
		idzebraconfig=$idzebrapath/idzebra-config-2.0
	else
		if test "x$srcdir" = "x"; then
			idzebrasrcdir=.
		else
			idzebrasrcdir=$srcdir
		fi
		for dir in ${idzebrasrcdir}/../idzebra* ${idzebrasrcdir}/../idzebra ../idzebra* ../zebra; do
			if test -d $dir; then
				conf=$dir/idzebra-config-2.0
				if test -r $conf; then
					idzebraconfig=$conf
				fi
			fi
		done
		if test "x$idzebraconfig" = "xNONE"; then
			AC_PATH_PROG(idzebraconfig, idzebra-config-2.0, NONE)
		fi
	fi
	AC_MSG_CHECKING(for idzebra)
	if $idzebraconfig --version >/dev/null 2>&1; then
		IDZEBRA_LIBS=`$idzebraconfig --libs $1`
		IDZEBRA_LALIBS=`$idzebraconfig --lalibs $1`
		IDZEBRA_CFLAGS=`$idzebraconfig --cflags $1`
		IDZEBRA_VERSION=`$idzebraconfig --version`
		AC_MSG_RESULT([$idzebraconfig])
	else
		AC_MSG_RESULT(Not found)
		IDZEBRA_VERSION=NONE
	fi
	if test "X$IDZEBRA_VERSION" != "XNONE"; then
		AC_MSG_CHECKING([for idzebra version])
		AC_MSG_RESULT([$IDZEBRA_VERSION])
		if test "$2"; then
			have_idzebra_version=`echo "$IDZEBRA_VERSION" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3;}'`
			req_idzebra_version=`echo "$2" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3;}'`
			if test "$have_idzebra_version" -lt "$req_idzebra_version"; then
				AC_MSG_ERROR([$IDZEBRA_VERSION. Requires idzebra $2 or later])
			fi
		fi
	fi
]) 

