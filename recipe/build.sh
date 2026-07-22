#!/bin/bash
set -ex

# Target architectures per CUDA toolkit. `<sm>-real` emits SASS only; a trailing
# bare `<sm>` (here 120) also emits PTX for JIT forward-compatibility on GPUs
# newer than the toolkit. Datacenter focus: A100 (80), H100/H200 (90),
# B200 (100), plus Turing/Ampere/Ada and GB202/RTX50 (120).
# Blackwell (sm_100 / sm_120) requires CUDA >= 12.8. A pre-set CMAKE_CUDA_ARCHS
# (e.g. for a faster local test build) is respected.
if [[ -z "${CMAKE_CUDA_ARCHS:-}" ]]; then
    if [[ ${cuda_compiler_version} == 11.8 ]]; then
        export CMAKE_CUDA_ARCHS="60-real;70-real;75-real;80-real;86-real;89-real;90"
    elif [[ ${cuda_compiler_version} == 12.* ]]; then
        export CMAKE_CUDA_ARCHS="75-real;80-real;86-real;89-real;90-real;100-real;120-real;120"
    elif [[ ${cuda_compiler_version} == 13.* ]]; then
        # CUDA 13 dropped Maxwell/Pascal/Volta; minimum supported arch is Turing (75).
        export CMAKE_CUDA_ARCHS="75-real;80-real;86-real;89-real;90-real;100-real;120-real;120"
    fi
fi

# workaround for cmake-vs-nvcc: make sure we pick up our own c-compiler
ln -s $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-cc $BUILD_PREFIX/bin/gcc
ln -s $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-c++ $BUILD_PREFIX/bin/c++
ln -s $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-g++ $BUILD_PREFIX/bin/g++

mkdir build
cd build

cmake \
    ${CMAKE_ARGS} \
    -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHS}" \
    -DBUILD_PYTHON=ON \
    ..

# compile
make -j$CPU_COUNT

cd python
pip install . --no-deps --no-build-isolation -vv
