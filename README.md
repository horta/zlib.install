# zlib.install

Windows one-line installer for zlib library.

# Usage

Open your command prompt as Administrator and enter

```
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/horta/zlib.install/master/install.bat', 'install_zlib.bat')"; install_zlib.bat; del install_zlib.bat
```

# Requirements

- Install Visual Studio with C++. Make sure to select Desktop Development with C++ when doing so.
- Make sure you have cmake: https://cmake.org/download/

The video https://www.youtube.com/watch?v=IsAoIqnNia4 presents a step-by-step tutorial
on how to install Visual Studio with support to C++.
