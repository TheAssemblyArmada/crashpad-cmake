add_executable(crashpad_handler_test_extended_handler)

set_target_properties(crashpad_handler_test_extended_handler PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_sources(crashpad_handler_test_extended_handler PRIVATE
    ${crashpad_git_SOURCE_DIR}/handler/crashpad_handler_test_extended_handler.cc
)

target_link_libraries(crashpad_handler_test_extended_handler PRIVATE
    gtest
    crashpad_common
    crashpad_compat
    crashpad_test
    crashpad_minidump
    minidump_test_support
    crashpad_snapshot
    snapshot_test_support
    crashpad_util
    crashpad_handler_obj
    minichromium
    AppleFrameworks
    crashpad_tools
    crashpad_client
    ZLIB::ZLIB
)

crashpad_add_test(crashpad_handler_test)

target_sources(crashpad_handler_test PRIVATE
    ${crashpad_git_SOURCE_DIR}/handler/minidump_to_upload_parameters_test.cc
)

target_link_libraries(crashpad_handler_test PRIVATE
    gtest
    gtest_main
    crashpad_test
    crashpad_client
    crashpad_snapshot
    snapshot_test_support
    crashpad_util
    crashpad_handler_obj
    minichromium
    ZLIB::ZLIB
)

add_dependencies(crashpad_handler_test crashpad_handler_test_extended_handler)