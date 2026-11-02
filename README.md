# Fluke
Simple Linux desktop GUI written in Qt

## Dependencies
- Qt 6.11+ (Qt Wayland, Qt Quick)
- libpulse, libpulse-mainloop-glib
- Git and network access to fetch the LXQt build tools and libqtxdg sources during CMake configuration

## Building

Configure and build with CMake and Ninja:

```sh
cmake -S . -B build -G Ninja
cmake --build build
```
