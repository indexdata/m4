AC_DEFUN([AUTHORITY_INIT],
[
	AC_SUBST(AUTHORITYLIB)
	AC_SUBST(AUTHORITYLALIB)
	AC_SUBST(AUTHORITYINC)
	AC_SUBST(AUTHORITYVERSION)
	authconfig=NONE
	authpath=NONE
	AC_ARG_WITH(auth, [  --with-auth=DIR          use authority-config-0.0 in DIR (example /home/frbr-0.0)], [authpath=$withval])
	if test "x$authpath" != "xNONE"; then
		authconfig=$authpath/authority-config-0.0
	else
		if test "x$srcdir" = "x"; then
			authsrcdir=.
		else
			authsrcdir=$srcdir
		fi
		for i in ${authsrcdir}/../../authc ${authsrcdir}/../authc-* ${authsrcdir}/../authc; do
			if test -d $i; then
				if test -r $i/authority-config-0.0; then
					authconfig=$i/authority-config-0.0
				fi
			fi
		done
		if test "x$authconfig" = "xNONE"; then
			AC_PATH_PROG(authconfig, authority-config-0.0, NONE)
		fi
	fi
	AC_MSG_CHECKING(for AUTHORITY)
	if $authconfig --version >/dev/null 2>&1; then
		AUTHORITYLIB=`$authconfig --libs $1`
		AUTHORITYLALIB=`$authconfig --lalibs $1`
		AUTHORITYINC=`$authconfig --cflags $1`
		AUTHORITYVERSION=`$authconfig --version`
		AC_MSG_RESULT([$authconfig])
	else
		AC_MSG_RESULT(Not found)
		AUTHORITYVERSION=NONE
	fi
	if test "X$AUTHORITYVERSION" != "XNONE"; then
		AC_MSG_CHECKING([for AUTHORITY version])
		AC_MSG_RESULT([$AUTHORITYVERSION])
		if test "$2"; then
			have_auth_version=`echo "$AUTHORITYVERSION" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3;}'`
			req_auth_version=`echo "$2" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 1000 + [$]3;}'`
			if test "$have_auth_version" -lt "$req_auth_version"; then
				AC_MSG_ERROR([$AUTHORITYVERSION. Requires AUTHORITY $2 or later])
			fi
		fi
	fi
]) 
