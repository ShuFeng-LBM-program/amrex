@echo off

set "LibName=lib_DFT"

mkdir %LibName%

cmake -S ./Source -B ./%LibName% -DAMReX_MPI=OFF  -DCMAKE_BUILD_TYPE=Release  -DAMReX_FORTRAN=OFF   -DAMReX_EB=EB  -DAMReX_PARTICLES=OFF   -DAMReX_LINEAR_SOLVERS_EM=OFF -DAMReX_AMRLEVEL=OFF -DAMReX_LINEAR_SOLVERS_INCFLO=OFF -DAMReX_LINEAR_SOLVERS=OFF  

cmake --build %LibName% --config Release -j 32

echo AMReX Library Builded
pause