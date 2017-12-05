help([[
Description
===========
 CP2K with Frank U. MOM occupancies fix - alqays check the occupancies and pay attention to DEOCC and OCC set

More information
================
 - Homepage: http://www.cp2k.org/
]])

whatis("Homepage: http://www.cp2k.org/")
conflict("cp2k-momfix")
load("MPICH/3.2-GCC-5.3.1-snapshot-20160419-2.25")
load("imkl/2017.1.132-iimpi-2017a")
prepend_path("LD_LIBRARY_PATH","/home/chalabaj/install/cp2k-5.1/lib")
prepend_path("LIBRARY_PATH","/home/chalabaj/install/cp2k-5.1/lib")
prepend_path("PATH","/home/chalabaj/install/cp2k-5.1/exe/local")
setenv("CP2K_DATA_DIR","/home/chalabaj/install/cp2k-5.1/data")

