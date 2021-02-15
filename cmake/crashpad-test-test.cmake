add_executable(crashpad_test_test_multiprocess_exec_test_child)

set_target_properties(crashpad_test_test_multiprocess_exec_test_child
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_sources(crashpad_test_test_multiprocess_exec_test_child PRIVATE 
    ${crashpad_git_SOURCE_DIR}/test/multiprocess_exec_test_child.cc
)

target_link_libraries(crashpad_test_test_multiprocess_exec_test_child PRIVATE 
    crashpad_common
    minichromium
    gtest
)

if(APPLE)
    target_link_libraries(crashpad_test_test_multiprocess_exec_test_child PRIVATE 
        AppleFrameworks
    )
endif()


crashpad_add_test(crashpad_test_test)
target_sources(crashpad_test_test PRIVATE
    ${crashpad_git_SOURCE_DIR}/test/hex_string_test.cc
    ${crashpad_git_SOURCE_DIR}/test/main_arguments_test.cc
    ${crashpad_git_SOURCE_DIR}/test/multiprocess_exec_test.cc
    ${crashpad_git_SOURCE_DIR}/test/scoped_guarded_page_test.cc
    ${crashpad_git_SOURCE_DIR}/test/scoped_temp_dir_test.cc
    ${crashpad_git_SOURCE_DIR}/test/test_paths_test.cc
)

if(UNIX)
    target_sources(crashpad_test_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/test/multiprocess_posix_test.cc
    )
endif()

if(APPLE)
    target_sources(crashpad_test_test PRIVATE
        ${crashpad_git_SOURCE_DIR}/test/mac/mach_multiprocess_test.cc
    )
endif()

target_link_libraries(crashpad_test_test
  PRIVATE
  gtest
  gtest_main
  gmock
  crashpad_util
  minichromium
  crashpad_test
  crashpad_handler_obj
  crashpad_client
  ZLIB::ZLIB
)