set(VCPKG_ROOT ${CMAKE_CURRENT_LIST_DIR}/vcpkg)
set(version 0.1.0)
set(libs
    oniguruma:x64-windows
    oniguruma:x86-windows
    gmp:x64-windows
    gmp:x86-windows)
set(zip_name nmosh-build-prerequisites-winnative.zip)
set(zip ${VCPKG_ROOT}/${zip_name})

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

# Generate zip package
message(STATUS "export...")
execute_process(
    COMMAND ${VCPKG_ROOT}/vcpkg 
    export ${libs}
    --zip
    --output=nmosh-build-prerequisites-winnative
    RESULT_VARIABLE rr
    )
if(rr)
    message(FATAL_ERROR "export failed(${rr})")
endif()

if(NOT EXISTS ${zip})
    set(src $ENV{VCPKG_INSTALLATION_ROOT}/${zip_name})
    set(dest ${zip})
    message(STATUS "Copy...(${src} => ${dest})")
    file(COPY ${src} DESTINATION ${VCPKG_ROOT})
endif()
