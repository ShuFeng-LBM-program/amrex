#!/bin/bash

# Default settings
BACKEND="cpu"               # 默认后端：gpu 或 cpu
PRECISION="single"          # 默认精度：single 或 double
USE_MPI="OFF"               # MPI开关：OFF 或 ON
CLEAN=false                 # 是否清理旧目录：false 或 true
BUILD=true                 # 是否立即执行编译：false 或 true
JOBS=8                      # 编译并发数
SOURCE_DIR="./source"       # 源码目录

usage() {
    echo "Usage: $0 [arguments]"
    echo "arguments:"
    echo "  -e, --backend [gpu|cpu]         指定后端 (默认cpu)"
    echo "  -p, --precision [single|double] 指定浮点精度 (默认single)"
    echo "  -m, --mpi [ON|OFF]              开启MPI (默认OFF)"
    echo "  -c, --clean                     编译前清除旧的构建目录"
    echo "  -b, --build                     配置完成后立即执行编译 (cmake --build)"
    echo "  -j, --jobs [N]                  指定编译使用的核心数 (默认8)"
    echo "  -h, --help                      显示帮助信息"
    exit 1
}


while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--backend)
            BACKEND="$2"
            shift 2
            ;;
        -p|--precision)
            PRECISION="$2"
            shift 2
            ;;
        -m|--mpi)
            USE_MPI="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift 1
            ;;
        -b|--build)
            BUILD=true
            shift 1
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown parameter $1"
            usage
            ;;
    esac
done

if [[ "$BACKEND" != "gpu" && "$BACKEND" != "cpu" ]]; then
    echo "Error: Backend should be 'gpu' or 'cpu'"
    exit 1
fi

if [[ "$PRECISION" != "single" && "$PRECISION" != "double" ]]; then
    echo "Error: Precision should be 'single' or 'double'"
    exit 1
fi

BUILD_DIR="./lib_cpu_sp"
CMAKE_ARGS=""

COMMON_CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release \
                   -DAMReX_FORTRAN=OFF \
                   -DAMReX_EB=EB \
                   -DAMReX_PARTICLES=OFF \
                   -DAMReX_LINEAR_SOLVERS_EM=OFF \
                   -DAMReX_LINEAR_SOLVERS_INCFLO=OFF \
                   -DAMReX_LINEAR_SOLVERS=OFF \
                   -DAMReX_AMRLEVEL=OFF"

if [[ "$PRECISION" == "single" ]]; then
    COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DAMReX_PRECISION=SINGLE"
    PRECISION_SUFFIX="sp"
else
    COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DAMReX_PRECISION=DOUBLE"
    PRECISION_SUFFIX="dp"
fi

if [[ "$USE_MPI" == "ON" ]]; then
    COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DAMReX_MPI=ON"
    USE_MPI_SUFFIX="_mpi"
else
    COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DAMReX_MPI=OFF"
    USE_MPI_SUFFIX=""
fi

if [[ "$BACKEND" == "gpu" ]]; then
    BUILD_DIR="lib_cuda_${PRECISION_SUFFIX}${USE_MPI_SUFFIX}"
    CMAKE_ARGS="$COMMON_CMAKE_ARGS \
                -DCMAKE_CUDA_COMPILER=nvcc \
                -DAMReX_GPU_BACKEND=CUDA"
    echo "Configurations: CUDA backend, precision: $PRECISION_SUFFIX, MPI: $USE_MPI"
elif [[ "$BACKEND" == "cpu" ]]; then
    BUILD_DIR="lib_cpu_${PRECISION_SUFFIX}${USE_MPI_SUFFIX}"
    CMAKE_ARGS="$COMMON_CMAKE_ARGS \
                -DAMReX_GPU_BACKEND=NONE"
    echo "Configurations: CPU backend, precision: $PRECISION_SUFFIX, MPI: $USE_MPI"
fi

# Build process
if [ "$CLEAN" = true ]; then
    if [ -d "$BUILD_DIR" ]; then
        echo "Purging build folder $BUILD_DIR ..."
        rm -rf "$BUILD_DIR"
    fi
fi

mkdir -p "$BUILD_DIR"

echo "Configuring CMake ..."
cmake -S "$SOURCE_DIR" -B "$BUILD_DIR" $CMAKE_ARGS

if [ $? -ne 0 ]; then
    echo "Error: configure CMake failed."
    exit 1
fi

if [ "$BUILD" = true ]; then
    echo "-----------------------------------"
    echo "Start building with $JOBS processors ..."
    cmake --build "$BUILD_DIR" --config Release -j "$JOBS"

    if [ $? -ne 0 ]; then
        echo "Error: building failed."
        exit 1
    else
        echo "===================================="
        echo " AMReX Library ($BACKEND / $PRECISION precision/ MPI: $USE_MPI) has been successfully built. "
        echo "===================================="
    fi
else
    echo "===================================="
    echo " AMReX Library ($BACKEND / $PRECISION precision/ MPI: $USE_MPI) CMake configuration done. "
    echo " Run cmake --build $BUILD_DIR --config Release -j $JOBS to build."
    echo "===================================="
fi

