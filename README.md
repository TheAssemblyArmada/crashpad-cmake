# crashpad-cmake 
Wanting a CMake wrapper around Google's Crashpad library and the supporting mini_chromium library to make it easy to integrate into CMake projects?

Based on existing works to provide a CMake solution for Crashpad we've put this together mainly for use as a submodule by [Assembly Armarda](https://github.com/TheAssemblyArmada) projects.

## Getting started

Add this repository as a submodule of your CMake project and then add it using the `add_submodule` directive.

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

## Contributing
Crashpad is under continuous development so feel free to submit pull requests to update the underlying submodules.

Currently building on macOS is untested but in theory is possible. Please feed back if any changes are required to make it build on that platform.
