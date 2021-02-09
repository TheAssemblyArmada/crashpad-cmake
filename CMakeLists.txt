set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
cmake_minimum_required(VERSION 3.0)
project(crashpad LANGUAGES C CXX)

if(WIN32)
	enable_language(ASM_MASM)
else()
    enable_language(ASM)
endif()

# We are going to use the FetchContent module to grab crashpad and its dependencies.
include(FetchContent)

# Try to find prebuilt zlib on the system to link against first before building it ourselves.
find_package(ZLIB 1.2.8)

# If not found, we fetch it and build it ourselves.
if(NOT ZLIB_FOUND AND NOT TARGET ZLIB::ZLIB)
	FetchContent_Declare(
	  zlib
	  GIT_REPOSITORY https://github.com/madler/zlib.git
	  GIT_TAG        v1.2.11
	)
	
	# We don't use FetchContent_MakeAvailable here because we don't want all zlib targets including, just our dependency.
	FetchContent_GetProperties(zlib)
	if(NOT zlib_POPULATED)
	  FetchContent_Populate(zlib)
	  add_subdirectory(${zlib_SOURCE_DIR} ${zlib_BINARY_DIR} EXCLUDE_FROM_ALL)
	endif()

	# Make sure headers are available for the static target and make an alias to match the Find module output.
	target_include_directories(zlibstatic INTERFACE ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR})
	add_library(ZLIB::ZLIB ALIAS zlibstatic)
endif()

find_package(Threads)

# Mini chromium library
FetchContent_Declare(
	mini_chromium_git
	GIT_REPOSITORY https://github.com/chromium/mini_chromium.git
	GIT_TAG        ae14a14
)

if(NOT mini_chromium_git_POPULATED)
	FetchContent_Populate(mini_chromium_git)
endif()

set(
    minichromium_sources
    ${mini_chromium_git_SOURCE_DIR}/base/debug/alias.cc
    ${mini_chromium_git_SOURCE_DIR}/base/files/file_path.cc
    ${mini_chromium_git_SOURCE_DIR}/base/files/scoped_file.cc
    ${mini_chromium_git_SOURCE_DIR}/base/logging.cc
    ${mini_chromium_git_SOURCE_DIR}/base/process/memory.cc
    ${mini_chromium_git_SOURCE_DIR}/base/rand_util.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/string16.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/string_number_conversions.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/stringprintf.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/utf_string_conversion_utils.cc
    ${mini_chromium_git_SOURCE_DIR}/base/strings/utf_string_conversions.cc
    ${mini_chromium_git_SOURCE_DIR}/base/synchronization/lock.cc
    ${mini_chromium_git_SOURCE_DIR}/base/third_party/icu/icu_utf.cc
    ${mini_chromium_git_SOURCE_DIR}/base/threading/thread_local_storage.cc
)

if(WIN32)
  list(
      APPEND
      minichromium_sources
      ${mini_chromium_git_SOURCE_DIR}/base/scoped_clear_last_error_win.cc
      ${mini_chromium_git_SOURCE_DIR}/base/strings/string_util_win.cc
      ${mini_chromium_git_SOURCE_DIR}/base/synchronization/lock_impl_win.cc
      ${mini_chromium_git_SOURCE_DIR}/base/threading/thread_local_storage_win.cc
      ${mini_chromium_git_SOURCE_DIR}/base/process/process_metrics_win.cc
  )
else()
  list(
      APPEND
      minichromium_sources
      ${mini_chromium_git_SOURCE_DIR}/base/files/file_util_posix.cc
      ${mini_chromium_git_SOURCE_DIR}/base/posix/safe_strerror.cc
      ${mini_chromium_git_SOURCE_DIR}/base/synchronization/condition_variable_posix.cc
      ${mini_chromium_git_SOURCE_DIR}/base/synchronization/lock_impl_posix.cc
      ${mini_chromium_git_SOURCE_DIR}/base/threading/thread_local_storage_posix.cc
      ${mini_chromium_git_SOURCE_DIR}/base/process/process_metrics_posix.cc
  )
endif()

if(APPLE)
  list(
      APPEND
      minichromium_sources
      ${mini_chromium_git_SOURCE_DIR}/base/mac/close_nocancel.cc
      ${mini_chromium_git_SOURCE_DIR}/base/mac/foundation_util.mm
      ${mini_chromium_git_SOURCE_DIR}/base/mac/mach_logging.cc
      ${mini_chromium_git_SOURCE_DIR}/base/mac/scoped_mach_port.cc
      ${mini_chromium_git_SOURCE_DIR}/base/mac/scoped_mach_vm.cc
      ${mini_chromium_git_SOURCE_DIR}/base/mac/scoped_nsautorelease_pool.mm
      ${mini_chromium_git_SOURCE_DIR}/base/strings/sys_string_conversions_mac.mm
  )
endif()

add_library(minichromium STATIC ${minichromium_sources})

