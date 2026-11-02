include(FetchContent)

FetchContent_Declare(
    lxqt2-build-tools
    GIT_REPOSITORY https://github.com/lxqt/lxqt-build-tools.git
    GIT_TAG a4b8db0a9ea05bcef0a7dacb18968ba6c5e4c46f
    GIT_SHALLOW TRUE
)

FetchContent_MakeAvailable(lxqt2-build-tools)
set(lxqt2-build-tools_DIR "${CMAKE_BINARY_DIR}")

FetchContent_Declare(
    libqtxdg
    GIT_REPOSITORY https://github.com/lxqt/libqtxdg.git
    GIT_TAG f1991ee59bdc6a58044a7a79d8aa7f12accfb091
    GIT_SHALLOW TRUE
)

FetchContent_MakeAvailable(libqtxdg)

qt_add_qml_module(fluke_taskmanager
    URI org.fluke.TaskManager
    SOURCES
        applicationitem.cpp
        applicationitem.h
        applicationsfilteredmodel.cpp
        applicationsfilteredmodel.h
        applicationsmodel.cpp
        applicationsmodel.h
        imagetexturescache.cpp
        imagetexturescache.h
        managedtexturenode.cpp
        managedtexturenode.h
        modelutils.cpp
        modelutils.h
        qiconitem.cpp
        qiconitem.h
        runner.cpp
        runner.h
)

target_link_libraries(fluke_taskmanager
    PRIVATE
        Qt6::Quick
        Qt6::WaylandCompositor
        Qt6Xdg
)

if(LINUX)
    # Keep the fetched QtXdg ahead of incompatible system copies in LD_LIBRARY_PATH.
    target_link_options(fluke_taskmanager
        PRIVATE
            "LINKER:--disable-new-dtags"
    )
endif()
