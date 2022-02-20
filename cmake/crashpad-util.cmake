# Utils library
add_library(crashpad_util STATIC)

set_target_properties(crashpad_util PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_compile_definitions(crashpad_util PRIVATE
    -DZLIB_CONST
)

target_link_libraries(crashpad_util PRIVATE
    minichromium
    crashpad_common
    crashpad_compat
    AppleFrameworks
    PUBLIC
    ZLIB::ZLIB
)

target_sources(crashpad_util PRIVATE
    ${crashpad_git_SOURCE_DIR}/util/file/delimited_file_reader.cc
    ${crashpad_git_SOURCE_DIR}/util/file/file_helper.cc
    ${crashpad_git_SOURCE_DIR}/util/file/file_io.cc
    ${crashpad_git_SOURCE_DIR}/util/file/file_reader.cc
    ${crashpad_git_SOURCE_DIR}/util/file/file_seeker.cc
    ${crashpad_git_SOURCE_DIR}/util/file/file_writer.cc
    ${crashpad_git_SOURCE_DIR}/util/file/output_stream_file_writer.cc
    ${crashpad_git_SOURCE_DIR}/util/file/scoped_remove_file.cc
    ${crashpad_git_SOURCE_DIR}/util/file/string_file.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/initialization_state_dcheck.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/lexing.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/metrics.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/pdb_structures.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/random_string.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/range_set.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/reinterpret_bytes.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/scoped_forbid_return.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/time.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/uuid.cc
    ${crashpad_git_SOURCE_DIR}/util/misc/zlib.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_body.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_body_gzip.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_multipart_builder.cc
    ${crashpad_git_SOURCE_DIR}/util/net/http_transport.cc
    ${crashpad_git_SOURCE_DIR}/util/net/url.cc
    ${crashpad_git_SOURCE_DIR}/util/numeric/checked_address_range.cc
    ${crashpad_git_SOURCE_DIR}/util/process/process_memory.cc
    ${crashpad_git_SOURCE_DIR}/util/process/process_memory_range.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/aligned_allocator.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/string_number_conversion.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/strlcpy.cc
    ${crashpad_git_SOURCE_DIR}/util/stdlib/strnlen.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/base94_output_stream.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/file_encoder.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/file_output_stream.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/log_output_stream.cc
    ${crashpad_git_SOURCE_DIR}/util/stream/zlib_output_stream.cc
    ${crashpad_git_SOURCE_DIR}/util/string/split_string.cc
    ${crashpad_git_SOURCE_DIR}/util/thread/thread.cc
    ${crashpad_git_SOURCE_DIR}/util/thread/thread_log_messages.cc
    ${crashpad_git_SOURCE_DIR}/util/thread/worker_thread.cc
)

if(UNIX)
    target_sources(crashpad_util PRIVATE
        ${crashpad_git_SOURCE_DIR}/util/file/directory_reader_posix.cc
        ${crashpad_git_SOURCE_DIR}/util/file/file_io_posix.cc
        ${crashpad_git_SOURCE_DIR}/util/file/filesystem_posix.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/clock_posix.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/close_stdio.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/scoped_dir.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/scoped_mmap.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/signals.cc
        ${crashpad_git_SOURCE_DIR}/util/synchronization/semaphore_posix.cc
        ${crashpad_git_SOURCE_DIR}/util/thread/thread_posix.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/close_multiple.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/double_fork_and_exec.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/drop_privileges.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/symbolic_constants_posix.cc
    )
endif()

if(APPLE)
    # The Apple target needs files generating with python
    find_file(EXC_DEFS exc.defs PATH_SUFFIXES /mach)
    find_file(MACH_EXC_DEFS mach_exc.defs PATH_SUFFIXES /mach)
    find_file(NOTIFY_DEFS notify.defs PATH_SUFFIXES /mach)
    include(crashpad-mig)

    target_add_mig_sources(crashpad_util ${EXC_DEFS}
        COMPILE_SERVER TRUE
        COMPILE_CLIENT TRUE
        TARGET_DIR "${crashpad_git_SOURCE_DIR}/util/mach"
    )

    target_add_mig_sources(crashpad_util ${MACH_EXC_DEFS}
        COMPILE_SERVER TRUE
        COMPILE_CLIENT TRUE
        TARGET_DIR "${crashpad_git_SOURCE_DIR}/util/mach"
    )

    target_add_mig_sources(crashpad_util ${NOTIFY_DEFS}
        COMPILE_SERVER TRUE
        COMPILE_CLIENT TRUE
        TARGET_DIR "${crashpad_git_SOURCE_DIR}/util/mach"
    )

    target_add_mig_sources(crashpad_util ${crashpad_git_SOURCE_DIR}/util/mach/child_port.defs
        COMPILE_SERVER TRUE
        COMPILE_CLIENT TRUE
        TARGET_DIR "${crashpad_git_SOURCE_DIR}/util/mach"
    )

    target_sources(crashpad_util PRIVATE
        ${crashpad_git_SOURCE_DIR}/util/mac/launchd.mm
        ${crashpad_git_SOURCE_DIR}/util/mac/mac_util.cc
        ${crashpad_git_SOURCE_DIR}/util/mac/service_management.cc
        ${crashpad_git_SOURCE_DIR}/util/mac/sysctl.cc
        ${crashpad_git_SOURCE_DIR}/util/mac/xattr.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/bootstrap.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/child_port_handshake.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/child_port_server.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/composite_mach_message_server.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exc_client_variants.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exc_server_variants.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exception_behaviors.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exception_ports.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/exception_types.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/mach_extensions.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/mach_message.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/mach_message_server.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/notify_server.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/scoped_task_suspend.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/symbolic_constants_mach.cc
        ${crashpad_git_SOURCE_DIR}/util/mach/task_for_pid.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_mac.S
        ${crashpad_git_SOURCE_DIR}/util/misc/clock_mac.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/paths_mac.cc
        ${crashpad_git_SOURCE_DIR}/util/net/http_transport_mac.mm
        ${crashpad_git_SOURCE_DIR}/util/posix/process_info_mac.cc
        ${crashpad_git_SOURCE_DIR}/util/process/process_memory_mac.cc
        ${crashpad_git_SOURCE_DIR}/util/synchronization/semaphore_mac.cc
    )
endif()

if(UNIX AND NOT APPLE)
    target_sources(crashpad_util PRIVATE
        ${crashpad_git_SOURCE_DIR}/util/net/http_transport_socket.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/auxiliary_vector.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/direct_ptrace_connection.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/exception_handler_client.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/exception_handler_protocol.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/memory_map.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/proc_stat_reader.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/proc_task_reader.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/ptrace_broker.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/ptrace_client.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/ptracer.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/scoped_pr_set_dumpable.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/scoped_pr_set_ptracer.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/scoped_ptrace_attach.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/socket.cc
        ${crashpad_git_SOURCE_DIR}/util/linux/thread_info.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_linux.S
        ${crashpad_git_SOURCE_DIR}/util/misc/paths_linux.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/time_linux.cc
        ${crashpad_git_SOURCE_DIR}/util/posix/process_info_linux.cc
        ${crashpad_git_SOURCE_DIR}/util/process/process_memory_linux.cc
        ${crashpad_git_SOURCE_DIR}/util/process/process_memory_sanitized.cc
    )
endif()

if(WIN32)
    target_sources(crashpad_util PRIVATE
        ${crashpad_git_SOURCE_DIR}/util/file/directory_reader_win.cc
        ${crashpad_git_SOURCE_DIR}/util/file/file_io_win.cc
        ${crashpad_git_SOURCE_DIR}/util/file/filesystem_win.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/clock_win.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/paths_win.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/time_win.cc
        ${crashpad_git_SOURCE_DIR}/util/net/http_transport_win.cc
        ${crashpad_git_SOURCE_DIR}/util/synchronization/semaphore_win.cc
        ${crashpad_git_SOURCE_DIR}/util/thread/thread_win.cc
        ${crashpad_git_SOURCE_DIR}/util/win/command_line.cc
        ${crashpad_git_SOURCE_DIR}/util/win/critical_section_with_debug_info.cc
        ${crashpad_git_SOURCE_DIR}/util/win/exception_handler_server.cc
        ${crashpad_git_SOURCE_DIR}/util/win/get_function.cc
        ${crashpad_git_SOURCE_DIR}/util/win/get_module_information.cc
        ${crashpad_git_SOURCE_DIR}/util/win/handle.cc
        ${crashpad_git_SOURCE_DIR}/util/win/initial_client_data.cc
        ${crashpad_git_SOURCE_DIR}/util/win/loader_lock.cc
        ${crashpad_git_SOURCE_DIR}/util/win/module_version.cc
        ${crashpad_git_SOURCE_DIR}/util/win/nt_internals.cc
        ${crashpad_git_SOURCE_DIR}/util/win/ntstatus_logging.cc
        ${crashpad_git_SOURCE_DIR}/util/win/process_info.cc
        ${crashpad_git_SOURCE_DIR}/util/win/registration_protocol_win.cc
        ${crashpad_git_SOURCE_DIR}/util/win/scoped_handle.cc
        ${crashpad_git_SOURCE_DIR}/util/win/scoped_local_alloc.cc
        ${crashpad_git_SOURCE_DIR}/util/win/scoped_process_suspend.cc
        ${crashpad_git_SOURCE_DIR}/util/win/scoped_set_event.cc
        ${crashpad_git_SOURCE_DIR}/util/win/session_end_watcher.cc
        ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_win.asm
        ${crashpad_git_SOURCE_DIR}/util/win/safe_terminate_process.asm
        ${crashpad_git_SOURCE_DIR}/util/process/process_memory.cc
        ${crashpad_git_SOURCE_DIR}/util/process/process_memory_range.cc
        ${crashpad_git_SOURCE_DIR}/util/process/process_memory_win.cc
    )

    if(MSVC AND CMAKE_SIZEOF_VOID_P EQUAL 4)
        set_source_files_properties(
            ${crashpad_git_SOURCE_DIR}/util/misc/capture_context_win.asm
            PROPERTIES
            COMPILE_FLAGS "/safeseh"
        )

        set_source_files_properties(
            ${crashpad_git_SOURCE_DIR}/util/win/safe_terminate_process.asm
            PROPERTIES
            COMPILE_FLAGS "/safeseh"
        )
    endif()
endif()
