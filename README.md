# zlib.install

[![AppVeyor](https://img.shields.io/appveyor/ci/Horta/zlib-install.svg?style=flat-square)](https://ci.appveyor.com/project/Horta/zlib-install)

Windows one-liner installer for zlib library.

# usage

```
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/horta/zlib.install/master/install.bat', 'install.bat')" && install.bat
```
