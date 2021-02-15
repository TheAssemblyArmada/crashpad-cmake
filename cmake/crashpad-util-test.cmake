# Crashpad util test
crashpad_add_test(crashpad_util_test)
add_dependencies(crashpad_util_test http_transport_test_server)

target_sources(crashpad_util_test PRIVATE
    ${crashpad_git_SOURCE_DIR}/util/file/delimited_file_reader_test.cc
    ${crashpad_git_SOURCE_DIR}/util/file/directory_reader_test.cc
    ${crashpad_git_SOURCE_DIR}/util/file/file_io_test.cc
    ${crashpad_git_SOURCE_DIR}/util/file/file_reader_test.cc
    ${crashpad_git_SOURCE_DIR}/util/file/filesystem_test.cc
    ${crashpad_git_SOURCE_DIR}/util/file/string_file_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/arraysize_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/clock_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/from_pointer_cast_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/initialization_state_dcheck_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/initialization_state_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/paths_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/random_string_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/range_set_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/reinterpret_bytes_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/scoped_forbid_return_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/time_test.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/uuid_test.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_body_gzip_test.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_body_test.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_body_test_util.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_body_test_util.h
    ${crashpad_git_SOURCE_DIR}/util/net/http_multipart_builder_test.cc
    ${crashpad_git_SOURCE_DIR}/util/net/url_test.cc
    ${crashpad_git_SOURCE_DIR}/util/numeric/checked_address_range_test.cc
    ${crashpad_git_SOURCE_DIR}/util/numeric/checked_range_test.cc
    ${crashpad_git_SOURCE_DIR}/util/numeric/in_range_cast_test.cc
    ${crashpad_git_SOURCE_DIR}/util/numeric/int128_test.cc
    ${crashpad_git_SOURCE_DIR}/util/process/process_memory_range_test.cc
    ${crashpad_git_SOURCE_DIR}/util/process/process_memory_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/aligned_allocator_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/map_insert_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/string_number_conversion_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/strlcpy_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/strnlen_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/thread_safe_vector_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/base94_output_stream_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/file_encoder_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/log_output_stream_test.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/test_output_stream.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/test_output_stream.h
    ${crashpad_git_SOURCE_DIR}/util/stream/zlib_output_stream_test.cc
    ${crashpad_git_SOURCE_DIR}/util/string/split_string_test.cc
    ${crashpad_git_SOURCE_DIR}/util/synchronization/semaphore_test.cc
    ${crashpad_git_SOURCE_DIR}/util/thread/thread_log_messages_test.cc
    ${crashpad_git_SOURCE_DIR}/util/thread/thread_test.cc
    ${crashpad_git_SOURCE_DIR}/util/thread/worker_thread_test.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_transport_test.cc
)


if(UNIX)
    target_sources(crashpad_util_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/util/posix/process_info_test.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/signals_test.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/symbolic_constants_posix_test.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/scoped_mmap_test.cc
    )

    if(NOT APPLE)
        target_sources(crashpad_util_test PRIVATE
            ${crashpad_git_SOURCE_DIR}/util/linux/auxiliary_vector_test.cc
            ${crashpad_git_SOURCE_DIR}/util/linux/memory_map_test.cc
            ${crashpad_git_SOURCE_DIR}/util/linux/proc_stat_reader_test.cc
            ${crashpad_git_SOURCE_DIR}/util/linux/proc_task_reader_test.cc
            ${crashpad_git_SOURCE_DIR}/util/linux/ptrace_broker_test.cc
            ${crashpad_git_SOURCE_DIR}/util/linux/ptracer_test.cc
            ${crashpad_git_SOURCE_DIR}/util/linux/scoped_ptrace_attach_test.cc
            ${crashpad_git_SOURCE_DIR}/util/linux/socket_test.cc
            ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_test_util_linux.cc
            ${crashpad_git_SOURCE_DIR}/util/process/process_memory_sanitized_test.cc
        )
    endif()
endif()

if(APPLE)
    target_sources(crashpad_util_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/util/mac/launchd_test.mm
        ${crashpad_git_SOURCE_DIR}/util/mac/mac_util_test.mm
        ${crashpad_git_SOURCE_DIR}/util/mac/service_management_test.mm
        ${crashpad_git_SOURCE_DIR}/util/mac/xattr_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/child_port_handshake_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/child_port_server_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/composite_mach_message_server_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exc_client_variants_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exc_server_variants_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exception_behaviors_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exception_ports_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exception_types_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/mach_extensions_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/mach_message_server_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/mach_message_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/notify_server_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/scoped_task_suspend_test.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/symbolic_constants_mach_test.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_test_util_mac.cc
        ${crashpad_git_SOURCE_DIR}/util/process/process_memory_mac_test.cc
    )
endif()

if(WIN32)
    target_sources(crashpad_util_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_test_util_win.cc
        ${crashpad_git_SOURCE_DIR}/util/win/command_line_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/critical_section_with_debug_info_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/exception_handler_server_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/get_function_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/handle_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/initial_client_data_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/loader_lock_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/process_info_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/registration_protocol_win_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/safe_terminate_process_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/scoped_process_suspend_test.cc
        ${crashpad_git_SOURCE_DIR}/util/win/session_end_watcher_test.cc
    )
endif()

target_link_libraries(crashpad_util_test PRIVATE
    crashpad_test
    gmock
    gtest
    gtest_main
    crashpad_client
    crashpad_handler_obj
    minichromium
    ZLIB::ZLIB
    $<$<CXX_COMPILER_ID:MSVC>:rpcrt4.lib>
    $<$<CXX_COMPILER_ID:MSVC>:dbghelp.lib>
)

if(WIN32)
    add_executable(crashpad_util_test_process_info_test_child 
        ${crashpad_git_SOURCE_DIR}/util/win/process_info_test_child.cc
    )
  
    set_target_properties(crashpad_util_test_process_info_test_child
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_util_test_process_info_test_child PRIVATE
        crashpad_common
        crashpad_compat
    )

    add_executable(crashpad_util_test_safe_terminate_process_test_child         
        ${crashpad_git_SOURCE_DIR}/util/win/safe_terminate_process_test_child.cc
    )
    
    set_target_properties(crashpad_util_test_safe_terminate_process_test_child
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_util_test_safe_terminate_process_test_child PRIVATE
        crashpad_common
        crashpad_compat
    )

    add_library(crashpad_util_test_loader_lock_test MODULE
        ${crashpad_git_SOURCE_DIR}/util/win/loader_lock_test_dll.cc
    )

    set_target_properties(crashpad_util_test_loader_lock_test
        PROPERTIES
        CXX_STANDARD 14
        POSITION_INDEPENDENT_CODE ON
        CXX_VISIBILITY_PRESET "hidden"
        C_VISIBILITY_PRESET "hidden"
        VISIBILITY_INLINES_HIDDEN ON
    )
    
    target_link_libraries(crashpad_util_test_loader_lock_test PRIVATE
        crashpad_common
        crashpad_compat
        crashpad_util
        minichromium
    )
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/util/net/testdata
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/util/net
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${crashpad_git_SOURCE_DIR}/util/net/testdata ${CMAKE_BINARY_DIR}/util/net/testdata
)