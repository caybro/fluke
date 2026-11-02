cmake_minimum_required(VERSION 3.21)

project(fluke VERSION 0.0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS
    Core
    DBus
    Gui
    LinguistTools
    Positioning
    PositioningQuick
    Qml
    QmlXmlListModel
    Quick
    QuickControls2
    QuickDialogs2
    QuickLayouts
    VirtualKeyboard
    WaylandCompositor
    WaylandCompositorXdgShell
)

qt_standard_project_setup(REQUIRES 6.11)

add_compile_definitions(QT_USE_QSTRINGBUILDER)

find_package(PkgConfig REQUIRED)
pkg_check_modules(PulseAudio REQUIRED IMPORTED_TARGET libpulse libpulse-mainloop-glib)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

add_subdirectory(imports)
add_subdirectory(src)
