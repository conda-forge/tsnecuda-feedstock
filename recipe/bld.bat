@echo on

SetLocal EnableDelayedExpansion

:: %MY_VAR:~0,2% selects first two characters
if "%cuda_compiler_version:~0,2%"=="10" (
    set "CMAKE_CUDA_ARCHS=35-real;50-real;52-real;60-real;61-real;70-real;75"
)
if "%cuda_compiler_version:~0,2%"=="11" (
    if "%cuda_compiler_version:~0,4%"=="11.0" (
        REM cuda 11.0 deprecates arches 35, 50
        set "CMAKE_CUDA_ARCHS=52-real;60-real;61-real;70-real;75-real;80"
    ) else (
        set "CMAKE_CUDA_ARCHS=52-real;60-real;61-real;70-real;75-real;80-real;86"
    )
)

set CUDA_CONFIG_ARGS=-DCMAKE_CUDA_ARCHITECTURES=!CMAKE_CUDA_ARCHS!
:: cmake does not generate output for the call below; echo some info
echo Set up extra cmake-args: CUDA_CONFIG_ARGS=!CUDA_CONFIG_ARGS!

:: See more extensive comment in build-lib.sh
:: TODO: Fix this in nvcc-feedstock or cmake-feedstock.
del %BUILD_PREFIX%\bin\nvcc.bat

:: ... and another workaround just to cover more bases
set "CudaToolkitDir=%CUDA_PATH%"
set "CUDAToolkit_ROOT=%CUDA_PATH%"

mkdir build
cd build

cmake ^
    !CUDA_CONFIG_ARGS! ^
    ..  
if %ERRORLEVEL% neq 0 exit 1

make -j$CPU_COUNT
if %ERRORLEVEL% neq 0 exit 1

cd python
pip install .
if %ERRORLEVEL% neq 0 exit 1
