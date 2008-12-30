#!/bin/sh -ev

. envsetup.sh
. source.sh
trap '{ cd $BASEDIR; exit 1; }' EXIT
PARALLEL=`sysctl hw.ncpu | perl -ne 's/\D//g; print $_+1'`
mkdir -p build; cd build

# jpeg
if [ \! -f $PREFIX/lib/libjpeg.dylib ]; then
    if [ \! -d jpeg* ]; then tar xf $SRCDIR/jpeg*; fi
    pushd jpeg*
    
    cp /usr/share/libtool/config.* . # Enable OS detection
    ./configure --prefix=$PREFIX --enable-shared --enable-static
    cp -f /usr/bin/glibtool libtool # Shared linking
    # Use LDFLAGS; use libtool tag
    perl -i -pe \
    's/(mode=link.*)\\/$1 \$(LDFLAGS) \\/;s/mode=[\S]+/$& --tag=CC/' Makefile
    make -j$PARALLEL LDFLAGS="$SYSLIBROOT $ARCHES"
    mkdir -p $PREFIX/{lib,include,bin,man/man1}
    make install
    
    popd
fi

# png
if [ \! -f $PREFIX/lib/libpng.dylib ]; then
    if [ \! -d libpng* ]; then tar xf $SRCDIR/libpng*; fi
    pushd libpng*
    
    ./configure --prefix=$PREFIX --disable-dependency-tracking
    make -j$PARALLEL && make install
    
    popd
fi

# tiff
if [ \! -f $PREFIX/lib/libtiff.dylib ]; then
    if [ \! -d tiff* ]; then tar xf $SRCDIR/tiff*; fi
    pushd tiff*
    
    ./configure --prefix=$PREFIX
    make -j$PARALLEL && make install
    
    popd
fi

# gettext
if [ \! -f $PREFIX/lib/libintl.dylib ]; then
    if [ \! -d gettext* ]; then tar xf $SRCDIR/gettext*; fi
    pushd gettext*
    
    CFLAGS="$CFLAGS -I/usr/include/libxml2"
        ./configure --prefix=$PREFIX --disable-java --disable-csharp \
        --disable-dependency-tracking
    make && make install  # parallel build breakage
    
    popd
fi

# pkg-config
if  [ \! -f $PREFIX/bin/pkg-config ]; then
    if [ \! -d pkg-config* ]; then tar xf $SRCDIR/pkg-config*; fi
    pushd pkg-config*
    ./configure --prefix=$PREFIX && make -j$PARALLEL && make install
    popd
fi

# glib
if  [ \! -f $PREFIX/lib/libglib-2.0.dylib ]; then
    if [ \! -d glib* ]; then tar xf $SRCDIR/glib*; fi
    pushd glib*
    
    # Host >= i486 for atomic operations
    ./configure --prefix=$PREFIX --host=i486-apple-darwin \
      --build=i486-apple-darwin
    make && make install
    
    popd
fi

# pixman
if  [ \! -f $PREFIX/lib/libpixman-1.dylib ]; then
    if [ \! -d pixman* ]; then tar xf $SRCDIR/pixman*; fi
    pushd pixman*
    ./configure --prefix=$PREFIX && make -j$PARALLEL && make install
    popd
fi

# cairo
if [ \! -f $PREFIX/lib/libcairo.dylib ]; then
    if [ \! -d cairo* ]; then tar xf $SRCDIR/cairo*; fi
    pushd cairo*
    
    ./configure --prefix=$PREFIX --disable-xlib --enable-pdf \
      --enable-quartz
    make -j$PARALLEL && make install
    
    popd
fi

# atk
if [ \! -f $PREFIX/lib/libatk-1.0.dylib ]; then
    if [ \! -d atk* ]; then tar xf $SRCDIR/atk*; fi
    pushd atk*
    
    ./configure --prefix=$PREFIX && make -j$PARALLEL && make install
    
    popd
fi

# pango
# NB: pango and gtk may have ccache errors?
if [ \! -f $PREFIX/lib/libpango-1.0.dylib ]; then
    if [ \! -d pango* ]; then tar xf $SRCDIR/pango*; fi
    pushd pango*
    
    # Deprecated function
    perl -i -pe 's/#undef cairo_atsui_font_face_create_for_atsu_font_id//' pango/pangocairo-atsuifont.c
    
    ./configure --prefix=$PREFIX --without-x --disable-dependency-tracking
    make -j$PARALLEL && make install
    
    popd
fi

# gtk+
if [ \! -f $PREFIX/lib/libgtk-quartz-2.0.dylib ]; then
    if [ \! -d gtk* ]; then tar xf $SRCDIR/gtk*; fi
    pushd gtk*
    
    # Do we care about jasper (jpeg 2000)?
    ./configure --prefix=$PREFIX --with-gdktarget=quartz \
      --without-libjasper --disable-dependency-tracking
    make -j$PARALLEL && make install
    
    popd
fi

# pygobject
if [ \! -f $PREFIX/lib/pkgconfig/pygobject-2.0.pc ]; then
    if [ \! -d pygobject* ]; then tar xf $SRCDIR/pygobject*; fi
    pushd pygobject*
    
    # Don't stuff things in /Library/Python!
    am_cv_python_pythondir=$PYTHONPATH am_cv_python_pyexecdir=$PYTHONPATH \
      ./configure --prefix=$PREFIX 
    make -j$PARALLEL && make install
    
    popd
fi

# pycairo
if [ \! -f $PREFIX/lib/pkgconfig/pycairo.pc ]; then
    if [ \! -d pycairo* ]; then tar xf $SRCDIR/pycairo*; fi
    pushd pycairo*
    
    am_cv_python_pythondir=$PYTHONPATH am_cv_python_pyexecdir=$PYTHONPATH \
      ./configure --prefix=$PREFIX 
    make -j$PARALLEL && make install
    
    popd
fi

# libglade
if [ \! -f $PREFIX/lib/libglade-2.0.dylib ]; then
    if [ \! -d libglade* ]; then tar xf $SRCDIR/libglade*; fi
    pushd libglade*
    
    ./configure --prefix=$PREFIX
    make -j$PARALLEL && make install
    
    popd
fi

# pygtk
if [ \! -f $PREFIX/lib/pkgconfig/pygtk-2.0.pc ]; then
    if [ \! -d pygtk* ]; then tar xf $SRCDIR/pygtk*; fi
    pushd pygtk*
    
    am_cv_python_pythondir=$PYTHONPATH am_cv_python_pyexecdir=$PYTHONPATH \
      ./configure --prefix=$PREFIX 
    make -j$PARALLEL && make install
    
    popd
fi

# nicotine
if [ \! -f $PREFIX/bin/nicotine ]; then
  if [ \! -d nicotine* ]; then tar xf $SRCDIR/nicotine*; fi
  pushd nicotine*
  
  # No easy way to install into proper dir
  PYTHONPATH=$PYTHONPATH/gtk-2.0 python setup.py install \
    --prefix=$PREFIX --root=`pwd`/root
  
  # Do it the long way
  cp -R `find root -name share`/ $PREFIX/share/
  cp -R root/$PREFIX/ $PREFIX/
  
  popd
fi
