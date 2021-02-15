add_library(minidump_test_support OBJECT)

set_target_properties(minidump_test_support
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_link_libraries(minidump_test_support PRIVATE
    crashpad_common
    crashpad_compat
)

target_sources(minidump_test_support PRIVATE
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_byte_array_writer_test_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_byte_array_writer_test_util.h
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_context_test_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_context_test_util.h
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_file_writer_test_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_file_writer_test_util.h
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_memory_writer_test_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_memory_writer_test_util.h
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_rva_list_test_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_rva_list_test_util.h
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_string_writer_test_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_string_writer_test_util.h
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_user_extension_stream_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_user_extension_stream_util.h
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_writable_test_util.cc
    ${crashpad_git_SOURCE_DIR}/minidump/test/minidump_writable_test_util.h
)

target_link_libraries(minidump_test_support PRIVATE gtest)

crashpad_add_test(crashpad_minidump_test)
target_sources(crashpad_minidump_test PRIVATE
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_annotation_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_byte_array_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_context_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_crashpad_info_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_exception_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_file_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_handle_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_memory_info_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_memory_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_misc_info_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_module_crashpad_info_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_module_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_rva_list_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_simple_string_dictionary_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_string_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_system_info_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_thread_id_map_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_thread_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_unloaded_module_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_user_stream_writer_test.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_writable_test.cc
)

if(NOT MSVC)
    target_compile_options(crashpad_minidump_test PRIVATE
        -Wno-maybe-uninitialized
    )
endif()

target_link_libraries(crashpad_minidump_test PRIVATE
    crashpad_minidump
    minidump_test_support
    crashpad_test
    gtest
    gtest_main
    crashpad_util
    minichromium
    snapshot_test_support
    crashpad_snapshot
    crashpad_handler_obj
    crashpad_client
    ZLIB::ZLIB
)