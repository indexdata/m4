AC_DEFUN([USEMARCON_INIT],
[
        AC_SUBST([USEMARCONLALIB])
        AC_SUBST([USEMARCONINC])
        usemarconconfig=NONE
        usemarconpath=NONE
        AC_ARG_WITH([usemarcon], [  --with-usemarcon=DIR    usemarcon-config in DIR (example /home/usemarcon145)], [usemarconpath=$withval])

        if test "$usemarconpath" = "NONE"; then
                if test "x$srcdir" = "x"; then
                        usemarconsrcdir=.
                else
                        usemarconsrcdir=$srcdir
                fi
                for i in ${usemarconsrcdir}/../usemarcon*; do
                        if test -d $i; then
                                if test -r $i/usemarcon-config; then
                                        usemarconconfig=$i/usemarcon-config
                                fi
                        fi
                done
                if test "x$usemarconconfig" = "xNONE"; then
                        AC_PATH_PROG([usemarconconfig], [usemarcon-config], [NONE])
                fi
	elif test "$usemarconpath" != "no"; then
                usemarconconfig=$usemarconpath/usemarcon-config
        fi

        AC_MSG_CHECKING([for USEMARCON])
        if $usemarconconfig --version >/dev/null 2>&1; then
                USEMARCONLALIB=`$usemarconconfig --lalibs $1`
                USEMARCONINC=`$usemarconconfig --cflags $1`
                USEMARCONVERSION=`$usemarconconfig --version`
                AC_MSG_RESULT([$usemarconconfig])
                AC_DEFINE([HAVE_USEMARCON],[1],[Define to 1 if USEMARCON is used])
        else
                AC_MSG_RESULT([Not found])
                USEMARCONVERSION=NONE
        fi
])