target_include_directories(
    minichromium
    PUBLIC
    ${mini_chromium_git_SOURCE_DIR}
)

if(WIN32)
	target_compile_definitions(
		minichromium
		PRIVATE
		-DNOMINMAX
		-DUNICODE
		-DWIN32
		-DWIN32_LEAN_AND_MEAN
	)
endif()

if(APPLE)
	target_link_libraries(
		minichromium
		PRIVATE
		"-framework ApplicationServices"
		"-framework CoreFoundation"
		"-framework Foundation"
		"-framework IOKit"
		"-framework Security"
	)
endif()

# Crashpad
FetchContent_Declare(
	crashpad_git
	GIT_REPOSITORY https://github.com/backtrace-labs/crashpad.git
	GIT_TAG        558c961
)

if(NOT crashpad_git_POPULATED)
	FetchContent_Populate(crashpad_git)
endif()

# LSS dependency for linux syscalls.
FetchContent_Declare(
	lss_git
	GIT_REPOSITORY https://chromium.googlesource.com/linux-syscall-support
	GIT_TAG        171a36a
)

if(NOT lss_git_POPULATED)
	FetchContent_Populate(lss_git)
endif()

file(COPY ${lss_git_SOURCE_DIR}/linux_syscall_support.h DESTINATION ${crashpad_git_SOURCE_DIR}/third_party/lss)

if(WIN32)
add_library(
    getopt
    STATIC
    ${crashpad_git_SOURCE_DIR}/third_party/getopt/getopt
)

target_compile_definitions(
    getopt
    PRIVATE
    -DNOMINMAX
    -DUNICODE
    -DWIN32
    -DWIN32_LEAN_AND_MEAN
	-D_CRT_SECURE_NO_WARNINGS
)

target_include_directories(
    getopt
    PUBLIC
    ${crashpad_git_SOURCE_DIR}/third_party/getopt
)
endif()

# Compat library.
if(WIN32)
	add_library(crashpad_compat STATIC 
		${crashpad_git_SOURCE_DIR}/compat/win/strings.cc
		${crashpad_git_SOURCE_DIR}/compat/win/time.cc
	)

	target_include_directories(
		crashpad_compat
		PUBLIC
		${crashpad_git_SOURCE_DIR}/compat/win
		${crashpad_git_SOURCE_DIR}/compat/non_mac
		${crashpad_git_SOURCE_DIR}/compat/non_elf
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
		${crashpad_git_SOURCE_DIR}/compat/linux/sys/mman.cc
	)

	target_include_directories(
		crashpad_compat
		PUBLIC
		${crashpad_git_SOURCE_DIR}/compat/linux
		${crashpad_git_SOURCE_DIR}/compat/non_mac
		${crashpad_git_SOURCE_DIR}/compat/non_win
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
    ${crashpad_git_SOURCE_DIR}/tools/tool_support.cc
)

