@echo on
setlocal EnableDelayedExpansion

:: Same targets as build.sh for CUDA 12.x and 13.x: SASS for Turing through
:: Blackwell, plus PTX for sm_120 so newer GPUs can JIT. A pre-set
:: CMAKE_CUDA_ARCHS is respected.
if not defined CMAKE_CUDA_ARCHS set "CMAKE_CUDA_ARCHS=75-real;80-real;86-real;89-real;90-real;100-real;120-real;120"

mkdir build
cd build

cmake -G Ninja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_CUDA_ARCHITECTURES="%CMAKE_CUDA_ARCHS%" ^
    -DBUILD_PYTHON=ON ^
    ..
if errorlevel 1 exit 1

cmake --build . --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cd python
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit 1
