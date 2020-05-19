cmake_minimum_required(VERSION 3.0)
project(crashpad LANGUAGES C CXX)

if(WIN32)
	enable_language(ASM_MASM)
else()
    enable_language(ASM)
endif()

find_package(ZLIB)

if(NOT ZLIB_FOUND AND NOT TARGET ZLIB::ZLIB)
	add_subdirectory(zlib "${CMAKE_CURRENT_BINARY_DIR}/zlib_build" EXCLUDE_FROM_ALL)
	target_include_directories(zlibstatic INTERFACE zlib "${CMAKE_CURRENT_BINARY_DIR}/zlib_build")
	add_library(ZLIB::ZLIB ALIAS zlibstatic)
endif()

find_package(Threads)

# Mini chromium library
set(
    minichromium_sources
    mini_chromium/base/debug/alias.cc
    mini_chromium/base/files/file_path.cc
    mini_chromium/base/files/scoped_file.cc
    mini_chromium/base/logging.cc
    mini_chromium/base/process/memory.cc
    mini_chromium/base/rand_util.cc
    mini_chromium/base/strings/string16.cc
    mini_chromium/base/strings/string_number_conversions.cc
    mini_chromium/base/strings/stringprintf.cc
    mini_chromium/base/strings/utf_string_conversion_utils.cc
    mini_chromium/base/strings/utf_string_conversions.cc
    mini_chromium/base/synchronization/lock.cc
    mini_chromium/base/third_party/icu/icu_utf.cc
    mini_chromium/base/threading/thread_local_storage.cc
)

if(WIN32)
  list(
      APPEND
      minichromium_sources
      mini_chromium/base/scoped_clear_last_error_win.cc
      mini_chromium/base/strings/string_util_win.cc
      mini_chromium/base/synchronization/lock_impl_win.cc
      mini_chromium/base/threading/thread_local_storage_win.cc
      mini_chromium/base/process/process_metrics_win.cc
  )
else()
  list(
      APPEND
      minichromium_sources
      mini_chromium/base/files/file_util_posix.cc
      mini_chromium/base/posix/safe_strerror.cc
      mini_chromium/base/synchronization/condition_variable_posix.cc
      mini_chromium/base/synchronization/lock_impl_posix.cc
      mini_chromium/base/threading/thread_local_storage_posix.cc
      mini_chromium/base/process/process_metrics_posix.cc
  )
endif()

if(APPLE)
  list(
      APPEND
      minichromium_sources
      mini_chromium/base/mac/close_nocancel.cc
      mini_chromium/base/mac/foundation_util.mm
      mini_chromium/base/mac/mach_logging.cc
      mini_chromium/base/mac/scoped_mach_port.cc
      mini_chromium/base/mac/scoped_mach_vm.cc
      mini_chromium/base/mac/scoped_nsautorelease_pool.mm
      mini_chromium/base/strings/sys_string_conversions_mac.mm
  )
endif()

add_library(minichromium STATIC ${minichromium_sources})

target_compile_definitions(
    minichromium
    PRIVATE
    -DNOMINMAX
    -DUNICODE
    -DWIN32
    -DWIN32_LEAN_AND_MEAN
)

target_include_directories(
    minichromium
    PUBLIC
    mini_chromium
)

if(WIN32)
add_library(
    getopt
    STATIC
    crashpad/third_party/getopt/getopt
)

target_compile_definitions(
    getopt
    PRIVATE
    -DNOMINMAX
    -DUNICODE
    -DWIN32
    -DWIN32_LEAN_AND_MEAN
)

target_include_directories(
    getopt
    PUBLIC
    crashpad/third_party/getopt
)
endif()

# Compat library.
if(WIN32)
	add_library(crashpad_compat STATIC 
		crashpad/compat/win/strings.cc
		crashpad/compat/win/time.cc
	)

	target_include_directories(
		crashpad_compat
		PUBLIC
		crashpad/compat/win
		crashpad/compat/non_mac
		crashpad/compat/non_elf
	)

	target_compile_definitions(
		crashpad_compat
		PRIVATE
		-DNOMINMAX
		-DUNICODE
		-DWIN32_LEAN_AND_MEAN
	)
endif()

# Linux currently.
if(UNIX AND NOT APPLE)
	add_library(crashpad_compat STATIC 
		crashpad/compat/linux/sys/mman.cc
	)

	target_include_directories(
		crashpad_compat
		PUBLIC
		crashpad/compat/linux
		crashpad/compat/non_mac
		crashpad/compat/non_win
	)

	target_link_libraries(
		crashpad_compat
		PUBLIC
		dl
    )