target_include_directories(
    crashpad_tools
    PUBLIC
    ${crashpad_git_SOURCE_DIR}
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
	list(
		APPEND
		util_sources
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
	list(
		APPEND
		util_sources
		${crashpad_git_SOURCE_DIR}/util/mac/launchd.mm
		${crashpad_git_SOURCE_DIR}/util/mac/mac_util.cc
		${crashpad_git_SOURCE_DIR}/util/mac/service_management.cc
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
	list(
		APPEND
		util_sources
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
	list(
		APPEND
		util_sources
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
    ${crashpad_git_SOURCE_DIR}
)

target_compile_definitions(
	crashpad_util
	PUBLIC 
	-DCRASHPAD_ZLIB_SOURCE_EXTERNAL
	-DCRASHPAD_LSS_SOURCE_EXTERNAL
	PRIVATE
	-DZLIB_CONST
	-D_CRT_SECURE_NO_WARNINGS
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
	# The Apple target needs files generating with python
	find_file(EXC_DEFS exc.defs PATH_SUFFIXES /mach)
	find_file(MACH_EXC_DEFS mach_exc.defs PATH_SUFFIXES /mach)
	find_file(NOTIFY_DEFS notify.defs PATH_SUFFIXES /mach)
	message("Found exc.defs at ${EXC_DEFS}")
	message("Found mach_exc.defs at ${MACH_EXC_DEFS}")
	message("Found notify.defs at ${NOTIFY_DEFS}")
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

if(NOT MSVC)
	target_compile_options(crashpad_util PUBLIC "-Wno-multichar")
endif()

set(
	client_sources
	${crashpad_git_SOURCE_DIR}/client/annotation.cc
	${crashpad_git_SOURCE_DIR}/client/annotation_list.cc
	${crashpad_git_SOURCE_DIR}/client/crash_report_database.cc
	${crashpad_git_SOURCE_DIR}/client/crashpad_info.cc
	${crashpad_git_SOURCE_DIR}/client/prune_crash_reports.cc
	${crashpad_git_SOURCE_DIR}/client/settings.cc
)

if(APPLE)
	list(
		APPEND
		client_sources
		${crashpad_git_SOURCE_DIR}/client/crash_report_database_mac.mm
		${crashpad_git_SOURCE_DIR}/client/crashpad_client_mac.cc
		${crashpad_git_SOURCE_DIR}/client/simulate_crash_mac.cc
	)
endif()

if (UNIX AND NOT APPLE)
	list(
		APPEND
		client_sources
		${crashpad_git_SOURCE_DIR}/client/crashpad_client_linux.cc
		${crashpad_git_SOURCE_DIR}/client/client_argv_handling.cc
		${crashpad_git_SOURCE_DIR}/client/crashpad_info_note.S
		${crashpad_git_SOURCE_DIR}/client/crash_report_database_generic.cc
	)
endif()

if(WIN32)
	list(
		APPEND
		client_sources
		${crashpad_git_SOURCE_DIR}/client/crash_report_database_win.cc
		${crashpad_git_SOURCE_DIR}/client/crashpad_client_win.cc
	)
endif()

add_library(crashpad_client STATIC ${client_sources})

target_include_directories(
	crashpad_client 
	PUBLIC 
	${crashpad_git_SOURCE_DIR}
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
    ${crashpad_git_SOURCE_DIR}
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
else()
	target_include_directories(
		crashpad_minidump
		PUBLIC
		${crashpad_git_SOURCE_DIR}/compat/non_win
	)
endif()

# Snapshot library
set(
	snapshot_sources
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
	${crashpad_git_SOURCE_DIR}/snapshot/x86/cpuid_reader.cc
)

if(UNIX)
	list(
		APPEND
		snapshot_sources
		${crashpad_git_SOURCE_DIR}/snapshot/posix/timezone.cc
	)
endif()

if(APPLE)
	list(
		APPEND
		snapshot_sources
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
		#${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/all.proctype
		#${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/annotation.proctype
		#${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/crashpad_info.proctype
		#${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/crashreporterclient.proctype
		${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/custom.cc
		#${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/dyld_images.proctype
		#${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/loader.proctype
		#${crashpad_git_SOURCE_DIR}/snapshot/mac/process_types/nlist.proctype
		${crashpad_git_SOURCE_DIR}/snapshot/mac/system_snapshot_mac.cc
		${crashpad_git_SOURCE_DIR}/snapshot/mac/thread_snapshot_mac.cc
	)
endif()

if(UNIX AND NOT APPLE)
	list(
		APPEND
		snapshot_sources
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
	list(
		APPEND
		snapshot_sources
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
	list(
		APPEND
		snapshot_sources
		${crashpad_git_SOURCE_DIR}/snapshot/crashpad_types/crashpad_info_reader.cc
	)
endif()

add_library(crashpad_snapshot ${snapshot_sources})

target_include_directories(
    crashpad_snapshot
    PUBLIC
    ${crashpad_git_SOURCE_DIR}
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
else()
	target_include_directories(
		crashpad_snapshot
		PUBLIC
		${crashpad_git_SOURCE_DIR}/compat/non_win
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
	${crashpad_git_SOURCE_DIR}/handler/crash_report_upload_thread.cc
	${crashpad_git_SOURCE_DIR}/handler/main.cc
	${crashpad_git_SOURCE_DIR}/handler/handler_main.cc
	${crashpad_git_SOURCE_DIR}/handler/minidump_to_upload_parameters.cc
	${crashpad_git_SOURCE_DIR}/handler/prune_crash_reports_thread.cc
	${crashpad_git_SOURCE_DIR}/handler/user_stream_data_source.cc
)

if(APPLE)
	list(
		APPEND
		handler_sources
		${crashpad_git_SOURCE_DIR}/handler/mac/crash_report_exception_handler.cc
		${crashpad_git_SOURCE_DIR}/handler/mac/exception_handler_server.cc
		${crashpad_git_SOURCE_DIR}/handler/mac/file_limit_annotation.cc
		)
endif()

if(UNIX AND NOT APPLE)
	list(
		APPEND
		handler_sources
		${crashpad_git_SOURCE_DIR}/handler/linux/capture_snapshot.cc
		${crashpad_git_SOURCE_DIR}/handler/linux/crash_report_exception_handler.cc
		${crashpad_git_SOURCE_DIR}/handler/linux/cros_crash_report_exception_handler.cc
		${crashpad_git_SOURCE_DIR}/handler/linux/exception_handler_server.cc
		)
endif()

if(WIN32)
	list(
		APPEND
		handler_sources
		${crashpad_git_SOURCE_DIR}/handler/win/crash_report_exception_handler.cc
		)
endif()

add_executable(crashpad_handler ${handler_sources})

target_include_directories(
    crashpad_handler
    PRIVATE
    ${crashpad_git_SOURCE_DIR}
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
