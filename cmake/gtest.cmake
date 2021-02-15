add_library(gtest OBJECT)
set_target_properties(gtest
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)
target_link_libraries(gtest PRIVATE crashpad_common)
target_include_directories(gtest PUBLIC ${googletest_SOURCE_DIR}/googletest/include PRIVATE ${googletest_SOURCE_DIR}/googletest)
target_compile_definitions(gtest PUBLIC GUNIT_NO_GOOGLE3=1)

target_sources(gtest
    PRIVATE
    ${googletest_SOURCE_DIR}/googletest/src/gtest-death-test.cc
    ${googletest_SOURCE_DIR}/googletest/src/gtest-filepath.cc
    ${googletest_SOURCE_DIR}/googletest/src/gtest-internal-inl.h
    ${googletest_SOURCE_DIR}/googletest/src/gtest-matchers.cc
    ${googletest_SOURCE_DIR}/googletest/src/gtest-port.cc
    ${googletest_SOURCE_DIR}/googletest/src/gtest-printers.cc
    ${googletest_SOURCE_DIR}/googletest/src/gtest-test-part.cc
    ${googletest_SOURCE_DIR}/googletest/src/gtest-typed-test.cc
    ${googletest_SOURCE_DIR}/googletest/src/gtest.cc
)

add_library(gmock OBJECT)
set_target_properties(gmock
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)
target_include_directories(gmock PUBLIC ${googletest_SOURCE_DIR}/googlemock/include)
target_link_libraries(gmock PRIVATE crashpad_common gtest)

if(NOT MSVC)
    target_compile_options(gmock PUBLIC -Wno-inconsistent-missing-override)
endif()

target_sources(gmock
    PRIVATE
    ${googletest_SOURCE_DIR}/googlemock/src/gmock-cardinalities.cc
    ${googletest_SOURCE_DIR}/googlemock/src/gmock-internal-utils.cc
    ${googletest_SOURCE_DIR}/googlemock/src/gmock-matchers.cc
    ${googletest_SOURCE_DIR}/googlemock/src/gmock-spec-builders.cc
    ${googletest_SOURCE_DIR}/googlemock/src/gmock.cc
)