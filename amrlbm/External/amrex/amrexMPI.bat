@echo off

set "LibName=lib_MPI"

mkdir %LibName%

cmake -S ./Source -B ./%LibName%  -DCMAKE_BUILD_TYPE=Release  -DAMReX_FORTRAN=OFF   -DAMReX_EB=EB  -DAMReX_PARTICLES=OFF  

cmake --build %LibName% --config Release -j 32

echo AMReX Library Builded
pause