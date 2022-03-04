set(ASM_DIALECT "_UASM")
set(CMAKE_ASM${ASM_DIALECT}_COMPILER_LIST uasm)
include(CMakeDetermineASMCompiler)
set(ASM_DIALECT)
