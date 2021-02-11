find_package(Python2 COMPONENTS Interpreter REQUIRED)
find_program(MIG_EXE mig REQUIRED)
message("Found mig at ${MIG_EXE}")

function(target_add_mig_sources target filename)
    cmake_parse_arguments(MIG "COMPILE_SERVER;COMPILE_CLIENT" "ARCH;TARGET_DIR" "" ${ARGN})

    if(NOT MIG_USER_SOURCE_SUFFIX)
        set(MIG_USER_SOURCE_SUFFIX User.c)
    endif()
    if(NOT MIG_USER_HEADER_SUFFIX)
        set(MIG_USER_HEADER_SUFFIX .h)
    endif()
    if(NOT MIG_SERVER_SOURCE_SUFFIX)
        set(MIG_SERVER_SOURCE_SUFFIX Server.c)
    endif()
    if(NOT MIG_SERVER_HEADER_SUFFIX)
        set(MIG_SERVER_HEADER_SUFFIX Server.h)
    endif()
    if(NOT MIG_TARGET_DIR)
        set(MIG_TARGET_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    
    get_target_property(_incs ${target} INCLUDE_DIRECTORIES)

    foreach(inc ${_incs})
        list(APPEND MIG_INCLUDE --include "${inc}")
    endforeach()

    if(NOT MIG_ARCH)
        set(MIG_ARCH x86_64)
    endif()

    get_filename_component(basename ${filename} NAME_WE)
    add_custom_command(
        OUTPUT
                ${MIG_TARGET_DIR}/${basename}${MIG_USER_SOURCE_SUFFIX}
                ${MIG_TARGET_DIR}/${basename}${MIG_SERVER_SOURCE_SUFFIX}
                ${MIG_TARGET_DIR}/${basename}${MIG_USER_HEADER_SUFFIX}
                ${MIG_TARGET_DIR}/${basename}${MIG_SERVER_HEADER_SUFFIX}
        COMMAND ${Python2_EXECUTABLE}
        ARGS    ${crashpad_git_SOURCE_DIR}/util/mach/mig.py
                ${filename}
                ${MIG_TARGET_DIR}/${basename}${MIG_USER_SOURCE_SUFFIX}
                ${MIG_TARGET_DIR}/${basename}${MIG_SERVER_SOURCE_SUFFIX}
                ${MIG_TARGET_DIR}/${basename}${MIG_USER_HEADER_SUFFIX}
                ${MIG_TARGET_DIR}/${basename}${MIG_SERVER_HEADER_SUFFIX}
                --mig-path ${MIG_EXE}
                --arch ${MIG_ARCH}
                ${MIG_INCLUDE}
        COMMENT "Mig ${filename}" VERBATIM
    )

    if(MIG_COMPILE_SERVER)
        target_sources(${target} PRIVATE
            ${MIG_TARGET_DIR}/${basename}${MIG_SERVER_SOURCE_SUFFIX}
            ${MIG_TARGET_DIR}/${basename}${MIG_SERVER_HEADER_SUFFIX}
        )
    endif()
    if(MIG_COMPILE_CLIENT)
        target_sources(${target} PRIVATE
            ${MIG_TARGET_DIR}/${basename}${MIG_USER_SOURCE_SUFFIX}
            ${MIG_TARGET_DIR}/${basename}${MIG_USER_HEADER_SUFFIX}
        )
    endif()
endfunction()