# Minidump library
add_library(crashpad_minidump STATIC)

set_target_properties(crashpad_minidump PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_link_libraries(crashpad_minidump PRIVATE
    minichromium
    crashpad_common
    crashpad_compat
    crashpad_util
)

target_sources(crashpad_minidump PRIVATE
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_annotation_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_byte_array_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_context_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_crashpad_info_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_exception_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_extensions.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_file_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_handle_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_memory_info_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_memory_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_misc_info_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_module_crashpad_info_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_module_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_rva_list_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_simple_string_dictionary_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_stream_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_string_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_system_info_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_thread_id_map.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_thread_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_unloaded_module_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_user_extension_stream_data_source.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_user_stream_writer.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_writable.cc
    ${crashpad_git_SOURCE_DIR}/minidump/minidump_writer_util.cc
)