endif()

# Tools library
add_library(
    crashpad_tools
    STATIC
    crashpad/tools/tool_support.cc
)

target_include_directories(
    crashpad_tools
    PUBLIC
    crashpad
)

target_link_libraries(
    crashpad_tools
    PUBLIC
    minichromium
)

if(WIN32)
	target_compile_definitions(
		crashpad_tools
		PRIVATE
		-DNOMINMAX
		-DUNICODE
		-DWIN32_LEAN_AND_MEAN
	)

	target_link_libraries(
		crashpad_tools
		PUBLIC
		getopt
	)
endif()

# Utils library
set(
	util_sources
	crashpad/util/file/delimited_file_reader.cc
	crashpad/util/file/file_io.cc
	crashpad/util/file/file_reader.cc
	crashpad/util/file/file_seeker.cc
	crashpad/util/file/file_writer.cc
	crashpad/util/file/output_stream_file_writer.cc
	crashpad/util/file/scoped_remove_file.cc
	crashpad/util/file/string_file.cc
	crashpad/util/misc/initialization_state_dcheck.cc
	crashpad/util/misc/lexing.cc
	crashpad/util/misc/metrics.cc
	crashpad/util/misc/pdb_structures.cc
	crashpad/util/misc/random_string.cc
	crashpad/util/misc/range_set.cc
	crashpad/util/misc/reinterpret_bytes.cc
	crashpad/util/misc/scoped_forbid_return.cc
	crashpad/util/misc/time.cc
	crashpad/util/misc/uuid.cc
	crashpad/util/misc/zlib.cc
	crashpad/util/net/http_body.cc
	crashpad/util/net/http_body_gzip.cc
	crashpad/util/net/http_multipart_builder.cc
	crashpad/util/net/http_transport.cc
	crashpad/util/net/url.cc
	crashpad/util/numeric/checked_address_range.cc
	crashpad/util/process/process_memory.cc
	crashpad/util/process/process_memory_range.cc
	crashpad/util/stdlib/aligned_allocator.cc
	crashpad/util/stdlib/string_number_conversion.cc
	crashpad/util/stdlib/strlcpy.cc
	crashpad/util/stdlib/strnlen.cc
	crashpad/util/stream/base94_output_stream.cc
    crashpad/util/stream/file_encoder.cc
    crashpad/util/stream/file_output_stream.cc
    crashpad/util/stream/log_output_stream.cc
    crashpad/util/stream/zlib_output_stream.cc
	crashpad/util/string/split_string.cc
	crashpad/util/thread/thread.cc
	crashpad/util/thread/thread_log_messages.cc
	crashpad/util/thread/worker_thread.cc
)

if(UNIX)
	list(
		APPEND
		util_sources
		crashpad/util/file/directory_reader_posix.cc
		crashpad/util/file/file_io_posix.cc
		crashpad/util/file/filesystem_posix.cc
		crashpad/util/misc/clock_posix.cc
		crashpad/util/posix/close_stdio.cc
		crashpad/util/posix/scoped_dir.cc
		crashpad/util/posix/scoped_mmap.cc
		crashpad/util/posix/signals.cc
		crashpad/util/synchronization/semaphore_posix.cc
		crashpad/util/thread/thread_posix.cc
		crashpad/util/posix/close_multiple.cc
		crashpad/util/posix/double_fork_and_exec.cc
		crashpad/util/posix/drop_privileges.cc
		crashpad/util/posix/symbolic_constants_posix.cc
		)
endif()

if(APPLE)
	list(
		APPEND
		util_sources
		crashpad/util/mac/launchd.mm
		crashpad/util/mac/mac_util.cc
		crashpad/util/mac/service_management.cc
		crashpad/util/mac/xattr.cc
		crashpad/util/mach/child_port_handshake.cc
		crashpad/util/mach/child_port_server.cc
		crashpad/util/mach/composite_mach_message_server.cc
		crashpad/util/mach/exc_client_variants.cc
		crashpad/util/mach/exc_server_variants.cc
		crashpad/util/mach/exception_behaviors.cc
		crashpad/util/mach/exception_ports.cc
		crashpad/util/mach/exception_types.cc
		crashpad/util/mach/mach_extensions.cc
		crashpad/util/mach/mach_message.cc
		crashpad/util/mach/mach_message_server.cc
		crashpad/util/mach/notify_server.cc
		crashpad/util/mach/scoped_task_suspend.cc
		crashpad/util/mach/symbolic_constants_mach.cc
		crashpad/util/mach/task_for_pid.cc
		crashpad/util/mach/task_memory.cc
		crashpad/util/misc/capture_context_mac.S
		crashpad/util/misc/clock_mac.cc
		crashpad/util/misc/paths_mac.cc
		crashpad/util/net/http_transport_mac.mm
		crashpad/util/posix/process_info_mac.cc
		crashpad/util/posix/process_memory_mac.cc
		crashpad/util/synchronization/semaphore_mac.cc
	)
