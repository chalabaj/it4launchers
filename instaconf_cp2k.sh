#/bin/bash
module load imkl/2017.1.132-iimpi-2017a

#export MKLROOT
./install_cp2k_toolchain.sh --install-all --mpi-mode=mpich --math-mode=mkl --enable-omp=no  --with-binutils=system