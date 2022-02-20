# Compat library.
if(APPLE)
    add_library(crashpad_compat INTERFACE)
else()
    add_library(crashpad_compat STATIC)
    target_link_libraries(crashpad_compat PRIVATE crashpad_common)

    set_target_properties(crashpad_compat
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
endif()


if(WIN32)
    target_sources(crashpad_compat PRIVATE
        ${crashpad_git_SOURCE_DIR}/compat/win/strings.cc
        ${crashpad_git_SOURCE_DIR}/compat/win/time.cc
        ${crashpad_git_SOURCE_DIR}/third_party/getopt/getopt.cc
    )

    target_include_directories(crashpad_compat PUBLIC
        ${crashpad_git_SOURCE_DIR}/compat/win
        ${crashpad_git_SOURCE_DIR}/third_party/getopt
    )
else()
    target_include_directories(crashpad_compat INTERFACE
        ${crashpad_git_SOURCE_DIR}/compat/non_win
    )
endif()

# Linux mostly.
if(UNIX AND NOT APPLE)
    target_sources(crashpad_compat PRIVATE
        ${crashpad_git_SOURCE_DIR}/compat/linux/sys/mman_memfd_create.cc
    )

    target_include_directories(crashpad_compat PUBLIC
        ${crashpad_git_SOURCE_DIR}/compat/linux
    )
else()
    target_include_directories(crashpad_compat INTERFACE
        ${crashpad_git_SOURCE_DIR}/compat/non_elf
    )
endif()

if(APPLE)
    target_include_directories(crashpad_compat INTERFACE
        ${crashpad_git_SOURCE_DIR}/compat/mac
    )
else()
    target_include_directories(crashpad_compat PUBLIC
        ${crashpad_git_SOURCE_DIR}/compat/non_mac
    )
endif()

if(ANDROID)
    target_sources(crashpad_compat PRIVATE
        ${crashpad_git_SOURCE_DIR}/compat/android/android/api-level.cc
        ${crashpad_git_SOURCE_DIR}/compat/android/dlfcn_internal.cc
        ${crashpad_git_SOURCE_DIR}/compat/android/sys/epoll.cc
        ${crashpad_git_SOURCE_DIR}/compat/android/sys/mman.cc
    )

    target_include_directories(crashpad_compat PUBLIC
        ${crashpad_git_SOURCE_DIR}/compat/android
    )
endif()
