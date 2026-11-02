file(GLOB_RECURSE FLUKE_QML_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/*.qml"
)

file(GLOB_RECURSE FLUKE_QML_RESOURCES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/fonts/*"
    "${CMAKE_CURRENT_SOURCE_DIR}/icons/*"
    "${CMAKE_CURRENT_SOURCE_DIR}/images/*"
)

foreach(file IN LISTS FLUKE_QML_FILES)
    file(RELATIVE_PATH alias "${CMAKE_CURRENT_SOURCE_DIR}/qml" "${file}")
    set_source_files_properties("${file}" PROPERTIES QT_RESOURCE_ALIAS "${alias}")
endforeach()

foreach(file IN LISTS FLUKE_QML_RESOURCES)
    file(RELATIVE_PATH alias "${CMAKE_CURRENT_SOURCE_DIR}" "${file}")
    set_source_files_properties("${file}" PROPERTIES QT_RESOURCE_ALIAS "${alias}")
endforeach()

qt_add_executable(fluke
    main.cpp
)

qt_add_qml_module(fluke
    URI org.fluke.Shell
    IMPORTS
        TARGET fluke_network
        TARGET fluke_power
        TARGET fluke_session
        TARGET fluke_sound
        TARGET fluke_taskmanager
    QML_FILES
        ${FLUKE_QML_FILES}
    RESOURCES
        ${FLUKE_QML_RESOURCES}
)

target_link_libraries(fluke
    PRIVATE
        Qt6::Gui
        Qt6::Positioning
        Qt6::PositioningQuick
        Qt6::Qml
        Qt6::QmlXmlListModel
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::QuickDialogs2
        Qt6::QuickLayouts
        Qt6::VirtualKeyboard
        Qt6::WaylandCompositor
        Qt6::WaylandCompositorXdgShell
)

qt_add_translations(
    TARGETS fluke
    SOURCE_TARGETS
        fluke
        fluke_network
        fluke_power
        fluke_session
        fluke_sound
        fluke_taskmanager
    TS_FILES
        translations/fluke_base.ts
        translations/fluke_cs.ts
    RESOURCE_PREFIX "/translations"
)
