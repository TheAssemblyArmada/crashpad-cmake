# Snapshot library
add_library(crashpad_snapshot STATIC)

set_target_properties(crashpad_snapshot PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_link_libraries(crashpad_snapshot PRIVATE
    minichromium
    crashpad_common
    crashpad_compat
    crashpad_client
    crashpad_util
)

target_sources(crashpad_snapshot PRIVATE
    ${crashpad_git_SOURCE_DIR}/snapshot/annotation_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/capture_memory.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/cpu_context.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_info_client_options.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/handle_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/memory_snapshot.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/exception_snapshot_minidump.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/memory_snapshot_minidump.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/minidump_annotation_reader.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/minidump_context_converter.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/minidump_simple_string_dictionary_reader.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/minidump_string_list_reader.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/minidump_string_reader.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/module_snapshot_minidump.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/process_snapshot_minidump.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/system_snapshot_minidump.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/minidump/thread_snapshot_minidump.cc
    ${crashpad_git_SOURCE_DIR}/snapshot/unloaded_module_snapshot.cc
)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
    target_sources(crashpad_snapshot PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/x86/cpuid_reader.cc
    )
endif()

if(UNIX)
    target_sources(crashpad_snapshot PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/posix/timezone.cc
    )
endif()

if(APPLE)
    target_sources(crashpad_snapshot PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/cpu_context_mac.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/exception_snapshot_mac.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_annotations_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_segment_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/mach_o_image_symbol_table_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/module_snapshot_mac.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/process_reader_mac.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/process_snapshot_mac.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/custom.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/system_snapshot_mac.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/mac/thread_snapshot_mac.cc
    )
endif()

if(UNIX AND NOT APPLE)
    target_sources(crashpad_snapshot PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_types/image_annotation_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/cpu_context_linux.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/debug_rendezvous.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/exception_snapshot_linux.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/process_reader_linux.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/process_snapshot_linux.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/system_snapshot_linux.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/linux/thread_snapshot_linux.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/sanitized/memory_snapshot_sanitized.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/sanitized/module_snapshot_sanitized.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/sanitized/process_snapshot_sanitized.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/sanitized/sanitization_information.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/sanitized/thread_snapshot_sanitized.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/elf/elf_dynamic_array_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/elf/elf_image_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/elf/elf_symbol_table_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/elf/module_snapshot_elf.cc
    )
endif()

if(WIN32)
    target_sources(crashpad_snapshot PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/win/capture_memory_delegate_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/cpu_context_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/exception_snapshot_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/memory_map_region_snapshot_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/module_snapshot_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/pe_image_annotations_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/pe_image_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/pe_image_resource_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/process_reader_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/process_snapshot_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/process_subrange_reader.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/system_snapshot_win.cc
        ${crashpad_git_SOURCE_DIR}/snapshot/win/thread_snapshot_win.cc
    )
endif()

if(NOT APPLE)
    target_sources(crashpad_snapshot PRIVATE
        ${crashpad_git_SOURCE_DIR}/snapshot/crashpad_types/crashpad_info_reader.cc
    )
endif()
