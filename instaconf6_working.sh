#!/bin/bash

MKLROOT=/apps/all/imkl/11.3.3.210-iimpi-2016.03-GCC-5.3.0-2.26/mkl

#MKL_DIR=/apps/all/imkl/2017.3.196-iimpi-2017.05-GCC-7.1.0-2.28/mkl/lib/intel64 #funguej na ifort
#MKL_DIR=/apps/all/imkl/2017.1.132-iompi-2017a/mkl/lib/intel64
#MKL_DIR=/apps/all/imkl/11.2.3.187/composer_xe_2015.3.187/mkl/lib/intel64/

. /home/chalabaj/prog/envmkl.sh
. /home/chalabaj/prog/fftw/3.3.5-gcc/env.sh #GCC 
. /home/chalabaj/prog/nfft/3.2.3/env.sh 
. /home/chalabaj/prog/libxc/3.0.0-gcc/env.sh
. /home/chalabaj/prog/gsl/2.2-gcc/env.sh 
. /home/chalabaj/prog/opempi/1.10.4/env.sh 
module load imkl/11.3.3.210-iimpi-2016.03-GCC-5.3.0-2.26

module unload GCCcore/5.3.0 ifort/2016.3.210-GCC-5.3.0-2.26 iimpi/2016.03-GCC-5.3.0-2.26 binutils/2.26-GCCcore-5.3.0 iccifort/2016.3.210-GCC-5.3.0-2.26 icc/2016.3.210-GCC-5.3.0-2.26 impi/5.1.3.181-iccifort-2016.3.210-GCC-5.3.0-2.26

MKLROOT=/apps/all/imkl/11.3.3.210-iimpi-2016.03-GCC-5.3.0-2.26/mkl

./configure --prefix=/home/chalabaj/prog/octopus/6.0-impi-metispar --enable-sse2 --enable-mpi CC=mpicc CXX=mpic++ FC=mpif90 F77=mpif77 --with-fftw-prefix=/home/chalabaj/prog/fftw/3.3.5-gcc --with-libxc-prefix=/home/chalabaj/prog/libxc/3.0.0-gcc --with-nfft=/home/chalabaj/prog/nfft/3.2.3 --with-blas="${MKLROOT}/lib/intel64/libmkl_scalapack_lp64.a -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_gf_lp64.a ${MKLROOT}/lib/intel64/libmkl_sequential.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_blacs_openmpi_ilp64.a -Wl,--end-group -lpthread -lm -ldl" --with-blacs="${MKLROOT}/lib/intel64/libmkl_blacs_openmpi_lp64.a" --with-scalapack="${MKLROOT}/lib/intel64/libmkl_scalapack_lp64.a" --with-metis-prefix=/home/chalabaj/prog/metis/5.1.0 --with-parmetis-prefix=/home/chalabaj/prog/parmetis/4.0.3

#CC=mpicc CXX=mpic++ FC=mpif90 F77=mpif77 
#CC=mpicc FC=mpif90 
#--with-blas="/home/chalabaj/prog/blas/3.7.1/lib/libblas.a"
#--with-blas="-L$MKL_DIR2 -Wl,--start-group  -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread" --with-blacs="$MKL_DIR2/libmkl_blacs_intelmpi_lp64.a" --with-scalapack="$MKL_DIR2/libmkl_scalapack_lp64.a"

#FOR gcc a gfortran -lmkl_gf_lp64 flag is needed
# --with-fftw-prefix=/apps/all/FFTW/3.3.6-intel-2017a

# libxc ./configure --prefix=/home/chalabaj/prog/libxc/3.0.0 --enable-shared CC=gcc CXX=g++ FC=gfortran F77=gfortran
#--with-libxc-prefix=/home/chalabaj/prog/libxc/3.0.0 --with-blas="-L$MKL_DIR -Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread" --with-blacs="$MKL_DIR/libmkl_blacs_intelmpi_lp64.a" --with-scalapack="$MKL_DIR/libmkl_scalapack_lp64.a"

#--with-fftw-prefix=/home/chalabaj/prog/fftw/3.3.5/ --with-nfft=/home/chalabaj/prog/nfft/3.2.3 --enable-openmp --enable-mpi  --with-blas=/etc/alternatives/

#libxc gcc
#libxc installed with  module load ifort/2017.4.196-GCC-7.1.0-2.28  icc/2017.4.196-GCC-7.1.0-2.28 -icc install

#icc####
#--with-blas="-L$MKL_DIR -Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread" --with-blacs="$MKL_DIR/libmkl_blacs_intelmpi_lp64.a" --with-scalapack="$MKL_DIR/libmkl_scalapack_lp64.a"

###GCC
#-with-blas="-L$MKL_DIR2 -Wl,--start-group -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread" --with-blacs="$MKL_DIR2/libmkl_blacs_intelmpi_lp64.a" --with-scalapack="$MKL_DIR2/libmkl_scalapack_lp64.a"

#FFTW    ./configure --prefix=/home/chalabaj/prog/fftw/3.3.6-pl2  CC=gcc FC=gfortran F77=gfortran --enable-threads --enable-mpi
#NFFT
#MKL_DIR=/apps/all/imkl/2017.1.132-iompi-2017a/mkl/lib/intel64