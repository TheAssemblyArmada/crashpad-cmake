# crashpad-cmake 
Wanting a CMake wrapper around Google's Crashpad library and the supporting mini_chromium library to make it easy to integrate into CMake projects?

Based on existing works to provide a CMake solution for Crashpad we've put this together mainly for use as a submodule by [Assembly Armarda](https://github.com/TheAssemblyArmada) projects.

## Getting started

There are various ways to include this in your own project. One is to just add it to your soruce tree if you want to customise it or maintain it yourself. Another is to add this repository as a submodule of your CMake project and then add it using the `add_submodule` directive. Finally you could use the CMake FetchContent module as follows:

```CMake
include(FetchContent)
FetchContent_Declare(
  crashpad_cmake
  GIT_REPOSITORY https://github.com/TheAssemblyArmada/crashpad-cmake.git
  GIT_TAG        deadbeef  # Put the commit ref you want to build here.
)
FetchContent_MakeAvailable(crashpad_cmake)
```

Next, initialize Crashpad using something similar to this example. Refer to [the Crashpad documentation](https://crashpad.chromium.org/doxygen/index.html) if in doubt.

```c++
#include <client/crash_report_database.h>
#include <client/settings.h>
#include <client/crashpad_client.h>

bool InitializeCrashpad()
{
  // Cache directory that will store crashpad information and minidumps
  base::FilePath database("path/to/crashpad/db");
  // Path to the out-of-process handler executable
  base::FilePath handler("path/to/crashpad_handler.exe");
  // URL used to submit minidumps to
  std::string url("https://error-handler.local");
  // Optional annotations passed via --annotations to the handler
  std::map<string, string> annotations;
  // Optional arguments to pass to the handler
  std::vector<string> arguments;

  CrashpadClient client;
  bool success = client.StartHandler(
    handler,
    database,
    database,
    url,
    annotations,
    arguments,
    /* restartable */ true,
    /* asynchronous_start */ false);
  
  return success;
}
```

You will also need to link your target against crashpad_client.

```CMake
add_executable(MyProgram myprogram.cpp)
target_link_libraries(MyProgram PRIVATE crashpad_client)
```

Finally you will want to distribute the crashpad_handler with your program so it can run in the background catch your program crashing.

## Contributing
Crashpad is under continuous development so feel free to submit pull requests to update the underlying submodules.
