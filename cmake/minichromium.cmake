add_library(minichromium STATIC)

set_target_properties(minichromium
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_link_libraries(minichromium PRIVATE
    crashpad_common
    AppleFrameworks
)

target_sources(minichromium PRIVATE
    ${mini_chromium_git_SOURCE_DIR}/base/debug/alias.cc
    ${mini_chromium_git_SOURCE_DIR}/base/files/file_path.cc
    ${mini_chromium_git_SOURCE_DIR}/base/files/scoped_file.cc
    ${mini_chromium_git_SOURCE_DIR}/base/logging.cc
    ${mini_chromium_git_SOURCE_DIR}/base/process/memory.cc
    ${mini_chromium_git_SOURCE_DIR}/base/rand_util.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/string_number_conversions.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/stringprintf.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/utf_string_conversion_utils.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/utf_string_conversions.cc
    ${mini_chromium_git_SOURCE_DIR}/base/synchronization/lock.cc
    ${mini_chromium_git_SOURCE_DIR}/base/third_party/icu/icu_utf.cc
    ${mini_chromium_git_SOURCE_DIR}/base/threading/thread_local_storage.cc
)

if(WIN32)
    target_sources(minichromium PRIVATE 
        ${mini_chromium_git_SOURCE_DIR}/base/scoped_clear_last_error_win.cc
        ${mini_chromium_git_SOURCE_DIR}/base/memory/page_size_win.cc
        ${mini_chromium_git_SOURCE_DIR}/base/strings/string_util_win.cc
        ${mini_chromium_git_SOURCE_DIR}/base/synchronization/lock_impl_win.cc
        ${mini_chromium_git_SOURCE_DIR}/base/threading/thread_local_storage_win.cc
    )
endif()

if(UNIX)
    target_sources(minichromium PRIVATE
        ${mini_chromium_git_SOURCE_DIR}/base/files/file_util_posix.cc
		${mini_chromium_git_SOURCE_DIR}/base/memory/page_size_posix.cc
        ${mini_chromium_git_SOURCE_DIR}/base/posix/safe_strerror.cc
        ${mini_chromium_git_SOURCE_DIR}/base/synchronization/condition_variable_posix.cc
        ${mini_chromium_git_SOURCE_DIR}/base/synchronization/lock_impl_posix.cc
        ${mini_chromium_git_SOURCE_DIR}/base/threading/thread_local_storage_posix.cc
    )
endif()

if(APPLE)
    target_sources(minichromium PRIVATE
        ${mini_chromium_git_SOURCE_DIR}/base/mac/close_nocancel.cc
        ${mini_chromium_git_SOURCE_DIR}/base/mac/foundation_util.mm
        ${mini_chromium_git_SOURCE_DIR}/base/mac/mach_logging.cc
        ${mini_chromium_git_SOURCE_DIR}/base/mac/scoped_mach_port.cc
        ${mini_chromium_git_SOURCE_DIR}/base/mac/scoped_mach_vm.cc
        ${mini_chromium_git_SOURCE_DIR}/base/mac/scoped_nsautorelease_pool.mm
        ${mini_chromium_git_SOURCE_DIR}/base/strings/sys_string_conversions_mac.mm
    )
endif()
