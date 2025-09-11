@echo off

set "LibName=lib_CUDA"

mkdir %LibName%

cmake -S ./Source -B ./%LibName%  -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Release -DAMReX_PRECISION=SINGLE -DAMReX_GPU_BACKEND=CUDA   -DAMReX_MPI=OFF   -DAMReX_FORTRAN=OFF   -DAMReX_EB=EB  -DAMReX_PARTICLES=OFF   -DCMAKE_CUDA_COMPILER=nvcc  

cmake --build %LibName% --config Release -j 32

echo AMReX Library Builded
pause
