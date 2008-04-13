# configure for Boost libs
#
# ID_BOOST([components],[libs])
AC_DEFUN([ID_BOOST],
    [
	AC_MSG_CHECKING([for Boost])
	AC_LANG_PUSH([C++])
	oldCPPFLAGS="$CPPFLAGS"
	oldLIBS="$LIBS"
	BOOST_REQ_VERSION=`echo "$2" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 100 + [$]3;}'`
	CPPFLAGS="$CPPFLAGS -DBOOST_REQ_VERSION=${BOOST_REQ_VERSION}"

	AC_ARG_WITH([boost],[[  --with-boost=DIR  use Boost in prefix DIR]])
	if test "$with_boost" = "yes"; then
	    BOOST_CPPFLAGS=""
	    BOOST_LIBS=""
	else
	    BOOST_CPPFLAGS="-I${with_boost}/include"
	    BOOST_LIBS=" -L${with_boost}/lib"
	fi
	if test "${with_boost}" = "no"; then
	    AC_MSG_RESULT([disabled])
	else
	    CPPFLAGS="${CPPFLAGS} ${BOOST_CPPFLAGS}"
	    LIBS="${LIBS} ${BOOST_LIBS}"
            AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
]],[[ 
int x = BOOST_VERSION;
]])],[AC_MSG_RESULT([yes])],[AC_MSG_RESULT([no])])


            AC_MSG_CHECKING([Boost version])
 	    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
]],[[
#if BOOST_VERSION < BOOST_REQ_VERSION
#error Version too old
#endif
]])],[
	    AC_MSG_RESULT([ok])
],[
	    AC_MSG_RESULT([version too old])
	])
	fi
	CPPFLAGS="$oldCPPFLAGS"
	LIBS="$oldLIBS"
	AC_LANG_POP([C++])
    ])
 

