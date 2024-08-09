#!/bin/bash
set -ex

if [[ ${cuda_compiler_version} == 11.8 ]]; then
    export CMAKE_CUDA_ARCHS="53-real;62-real;72-real;75-real;80-real;86-real;89"
elif [[ ${cuda_compiler_version} == 12.0 ]]; then
    export CMAKE_CUDA_ARCHS="53-real;62-real;72-real;75-real;80-real;86-real;89-real;90"
fi

# workaround for cmake-vs-nvcc: make sure we pick up the our own c-compiler
ln -s $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-cc $BUILD_PREFIX/bin/gcc
ln -s $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-c++ $BUILD_PREFIX/bin/c++
ln -s $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-g++ $BUILD_PREFIX/bin/g++

mkdir build
cd build

cmake \
    ${CMAKE_ARGS} \
    -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHS}" \
    ..

# compile
make -j$CPU_COUNT

cd python
pip install .
