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
	AC_SUBST([BOOST_CPPFLAGS])
	AC_SUBST([BOOST_LIB])
	
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
	    AC_LANG_CONFTEST(
               [AC_LANG_SOURCE([[
#include <boost/version.hpp>
version_is:BOOST_VERSION
]])])
	    BOOST_GOT_VERSION=`(eval "$ac_cpp conftest.$ac_ext") 2>&AS_MESSAGE_LOG_FD | $EGREP version_is 2>/dev/null | cut -d ":" -f2`
	    if test $BOOST_GOT_VERSION = "BOOST_VERSION"; then
		AC_MSG_RESULT([no])
		AC_MSG_ERROR([Boost development libraries required])
	    fi
	    AC_MSG_RESULT([yes ($BOOST_GOT_VERSION)])
	    if test $BOOST_GOT_VERSION -lt $BOOST_REQ_VERSION; then
		AC_MSG_ERROR([Boost version $BOOST_REQ_VERSION required])
	    fi
	    for c in $1; do
	    	case $c in 
		    thread)
			AC_SUBST([BOOST_THREAD_LIB])
			BOOST_THREAD_LIB=""
			for l in boost_thread-mt boost_thread; do
			    AC_CHECK_LIB([${l}],[main],[
				    BOOST_THREAD_LIB="-l${l}"
				    break
				    ],[])
			done
			if test -z "${BOOST_THREAD_LIB}"; then
			    AC_MSG_ERROR([Boost thread libs not found])
			fi
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
			AC_SUBST([BOOST_TEST_LIB])
			BOOST_TEST_LIB=""
			for l in boost_unit_test_framework-mt boost_unit_test_framework; do
			    AC_CHECK_LIB([${l}],[main],[
				    BOOST_TEST_LIB="-l${l}"
				    break
				    ],[])
			done
			if test -z "${BOOST_TEST_LIB}"; then
			    AC_MSG_ERROR([Boost unit test libs not found])
			fi
			saveLIBS="${LIBS}"
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
	fi
	CPPFLAGS="$oldCPPFLAGS"
	LIBS="$oldLIBS"
	AC_LANG_POP([C++])
    ])
 

