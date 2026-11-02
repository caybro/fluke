# Copilot instructions

## Build, test, and lint

- Requirements: Qt 6.11 or newer (including Qt Wayland, Qt Quick, Positioning, and Virtual Keyboard), libpulse, libpulse-mainloop-glib, CMake 3.21+, Ninja, and Git/network access for CMake FetchContent. See `README.md`.
- Configure and build with CMake from a separate directory:
  ```sh
  cmake -S . -B build -G Ninja
  cmake --build build --parallel
  ```
- The top-level `CMakeLists.txt` adds `imports` before `src`; plugin targets are defined in each module's `CMakeLists.txt`.
- There are no automated test targets or test files in the repository, so no full-suite or single-test command is available.
- The QML module provides a `fluke_qmllint` target. Run it from the build directory:
  ```sh
  cmake --build build --target fluke_qmllint
  ```

## Architecture

Fluke is a Qt Quick-based Linux desktop shell and Wayland compositor. `src/main.cpp` sets up the Qt application, translations, fonts, and compositor environment, then loads the `Main` type from the `org.fluke.Shell` QML module. The root QML component creates a Wayland compositor and one `Output.qml` per screen. Each output connects compositor surfaces to the shell UI: `Workspace.qml` tracks workspace-level actions and fullscreen state, `Chrome.qml` wraps client surfaces and their window behavior, while `Panel.qml`, `Dock.qml`, the launcher, and `Indicators/` provide desktop controls.

The native QML extensions under `imports/` provide the system-facing APIs used by the UI. `TaskManager` handles application discovery, launch and surface tracking; `Session`, `Power`, and `Network` expose session, power, and connectivity state/actions; `Sound` integrates PulseAudio. The root `CMakeLists.txt` builds these plugin libraries before the app. Each module has its own `CMakeLists.txt` and `qt_add_qml_module` declaration for its QML import URI and plugin metadata. TaskManager uses CMake `FetchContent` to build pinned `lxqt-build-tools` and `libqtxdg` sources against the selected Qt SDK.

## Repository conventions

- Keep native QML APIs declared with the Qt QML registration macros in their C++ headers. Use `QML_SINGLETON` for shared services and `QML_NAMED_ELEMENT` when the QML type name differs from the C++ class name; keep each module's URI, plugin metadata, and generated `qmldir` consistent with its `qt_add_qml_module` declaration.
- Keep QML presentation in `src/qml/` and its system integration in the relevant native plugin under `imports/`. Indicator components belong in `src/qml/Indicators/` and are composed by `Panel.qml`.
- App QML and QML-only assets are embedded by the app's `qt_add_qml_module` in `src/CMakeLists.txt`; add files to its `QML_FILES` or `RESOURCES` inputs and use resource URLs (`qrc:/...`) where appropriate. QML module resources live under `/qt/qml/org/fluke/Shell/`.
- User-facing QML strings use `qsTr`; translations are maintained in `src/translations/*.ts` and generated/embedded with `qt_add_translations` in `src/CMakeLists.txt`.
- The project uses CMake and C++17. Keep module source/header lists and external library dependencies in the corresponding module `CMakeLists.txt`; prefer explicit Qt target linkage and `PRIVATE` visibility for implementation dependencies.
