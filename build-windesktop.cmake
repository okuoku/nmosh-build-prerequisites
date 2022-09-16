set(VCPKG_ROOT ${CMAKE_CURRENT_LIST_DIR}/vcpkg)
set(version 0.1.0)
set(libs
    oniguruma:x64-windows
    oniguruma:x86-windows
    gmp:x64-windows
    gmp:x86-windows)
set(nupkg ${VCPKG_ROOT}/vcpkg-nmosh-prereq-${version}.nupkg)

# bootstrap vcpkg
message(STATUS "Bootstrap...")
execute_process(
    COMMAND ${VCPKG_ROOT}/bootstrap-vcpkg.bat
    -disableMetrics
    RESULT_VARIABLE rr)
if(rr)
    message(FATAL_ERROR "Bootstrap failed(${rr})")
endif()

# Build prerequisites
message(STATUS "Build...")
execute_process(
    COMMAND ${VCPKG_ROOT}/vcpkg
    install 
    ${libs}
    RESULT_VARIABLE rr
    )

if(rr)
    message(FATAL_ERROR "Build failed(${rr})")
endif()

# Generate nuget packages
message(STATUS "export...")
execute_process(
    COMMAND ${VCPKG_ROOT}/vcpkg 
    export ${libs}
    --nuget --nuget-id=vcpkg-nmosh-prereq
    --nuget-version=${version}
    "--nuget-description=nmosh prerequisites"
    RESULT_VARIABLE rr
    )
if(rr)
    message(FATAL_ERROR "export failed(${rr})")
endif()
        