endif()

if(UNIX AND NOT APPLE)
	list(
		APPEND
		util_sources
		crashpad/util/net/http_transport_socket.cc
		crashpad/util/linux/auxiliary_vector.cc
		crashpad/util/linux/direct_ptrace_connection.cc
		crashpad/util/linux/exception_handler_client.cc
		crashpad/util/linux/exception_handler_protocol.cc
		crashpad/util/linux/memory_map.cc
		crashpad/util/linux/proc_stat_reader.cc
		crashpad/util/linux/proc_task_reader.cc
		crashpad/util/linux/ptrace_broker.cc
		crashpad/util/linux/ptrace_client.cc
		crashpad/util/linux/ptracer.cc
		crashpad/util/linux/scoped_pr_set_dumpable.cc
		crashpad/util/linux/scoped_pr_set_ptracer.cc
		crashpad/util/linux/scoped_ptrace_attach.cc
		crashpad/util/linux/socket.cc
		crashpad/util/linux/thread_info.cc
		crashpad/util/misc/capture_context_linux.S
		crashpad/util/misc/paths_linux.cc
		crashpad/util/misc/time_linux.cc
		crashpad/util/posix/process_info_linux.cc
		crashpad/util/process/process_memory_linux.cc
		crashpad/util/process/process_memory_sanitized.cc
	)
endif()

if(WIN32)
	list(
		APPEND
		util_sources
		crashpad/util/file/directory_reader_win.cc
		crashpad/util/file/file_io_win.cc
		crashpad/util/file/filesystem_win.cc
		crashpad/util/misc/clock_win.cc
		crashpad/util/misc/paths_win.cc
		crashpad/util/misc/time_win.cc
		crashpad/util/net/http_transport_win.cc
		crashpad/util/synchronization/semaphore_win.cc
		crashpad/util/thread/thread_win.cc
		crashpad/util/win/command_line.cc
		crashpad/util/win/critical_section_with_debug_info.cc
		crashpad/util/win/exception_handler_server.cc
		crashpad/util/win/get_function.cc
		crashpad/util/win/get_module_information.cc
		crashpad/util/win/handle.cc
		crashpad/util/win/initial_client_data.cc
		crashpad/util/win/loader_lock.cc
		crashpad/util/win/module_version.cc
		crashpad/util/win/nt_internals.cc
		crashpad/util/win/ntstatus_logging.cc
		crashpad/util/win/process_info.cc
		crashpad/util/win/registration_protocol_win.cc
		crashpad/util/win/scoped_handle.cc
		crashpad/util/win/scoped_local_alloc.cc
		crashpad/util/win/scoped_process_suspend.cc
		crashpad/util/win/scoped_set_event.cc
		crashpad/util/win/session_end_watcher.cc
		crashpad/util/misc/capture_context_win.asm
		crashpad/util/win/safe_terminate_process.asm
		crashpad/util/process/process_memory.cc
		crashpad/util/process/process_memory_range.cc
		crashpad/util/process/process_memory_win.cc
	)
endif()

add_library(crashpad_util STATIC ${util_sources})

target_link_libraries(
    crashpad_util
    PRIVATE
    minichromium
    PUBLIC
	ZLIB::ZLIB
)

