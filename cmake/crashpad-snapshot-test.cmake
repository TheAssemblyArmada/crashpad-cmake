add_library(snapshot_test_support OBJECT)

set_target_properties(snapshot_test_support
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_sources(snapshot_test_support
    PRIVATE
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_cpu_context.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_cpu_context.h
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_exception_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_exception_snapshot.h
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_memory_map_region_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_memory_map_region_snapshot.h
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_memory_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_memory_snapshot.h
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_module_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_module_snapshot.h
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_process_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_process_snapshot.h
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_system_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_system_snapshot.h
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_thread_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/test/test_thread_snapshot.h
)

target_link_libraries(snapshot_test_support PRIVATE
    crashpad_common
    crashpad_compat
    minichromium
    crashpad_util
)

crashpad_add_test(crashpad_snapshot_test)

if(NOT MSVC)
    target_compile_options(crashpad_snapshot_test PRIVATE
        -Wno-maybe-uninitialized
    )
endif()

target_sources(crashpad_snapshot_test PRIVATE
    ${crashpad_git_SOURCE_DIR}/snapshot/cpu_context_test.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/memory_snapshot_test.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/process_snapshot_minidump_test.cc
)

if(APPLE)
    target_sources(crashpad_snapshot_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/cpu_context_mac_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_annotations_reader_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_reader_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_segment_reader_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/process_reader_mac_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/system_snapshot_mac_test.cc
    )
endif()

if(UNIX AND NOT APPLE)
    target_sources(crashpad_snapshot_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/debug_rendezvous_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/exception_snapshot_linux_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/process_reader_linux_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/system_snapshot_linux_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/sanitized/process_snapshot_sanitized_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/sanitized/sanitization_information_test.cc
    )
else()
    target_sources(crashpad_snapshot_test PRIVATE 
        ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_info_client_options_test.cc
    )
endif()

if(NOT APPLE)
    target_sources(crashpad_snapshot_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_types/crashpad_info_reader_test.cc
    )
endif()

if(WIN32)
    target_sources(crashpad_snapshot_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/win/cpu_context_win_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/exception_snapshot_win_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/extra_memory_ranges_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/module_snapshot_win_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/pe_image_reader_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/process_reader_win_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/process_snapshot_win_test.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/system_snapshot_win_test.cc
    )
else()
    target_sources(crashpad_snapshot_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/posix/timezone_test.cc
    )
endif()

target_link_libraries(crashpad_snapshot_test PRIVATE
    snapshot_test_support
    crashpad_client
    crashpad_test
    minichromium
    crashpad_util
    gtest
    gtest_main
    crashpad_handler_obj
    ZLIB::ZLIB
)

add_dependencies(crashpad_snapshot_test
    crashpad_snapshot_test_module
    crashpad_snapshot_test_module_large
    crashpad_snapshot_test_module_small
)

set(CMAKE_SHARED_MODULE_PREFIX "")

add_library(crashpad_snapshot_test_module MODULE 
    ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_info_client_options_test_module.cc
)

set_target_properties(crashpad_snapshot_test_module
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_link_libraries(crashpad_snapshot_test_module PRIVATE
    crashpad_common
    crashpad_client
    AppleFrameworks
)

add_library(crashpad_snapshot_test_module_large MODULE
    ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_info_size_test_module.cc
)

set_target_properties(crashpad_snapshot_test_module_large
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_compile_definitions(crashpad_snapshot_test_module_large PRIVATE 
    -DCRASHPAD_INFO_SIZE_TEST_MODULE_LARGE
)

target_link_libraries(crashpad_snapshot_test_module_large PRIVATE
    crashpad_common
    minichromium
    AppleFrameworks
)

if(UNIX)
    target_link_libraries(crashpad_snapshot_test_module_large PRIVATE crashpad_util)
endif()

add_library(crashpad_snapshot_test_module_small MODULE
    ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_info_size_test_module.cc
)

set_target_properties(crashpad_snapshot_test_module_small
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_compile_definitions(crashpad_snapshot_test_module_small PRIVATE 
    CRASHPAD_INFO_SIZE_TEST_MODULE_SMALL
)

target_link_libraries(crashpad_snapshot_test_module_small PRIVATE
    crashpad_common
    AppleFrameworks
)
if(UNIX)
    target_link_libraries(crashpad_snapshot_test_module_small PRIVATE crashpad_util)
endif()

if(UNIX AND NOT APPLE)
    add_library(crashpad_snapshot_test_both_dt_hash_styles MODULE
        ${crashpad_git_SOURCE_DIR}/snapshot/hash_types_test.cc
    )

    set_target_properties(crashpad_snapshot_test_both_dt_hash_styles
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_snapshot_test_both_dt_hash_styles PRIVATE crashpad_common)
    
    target_link_options(crashpad_snapshot_test_both_dt_hash_styles PRIVATE
        "-Wl,--hash-style=both"
    )
endif()

if(APPLE)
    add_library(crashpad_snapshot_test_module_crashy_initializer MODULE
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_annotations_reader_test_module_crashy_initializer.cc
    )

    set_target_properties(crashpad_snapshot_test_module_crashy_initializer
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )

    target_link_libraries(crashpad_snapshot_test_module_crashy_initializer PRIVATE 
        crashpad_common
    )
    
    add_executable(crashpad_snapshot_test_no_op
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_annotations_reader_test_no_op.cc
    )
    
    set_target_properties(crashpad_snapshot_test_no_op
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )

    target_link_libraries(crashpad_snapshot_test_no_op PRIVATE 
        crashpad_common
    )

    add_dependencies(crashpad_snapshot_test
        crashpad_snapshot_test_module_crashy_initializer
        crashpad_snapshot_test_no_op
    )
endif()

if(WIN32)
    add_executable(crashpad_snapshot_test_annotations
        ${crashpad_git_SOURCE_DIR}/snapshot/win/crashpad_snapshot_test_annotations.cc
    )
    
    set_target_properties(crashpad_snapshot_test_annotations
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_snapshot_test_annotations PRIVATE
        crashpad_common
        crashpad_client
        minichromium
    )

    add_executable(crashpad_snapshot_test_crashing_child
        ${crashpad_git_SOURCE_DIR}/snapshot/win/crashpad_snapshot_test_crashing_child.cc
    )
    
    set_target_properties(crashpad_snapshot_test_crashing_child
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_snapshot_test_crashing_child PRIVATE
        crashpad_common
        crashpad_client
        minichromium
        crashpad_util
    )

    add_executable(crashpad_snapshot_test_dump_without_crashing
        ${crashpad_git_SOURCE_DIR}/snapshot/win/crashpad_snapshot_test_dump_without_crashing.cc
    )
    
    set_target_properties(crashpad_snapshot_test_dump_without_crashing
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    target_link_libraries(crashpad_snapshot_test_dump_without_crashing PRIVATE
        crashpad_common
        crashpad_client
        minichromium
        crashpad_util
    )

    add_executable(crashpad_snapshot_test_extra_memory_ranges
        ${crashpad_git_SOURCE_DIR}/snapshot/win/crashpad_snapshot_test_extra_memory_ranges.cc
    )
    
    set_target_properties(crashpad_snapshot_test_extra_memory_ranges
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_snapshot_test_extra_memory_ranges PRIVATE
        crashpad_common
        crashpad_client
        minichromium
    )

    add_executable(crashpad_snapshot_test_image_reader
        ${crashpad_git_SOURCE_DIR}/snapshot/win/crashpad_snapshot_test_image_reader.cc
    )
    
    set_target_properties(crashpad_snapshot_test_image_reader
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_snapshot_test_image_reader PRIVATE
        crashpad_common
        crashpad_client
        minichromium
        crashpad_util
    )

    add_library(crashpad_snapshot_test_image_reader_module MODULE
        ${crashpad_git_SOURCE_DIR}/snapshot/win/crashpad_snapshot_test_image_reader_module.cc
    )
    
    set_target_properties(crashpad_snapshot_test_image_reader_module
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_snapshot_test_image_reader_module PRIVATE
        crashpad_common
        crashpad_client
        minichromium
    )

    add_dependencies(crashpad_snapshot_test
        crashpad_snapshot_test_annotations
        crashpad_snapshot_test_crashing_child
        crashpad_snapshot_test_dump_without_crashing
        crashpad_snapshot_test_extra_memory_ranges
        crashpad_snapshot_test_image_reader
        crashpad_snapshot_test_image_reader_module
    )
endif()