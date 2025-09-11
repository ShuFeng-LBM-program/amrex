@echo off

set "LibName=lib_DFT"

mkdir %LibName%

cmake -S ./Source -B ./%LibName%  -DCMAKE_BUILD_TYPE=Release -DAMReX_MPI=OFF -DAMReX_FORTRAN=OFF   -DAMReX_EB=EB  -DAMReX_PARTICLES=OFF  

cmake --build %LibName% --config Release -j 32

echo AMReX Library Builded
pause