TEMPLATE = lib
TARGET  = sessionplugin
QT += qml quick dbus
CONFIG += qt plugin c++11

uri = org.fluke.Session

SOURCES += \
    plugin.cpp \
    session.cpp \
    platform.cpp \
    geolocation.cpp

HEADERS += session.h \
    platform.h \
    geolocation.h

target.path = $$[QT_INSTALL_QML]/org/fluke/Session
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Session

INSTALLS += target pluginfiles
