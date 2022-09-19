
#
# INPUTs:
#   SLOT: winnative | emscripten | android | apple 

# Autodetect slotname
if(NOT SLOT)
    if(WIN32)
        set(SLOT winnative)
    elseif(APPLE)
        set(SLOT apple)
    else()
        set(SLOT emscripten)
    endif()
    message(STATUS "(You should not see this in CI)")
    message(STATUS "SLOT := winnative | emscripten | android | apple")
    message(STATUS "Testing for SLOT(${SLOT})")
endif()

set(VCPKG_ROOT ${CMAKE_CURRENT_LIST_DIR}/vcpkg)
set(pkgs oniguruma gmp)
if(SLOT STREQUAL "winnative")
    # MSVC requires libatomic-ops for embedded BoehmGC
    list(APPEND pkgs libatomic-ops)
endif()
if(SLOT STREQUAL "winnative")
    set(triples x64-windows x86-windows)
elseif(SLOT STREQUAL "android")
    set(triples arm64-android arm-android)
elseif(SLOT STREQUAL "emscripten")
    set(triples wasm32-emscripten)
elseif(SLOT STREQUAL "apple")
    set(triples arm64-ios arm64-osx x64-ios x64-osx)
endif()

if(NOT triples)
    message(FATAL_ERROR "no triples defined(${SLOT})")
endif()

set(libs)
foreach(t ${triples})
    foreach(p ${pkgs})
        message(STATUS "Request: ${p}:${t}")
        list(APPEND libs ${p}:${t})
    endforeach()
endforeach()

message(STATUS "LIBS = ${libs}")

set(zip_name nmosh-build-prerequisites-${SLOT}.zip)
set(zip ${VCPKG_ROOT}/${zip_name})

# bootstrap vcpkg
if(WIN32)
    set(ext bat)
else()
    set(ext sh)
endif()
message(STATUS "Bootstrap...")
execute_process(
    COMMAND ${VCPKG_ROOT}/bootstrap-vcpkg.${ext}
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
    --output=nmosh-build-prerequisites-${SLOT}
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
