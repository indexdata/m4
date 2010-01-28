AC_DEFUN([Z3_INIT],
[
	AC_SUBST(Z3LIB)
	AC_SUBST(Z3LALIB)
	AC_SUBST(Z3INC)
	AC_SUBST(Z3VERSION)
	z3config=NONE
	z3path=NONE
	AC_ARG_WITH(z3, [  --with-z3=DIR          use idzebra-config-3.0 in DIR (example /home/z3-1.7)], [z3path=$withval])
	if test "x$z3path" != "xNONE"; then
		z3config=$z3path/idzebra-config-3.0
	else
		if test "x$srcdir" = "x"; then
			z3srcdir=.
		else
			z3srcdir=$srcdir
		fi
		for i in ${z3srcdir}/../../z3 ${z3srcdir}/../z3-* ${z3srcdir}/../z3; do
			if test -d $i; then
				if test -r $i/idzebra-config-3.0; then
					z3config=$i/idzebra-config-3.0
				fi
			fi
		done
		if test "x$z3config" = "xNONE"; then
			AC_PATH_PROG(z3config, idzebra-config-3.0, NONE)
		fi
	fi
	AC_MSG_CHECKING(for Z3)
	if $z3config --version >/dev/null 2>&1; then
		Z3LIB=`$z3config --libs $1`
		Z3LALIB=`$z3config --lalibs $1`
		Z3INC=`$z3config --cflags $1`
		Z3VERSION=`$z3config --version`
		AC_MSG_RESULT([$z3config])
	else
		AC_MSG_RESULT(Not found)
		Z3VERSION=NONE
	fi
	if test "X$Z3VERSION" != "XNONE"; then
		AC_MSG_CHECKING([for Z3 version])
		AC_MSG_RESULT([$Z3VERSION])
		if test "$2"; then
			have_z3_version=`echo "$Z3VERSION" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3;}'`
			req_z3_version=`echo "$2" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3;}'`
			if test "$have_z3_version" -lt "$req_z3_version"; then
				AC_MSG_ERROR([$Z3VERSION. Requires Z3 $2 or later])
			fi
		fi
	fi
]) 
