# Tools library
add_library(crashpad_tools STATIC)

set_target_properties(crashpad_tools
    PROPERTIES
    CXX_STANDARD 14
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET "hidden"
    C_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN ON
)

target_link_libraries(crashpad_tools PRIVATE
    minichromium
    crashpad_common
)

target_sources(crashpad_tools PRIVATE
    ${crashpad_git_SOURCE_DIR}/tools/tool_support.cc
)
