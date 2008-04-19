# configure for Boost libs
#
# ID_BOOST([components],[libs])
#
# Sets the following variables:
#
#   BOOST_CPPFLAGS
#   BOOST_LIB
# If components include "thread":
#   BOOST_THREAD_LIB
# If components include "test":
#   BOOST_TEST_LIB

AC_DEFUN([ID_BOOST],
    [
	AC_SUBST(BOOST_CPPFLAGS)
	AC_SUBST(BOOST_LIB)
	
	AC_MSG_CHECKING([for Boost])
	AC_LANG_PUSH([C++])
	oldCPPFLAGS="$CPPFLAGS"
	oldLIBS="$LIBS"
	BOOST_REQ_VERSION=`echo "$2" | awk 'BEGIN { FS = "."; } { printf "%d", ([$]1 * 1000 + [$]2) * 100 + [$]3;}'`
	CPPFLAGS="$CPPFLAGS -DBOOST_REQ_VERSION=${BOOST_REQ_VERSION}"

	AC_ARG_WITH([boost],[[  --with-boost=DIR  use Boost in prefix DIR]])
	if test "$with_boost" = "yes" -o -z "$with_boost"; then
	    BOOST_CPPFLAGS=""
	    BOOST_LIB=""
	else
	    BOOST_CPPFLAGS="-I${with_boost}/include"
	    BOOST_LIB="-L${with_boost}/lib"
	fi
	if test "${with_boost}" = "no"; then
	    AC_MSG_RESULT([disabled])
	else
	    CPPFLAGS="${CPPFLAGS} ${BOOST_CPPFLAGS}"
	    LIBS="${LIBS} ${BOOST_LIB}"
            AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
]],[[ 
int x = BOOST_VERSION;
]])],[AC_MSG_RESULT([yes])],[AC_MSG_RESULT([no])
	    AC_MSG_ERROR([Boost development libraries required])
])


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
	    AC_MSG_ERROR([A newer version of Boost is required])
	])
	fi
	for c in $1; do
	    case $c in 
		thread)
		    AC_SUBST(BOOST_THREAD_LIB)
		    BOOST_THREAD_LIB="-lboost_thread-mt"
		    LIBS="${LIBS} ${BOOST_THREAD_LIB}"
		    AC_MSG_CHECKING([Boost threads])
		    AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
#include <boost/thread/thread.hpp>
]],[[ 
int x = BOOST_VERSION;
]])],[AC_MSG_RESULT([yes])],[
AC_MSG_RESULT([no])
AC_MSG_ERROR([Boost thread libraries required])
])
                    ;;
		test)
		    AC_SUBST(BOOST_TEST_LIB)
		    saveLIBS="${LIBS}"
		    BOOST_TEST_LIB="-lboost_unit_test_framework-mt"
		    LIBS="${LIBS} ${BOOST_TEST_LIB}"
		    AC_MSG_CHECKING([Boost unit test framework])
		    AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#define BOOST_TEST_DYN_LINK
#include <boost/test/auto_unit_test.hpp>
BOOST_AUTO_TEST_CASE( t ) 
{
    BOOST_CHECK(1);
}
]],[[ 
]])],[AC_MSG_RESULT([yes])],[AC_MSG_RESULT([no])
AC_MSG_ERROR([Boost unit test framework libraries required])])
		    LIBS="${saveLIBS}"
                    ;;
		esac
	done
	CPPFLAGS="$oldCPPFLAGS"
	LIBS="$oldLIBS"
	AC_LANG_POP([C++])
    ])
 

