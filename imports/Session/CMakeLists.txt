qt_add_qml_module(fluke_session
    URI org.fluke.Session
    SOURCES
        platform.cpp
        platform.h
        session.cpp
        session.h
)

target_link_libraries(fluke_session
    PRIVATE
        Qt6::DBus
)
