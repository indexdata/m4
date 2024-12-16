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
	    for b in ${with_boost}/lib ${with_boost}/lib64; do
		if test -d "$b"; then
	    	    BOOST_LIB+=" -L$b"
		fi
            done
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
BOOST_VERSION
]])])
	    BOOST_GOT_VERSION=`(eval "$ac_cpp conftest.$ac_ext") 2>&AS_MESSAGE_LOG_FD | grep -v '#' | grep -v '^$' 2>/dev/null`
	    if test -z "$BOOST_GOT_VERSION" -o \
		"$BOOST_GOT_VERSION" = "BOOST_VERSION"; then
		AC_MSG_RESULT([no])
		AC_MSG_ERROR([Boost development libraries required])
	    fi
	    AC_MSG_RESULT([yes ($BOOST_GOT_VERSION)])
	    if test "$BOOST_GOT_VERSION" -lt $BOOST_REQ_VERSION; then
		AC_MSG_ERROR([Boost version $BOOST_REQ_VERSION required])
	    fi
	    for c in $1; do
	    	case $c in 
		    system)
			AC_SUBST([BOOST_SYSTEM_LIB])
			BOOST_SYSTEM_LIB=""
			if test "$BOOST_GOT_VERSION" -ge 104100; then
			    AC_MSG_CHECKING([Boost system])
			    saveLIBS="${LIBS}"
			    for l in "${BOOST_TOOLSET}" "${BOOST_TOOLSET}-mt"; do
				trylib="-lboost_system${l}"
				LIBS="${saveLIBS} ${trylib}"
				AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
#include <boost/system/error_code.hpp>
]],[[ 
int x = BOOST_VERSION;
]])],[
					BOOST_SYSTEM_LIB="${trylib}"
					break],[])
			    done
			    if test "${BOOST_SYSTEM_LIB}"; then
				AC_MSG_RESULT([yes])
			    else
				AC_MSG_RESULT([no])
			        LIBS="${saveLIBS}"
			    fi
			fi
			;;
		    thread)
			AC_MSG_CHECKING([Boost threads])
			AC_SUBST([BOOST_THREAD_LIB])
			saveLIBS="${LIBS}"
			BOOST_THREAD_LIB=""
			for l in "${BOOST_TOOLSET}" "${BOOST_TOOLSET}-mt"; do
			    trylib="-lboost_thread${l}"
		            LIBS="${saveLIBS} ${trylib}"
			AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
#include <boost/thread/thread.hpp>
]],[[ 
int x = BOOST_VERSION;
]])],[
			    BOOST_THREAD_LIB="${trylib}"
			    break],[])
			done
			if test "${BOOST_THREAD_LIB}"; then
			    AC_MSG_RESULT([yes])
			else
			    AC_MSG_RESULT([no])
			    LIBS="${saveLIBS}"
			fi
			;;
		    test)
			AC_MSG_CHECKING([Boost unit test framework])
			saveLIBS="${LIBS}"
			AC_SUBST([BOOST_TEST_LIB])
			BOOST_TEST_LIB=""
			for l in boost_unit_test_framework${BOOST_TOOLSET} boost_unit_test_framework${BOOST_TOOLSET}-mt; do
			    LIBS="${saveLIBS} -l${l}"
			    AC_LINK_IFELSE([AC_LANG_SOURCE([[
#define BOOST_TEST_DYN_LINK
#define BOOST_AUTO_TEST_MAIN
#define BOOST_TEST_MODULE configure
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
		    regex)
			AC_MSG_CHECKING([Boost regex])
			AC_SUBST([BOOST_REGEX_LIB])
			saveLIBS="${LIBS}"
			BOOST_REGEX_LIB=""
			for l in boost_regex${BOOST_TOOLSET} boost_regex${BOOST_TOOLSET}-mt; do
		            LIBS="${saveLIBS} -l${l}"
			AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#include <boost/version.hpp>
#include <boost/regex.hpp>
]],[[ 
int x = BOOST_VERSION;
]])],[
			    BOOST_REGEX_LIB="-l${l}"
			    break],[])
			done
			if test "${BOOST_REGEX_LIB}"; then
			    AC_MSG_RESULT([yes])
			else
			    AC_MSG_RESULT([no])
			    LIBS="${saveLIBS}"
			fi
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