target_include_directories(
    crashpad_util
    PUBLIC
    crashpad
	${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(
	crashpad_util
	PUBLIC 
	-DCRASHPAD_ZLIB_SOURCE_EXTERNAL
	-DCRASHPAD_LSS_SOURCE_EXTERNAL
	PRIVATE
	-DZLIB_CONST
)

if(WIN32)
	target_link_libraries(
		crashpad_util
		PRIVATE
		user32
		version
		winhttp
	)

	target_compile_definitions(
		crashpad_util
		PRIVATE
		-DNOMINMAX
		-DUNICODE
		-DWIN32
		-DWIN32_LEAN_AND_MEAN
	)
else()
    target_link_libraries(crashpad_util PUBLIC Threads::Threads)
endif()

if(APPLE)
	target_link_libraries(
		crashpad_util
		PRIVATE
		bsm
		"-framework CoreFoundation"
		"-framework Foundation"
		"-framework IOKit"
	)
else()
# Compat only exists for none mac?
	target_link_libraries(
		crashpad_util
		PRIVATE
		crashpad_compat
	)
endif()

set(
	client_sources
	crashpad/client/annotation.cc
	crashpad/client/annotation_list.cc
	crashpad/client/crash_report_database.cc
	crashpad/client/crashpad_info.cc
	crashpad/client/prune_crash_reports.cc
	crashpad/client/settings.cc
)

if(APPLE)
	list(
		APPEND
		client_sources
		crashpad/client/crash_report_database_mac.mm
		crashpad/client/crashpad_client_mac.cc
		crashpad/client/simulate_crash_mac.cc
	)
endif()

if (UNIX AND NOT APPLE)
	list(
		APPEND
		client_sources
		crashpad/client/crashpad_client_linux.cc
		crashpad/client/client_argv_handling.cc
		crashpad/client/crashpad_info_note.S
		crashpad/client/crash_report_database_generic.cc
	)
endif()

if(WIN32)
	list(
		APPEND
		client_sources
		crashpad/client/crash_report_database_win.cc
		crashpad/client/crashpad_client_win.cc
	)
endif()

add_library(crashpad_client STATIC ${client_sources})

target_include_directories(
	crashpad_client 
	PUBLIC 
	crashpad
	${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(
	crashpad_client 
	PRIVATE
	-DCRASHPAD_LSS_SOURCE_EXTERNAL
)

target_link_libraries(
    crashpad_client
    PUBLIC
    minichromium
    crashpad_util
)

if(WIN32)
	target_compile_definitions(
		crashpad_client
		PRIVATE
		-DNOMINMAX
		-DUNICODE
	)
endif()

# Minidump library

add_library(crashpad_minidump
	crashpad/minidump/minidump_annotation_writer.cc
	crashpad/minidump/minidump_byte_array_writer.cc
	crashpad/minidump/minidump_context_writer.cc
	crashpad/minidump/minidump_crashpad_info_writer.cc
	crashpad/minidump/minidump_exception_writer.cc
	crashpad/minidump/minidump_extensions.cc
	crashpad/minidump/minidump_file_writer.cc
	crashpad/minidump/minidump_handle_writer.cc
	crashpad/minidump/minidump_memory_info_writer.cc
	crashpad/minidump/minidump_memory_writer.cc
	crashpad/minidump/minidump_misc_info_writer.cc
	crashpad/minidump/minidump_module_crashpad_info_writer.cc
	crashpad/minidump/minidump_module_writer.cc
	crashpad/minidump/minidump_rva_list_writer.cc
	crashpad/minidump/minidump_simple_string_dictionary_writer.cc
	crashpad/minidump/minidump_stream_writer.cc
	crashpad/minidump/minidump_string_writer.cc
	crashpad/minidump/minidump_system_info_writer.cc
	crashpad/minidump/minidump_thread_id_map.cc
	crashpad/minidump/minidump_thread_writer.cc
	crashpad/minidump/minidump_unloaded_module_writer.cc
	crashpad/minidump/minidump_user_extension_stream_data_source.cc
	crashpad/minidump/minidump_user_stream_writer.cc
	crashpad/minidump/minidump_writable.cc
	crashpad/minidump/minidump_writer_util.cc
)

if(WIN32)
	target_compile_definitions(
		crashpad_minidump
		PRIVATE
		-DNOMINMAX
		-DUNICODE
		-DWIN32
		-DWIN32_LEAN_AND_MEAN
	)
endif()

target_include_directories(
    crashpad_minidump
    PUBLIC
    crashpad
)

target_link_libraries(
    crashpad_minidump
    PRIVATE
    minichromium
    crashpad_util
)

if(NOT APPLE)
	target_link_libraries(
		crashpad_minidump
		PRIVATE
		crashpad_compat
	)
endif()

# Snapshot library
set(
	snapshot_sources
	crashpad/snapshot/annotation_snapshot.cc
	crashpad/snapshot/capture_memory.cc
	crashpad/snapshot/cpu_context.cc
	crashpad/snapshot/crashpad_info_client_options.cc
	crashpad/snapshot/handle_snapshot.cc
	crashpad/snapshot/memory_snapshot.cc
	crashpad/snapshot/minidump/exception_snapshot_minidump.cc
	crashpad/snapshot/minidump/memory_snapshot_minidump.cc
	crashpad/snapshot/minidump/minidump_annotation_reader.cc
	crashpad/snapshot/minidump/minidump_context_converter.cc
	crashpad/snapshot/minidump/minidump_simple_string_dictionary_reader.cc
	crashpad/snapshot/minidump/minidump_string_list_reader.cc
	crashpad/snapshot/minidump/minidump_string_reader.cc
	crashpad/snapshot/minidump/module_snapshot_minidump.cc
	crashpad/snapshot/minidump/process_snapshot_minidump.cc
	crashpad/snapshot/minidump/exception_snapshot_minidump.cc
	crashpad/snapshot/minidump/system_snapshot_minidump.cc
	crashpad/snapshot/minidump/thread_snapshot_minidump.cc
	crashpad/snapshot/unloaded_module_snapshot.cc
	crashpad/snapshot/x86/cpuid_reader.cc
	crashpad/snapshot/crashpad_types/crashpad_info_reader.cc
	crashpad/snapshot/crashpad_types/image_annotation_reader.cc
)

if(UNIX)
	list(
		APPEND
		snapshot_sources
		crashpad/snapshot/posix/timezone.cc
	)
endif()

if(APPLE)
	list(
		APPEND
		snapshot_sources
		crashpad/snapshot/mac/cpu_context_mac.cc
		crashpad/snapshot/mac/exception_snapshot_mac.cc
		crashpad/snapshot/mac/mach_o_image_annotations_reader.cc
		crashpad/snapshot/mac/mach_o_image_reader.cc
		crashpad/snapshot/mac/mach_o_image_segment_reader.cc
		crashpad/snapshot/mac/mach_o_image_symbol_table_reader.cc
		crashpad/snapshot/mac/module_snapshot_mac.cc
		crashpad/snapshot/mac/process_reader_mac.cc
		crashpad/snapshot/mac/process_snapshot_mac.cc
		crashpad/snapshot/mac/process_types.cc
		crashpad/snapshot/mac/process_types/all.proctype
		crashpad/snapshot/mac/process_types/annotation.proctype
		crashpad/snapshot/mac/process_types/crashpad_info.proctype
		crashpad/snapshot/mac/process_types/crashreporterclient.proctype
		crashpad/snapshot/mac/process_types/custom.cc
		crashpad/snapshot/mac/process_types/dyld_images.proctype
		crashpad/snapshot/mac/process_types/loader.proctype
		crashpad/snapshot/mac/process_types/nlist.proctype
		crashpad/snapshot/mac/system_snapshot_mac.cc
		crashpad/snapshot/mac/thread_snapshot_mac.cc
	)
endif()

if(UNIX AND NOT APPLE)
	list(
		APPEND
		snapshot_sources
		crashpad/snapshot/linux/cpu_context_linux.cc
		crashpad/snapshot/linux/debug_rendezvous.cc
		crashpad/snapshot/linux/exception_snapshot_linux.cc
		crashpad/snapshot/linux/process_reader_linux.cc
		crashpad/snapshot/linux/process_snapshot_linux.cc
		crashpad/snapshot/linux/system_snapshot_linux.cc
		crashpad/snapshot/linux/thread_snapshot_linux.cc
		crashpad/snapshot/sanitized/memory_snapshot_sanitized.cc
		crashpad/snapshot/sanitized/module_snapshot_sanitized.cc
		crashpad/snapshot/sanitized/process_snapshot_sanitized.cc
		crashpad/snapshot/sanitized/sanitization_information.cc
		crashpad/snapshot/sanitized/thread_snapshot_sanitized.cc
		crashpad/snapshot/elf/elf_dynamic_array_reader.cc
		crashpad/snapshot/elf/elf_image_reader.cc
		crashpad/snapshot/elf/elf_symbol_table_reader.cc
		crashpad/snapshot/elf/module_snapshot_elf.cc
	)
endif()

if(WIN32)
	list(
		APPEND
		snapshot_sources
		crashpad/snapshot/win/capture_memory_delegate_win.cc
		crashpad/snapshot/win/cpu_context_win.cc
		crashpad/snapshot/win/exception_snapshot_win.cc
		crashpad/snapshot/win/memory_map_region_snapshot_win.cc
		crashpad/snapshot/win/module_snapshot_win.cc
		crashpad/snapshot/win/pe_image_annotations_reader.cc
		crashpad/snapshot/win/pe_image_reader.cc
		crashpad/snapshot/win/pe_image_resource_reader.cc
		crashpad/snapshot/win/process_reader_win.cc
		crashpad/snapshot/win/process_snapshot_win.cc
		crashpad/snapshot/win/process_subrange_reader.cc
		crashpad/snapshot/win/system_snapshot_win.cc
		crashpad/snapshot/win/thread_snapshot_win.cc
	)
endif()

if(NOT APPLE)
	list(
		APPEND
		snapshot_sources
		crashpad/snapshot/crashpad_types/crashpad_info_reader.cc
	)
endif()

add_library(crashpad_snapshot ${snapshot_sources})

target_include_directories(
    crashpad_snapshot
    PUBLIC
    crashpad
)

target_link_libraries(
    crashpad_snapshot
    PRIVATE
    minichromium
	crashpad_client
	crashpad_util
)

if(NOT APPLE)
	target_link_libraries(
		crashpad_snapshot
		PRIVATE
		crashpad_compat
	)
endif()

if(WIN32)
	target_compile_definitions(
		crashpad_snapshot
		PRIVATE
		-DNOMINMAX
		-DUNICODE
		-DWIN32
		-DWIN32_LEAN_AND_MEAN
	)

	target_link_libraries(
		crashpad_snapshot
		PRIVATE
		powrprof
	)
endif()

# Handler executable
set(
	handler_sources
	crashpad/handler/crash_report_upload_thread.cc
	crashpad/handler/main.cc
	crashpad/handler/handler_main.cc
	crashpad/handler/minidump_to_upload_parameters.cc
	crashpad/handler/prune_crash_reports_thread.cc
	crashpad/handler/user_stream_data_source.cc
)

if(APPLE)
	list(
		APPEND
		handler_sources
		crashpad/handler/mac/crash_report_exception_handler.cc
		crashpad/handler/mac/exception_handler_server.cc
		crashpad/handler/mac/file_limit_annotation.cc
		)
endif()

if(UNIX AND NOT APPLE)
	list(
		APPEND
		handler_sources
		crashpad/handler/linux/capture_snapshot.cc
		crashpad/handler/linux/crash_report_exception_handler.cc
		crashpad/handler/linux/cros_crash_report_exception_handler.cc
		crashpad/handler/linux/exception_handler_server.cc
		)
endif()

if(WIN32)
	list(
		APPEND
		handler_sources
		crashpad/handler/win/crash_report_exception_handler.cc
		)
endif()

add_executable(crashpad_handler ${handler_sources})

target_include_directories(
    crashpad_handler
    PRIVATE
    crashpad
)

target_link_libraries(
    crashpad_handler
    PRIVATE
    crashpad_client
    crashpad_minidump
    crashpad_snapshot
    crashpad_tools
)

target_compile_definitions(crashpad_handler PRIVATE 
	-DCRASHPAD_ZLIB_SOURCE_EXTERNAL
)

if(WIN32)
	target_compile_definitions(
		crashpad_handler
		PRIVATE
		-DNOMINMAX
		-DUNICODE
		-DWIN32
		-DWIN32_LEAN_AND_MEAN
	)

	target_link_libraries(
		crashpad_handler
		PRIVATE
		getopt
	)
endif()

if(NOT APPLE)
	target_link_libraries(
		crashpad_handler
		PRIVATE
		crashpad_compat
	)
endif()

if(WIN32)
	# Make a .com file copy from the .exe with subsystem console
	add_custom_command(
		TARGET crashpad_handler POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			$<TARGET_FILE:crashpad_handler>
			"$<TARGET_FILE_DIR:crashpad_handler>/crashpad_handler.com"
	)

	add_custom_command(
		TARGET crashpad_handler POST_BUILD
		COMMAND editbin
			-nologo
			-subsystem:console
			"$<TARGET_FILE_DIR:crashpad_handler>/crashpad_handler.com"
	)

	set_source_files_properties(
		crashpad/util/misc/capture_context_win.asm
		PROPERTIES
		COMPILE_FLAGS "/safeseh"
	)

	set_source_files_properties(
		crashpad/util/win/safe_terminate_process.asm
		PROPERTIES
		COMPILE_FLAGS "/safeseh"
	)
endif()
