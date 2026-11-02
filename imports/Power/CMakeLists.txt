qt_add_qml_module(fluke_power
    URI org.fluke.Power
    SOURCES
        power.cpp
        power.h
)

target_link_libraries(fluke_power
    PRIVATE
        Qt6::DBus
)
