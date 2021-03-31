#!/bin/sh

SRCDIR=$1

SRCBASENAME=xv_demosaic.c
SRC=${SRCDIR}/${SRCBASENAME}
grep '#undef __linux__' ${SRC} > /dev/null
if [ $? -ne 0 ]; then
    sed -e 's/#include "xv_demosaic.h"/#ifdef __linux__\n#undef __linux__\n#endif\n#include "xv_demosaic.h"/' ${SRC} > tmp.c
    mv tmp.c ${SRC}
    echo "${SRCBASENAME} modified"
fi

SRCBASENAME=xv_demosaic_sinit.c
SRC=${SRCDIR}/${SRCBASENAME}
grep '#undef __linux__' ${SRC} > /dev/null
if [ $? -ne 0 ]; then
    sed -e 's/#ifndef __linux__/#ifdef __linux__\n#undef __linux__\n#endif\n#ifndef __linux__/' ${SRC} > tmp.c
    mv tmp.c ${SRC}
    echo "${SRCBASENAME} modified"
fi

SRCBASENAME=xv_demosaic_g.c
SRC=${SRCDIR}/${SRCBASENAME}
grep '#undef __linux__' ${SRC} > /dev/null
if [ $? -ne 0 ]; then
    sed -e 's/#include "xparameters.h"/#ifdef __linux__\n#undef __linux__\n#endif\n#include "xparameters.h"/' ${SRC} > tmp.c
    mv tmp.c ${SRC}
    echo "${SRCBASENAME} modified"
fi

#SRCBASENAME=xv_demosaic.h
#SRC=${SRCDIR}/${SRCBASENAME}
#grep 'UINTPTR Bus_axi4ls_BaseAddress' ${SRC} > /dev/null
#if [ $? -ne 0 ]; then
#    sed -e 's/u32 Bus_axi4ls_BaseAddress/UINTPTR Bus_axi4ls_BaseAddress/' ${SRC} > tmp.h
#    mv tmp.h ${SRC}
#    echo "${SRCBASENAME} modified"
#fi
