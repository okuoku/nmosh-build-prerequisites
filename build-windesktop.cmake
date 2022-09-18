set(VCPKG_ROOT ${CMAKE_CURRENT_LIST_DIR}/vcpkg)
set(version 0.1.0)
set(libs
    oniguruma:x64-windows
    oniguruma:x86-windows
    gmp:x64-windows
    gmp:x86-windows)
set(nupkg_name vcpkg-nmosh-prereq.${version}.nupkg)
set(nupkg ${VCPKG_ROOT}/${nupkg_name})

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

if(NOT EXISTS ${nupkg})
    set(src $ENV{VCPKG_INSTALLATION_ROOT}/${nupkg_name})
    set(dest ${nupkg})
    message(STATUS "Copy...(${src} => ${dest})")
    file(COPY ${src} DESTINATION ${VCPKG_ROOT})
endif()
