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

	AC_ARG_WITH([boost],[  --with-boost=DIR        use Boost in prefix DIR])
	if test "$with_boost" = "yes" -o -z "$with_boost"; then
	    BOOST_CPPFLAGS=""
	    BOOST_LIB=""
	else
	    BOOST_LIB="-L${with_boost}/lib"
	    BOOST_CPPFLAGS="-I${with_boost}/include"
	    if test ! -f "${with_boost}/include/boost/version.hpp"; then
		for b in ${with_boost}/include/boost-*; do
		    BOOST_CPPFLAGS="-I$b"
		done
	    fi
	fi
	AC_ARG_WITH([boost-toolset],[  --with-boost-toolset=x  use Boost toolset (eg gcc43)])
	if test "$with_boost_toolset" = "yes" -o -z "$with_boost_toolset"; then
	    BOOST_TOOLSET=""
	else
	    BOOST_TOOLSET="-${with_boost_toolset}"
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
	    if test "$BOOST_GOT_VERSION" = "BOOST_VERSION"; then
		AC_MSG_RESULT([no])
		AC_MSG_ERROR([Boost development libraries required])
	    fi
	    AC_MSG_RESULT([yes ($BOOST_GOT_VERSION)])
	    if test "$BOOST_GOT_VERSION" -lt $BOOST_REQ_VERSION; then
		AC_MSG_ERROR([Boost version $BOOST_REQ_VERSION required])
	    fi
	    for c in $1; do
	    	case $c in 
		    thread)
			AC_MSG_CHECKING([Boost threads])
			AC_SUBST([BOOST_THREAD_LIB])
			saveLIBS="${LIBS}"
			BOOST_THREAD_LIB=""
			for l in boost_thread${BOOST_TOOLSET}-mt boost_thread${BOOST_TOOLSET}; do
		            LIBS="${saveLIBS} -l${l}"
			AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
#include <boost/thread/thread.hpp>
]],[[ 
int x = BOOST_VERSION;
]])],[
			    BOOST_THREAD_LIB="-l${l}"
			    break],[])
			done
			if test "${BOOST_THREAD_LIB}"; then
			    AC_MSG_RESULT([yes])
			else
			    AC_MSG_RESULT([no])
			fi
			;;
		    test)
			AC_MSG_CHECKING([Boost unit test framework])
			saveLIBS="${LIBS}"
			AC_SUBST([BOOST_TEST_LIB])
			BOOST_TEST_LIB=""
			for l in boost_unit_test_framework${BOOST_TOOLSET}-mt boost_unit_test_framework${BOOST_TOOLSET}; do
			    LIBS="${saveLIBS} -l${l}"
			    AC_LINK_IFELSE([AC_LANG_SOURCE([[
#define BOOST_TEST_DYN_LINK
#define BOOST_AUTO_TEST_MAIN
#include <boost/test/auto_unit_test.hpp>
BOOST_AUTO_TEST_CASE( t ) 
{
    BOOST_CHECK(1);
}
]])],[
			      BOOST_TEST_LIB="-l${l}"
			      break
],[])
			done
			if test "${BOOST_TEST_LIB}"; then
			    AC_MSG_RESULT([yes])
			else
			    AC_MSG_RESULT([no])
			fi
			LIBS="${saveLIBS}"
			;;
		esac
	    done
	fi
	CPPFLAGS="$oldCPPFLAGS"
	LIBS="$oldLIBS"
	AC_LANG_POP([C++])
    ])

dnl Local Variables:
dnl mode:shell-script
dnl sh-indentation: 2
dnl sh-basic-offset: 4
dnl End:
