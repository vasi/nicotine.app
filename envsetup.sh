export BASEDIR=$PWD
export PDIR=`dirname $BASEDIR`
export SRCDIR=$BASEDIR/src
export SDLDIR=$BASEDIR/sdl
export PATCHDIR=$BASEDIR/patch
export RSRCDIR=$BASEDIR/resources
export PREFIX=$BASEDIR/prefix

export MACOSX_DEPLOYMENT_TARGET=10.5
export SDK=/Developer/SDKs/MacOSX10.5.sdk
export GCC_VERSION=4.0
export ARCHES="-arch i386"
#export OPT='-g -O0'
export OPT='-Os'

export CC=gcc-$GCC_VERSION
export CXX=g++-$GCC_VERSION
export CPPFLAGS="-I$PREFIX/include -isysroot $SDK"
export CFLAGS="$OPT $ARCHES"
export CXXFLAGS="$CFLAGS"
export SYSLIBROOT="-Wl,-syslibroot,$SDK"
export LDFLAGS="$ARCHES $SYSLIBROOT -L$PREFIX/lib"
export PATH="$PREFIX/bin:/usr/bin:/bin"

export PYTHONPATH=$PREFIX/lib/python2.5/site-packages
export PKG_CONFIG_PATH=/usr/lib/pkgconfig # for libxml2

if [ -z "$CCACHE_DISABLE" ]; then
  export PATH="/Users/vasi/Hacking/Commands/ccache:$PATH"
fi
