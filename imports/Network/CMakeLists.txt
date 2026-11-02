qt_add_qml_module(fluke_network
    URI org.fluke.Network
    SOURCES
        network.cpp
        network.h
)

target_link_libraries(fluke_network
    PRIVATE
        Qt6::DBus
)
