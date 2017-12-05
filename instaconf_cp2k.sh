#/bin/bash
module load imkl/2017.1.132-iimpi-2017a
module load MPICH/3.2-GCC-5.3.1-snapshot-20160419-2.25

#export MKLROOT
./install_cp2k_toolchain.sh --install-all --mpi-mode=mpich --math-mode=mkl --enable-omp=no --with-binutils=system --with-mkl=system --with-gcc=system --with-mpich=system --with-binutils=system --with-make=system --with-cmake=system