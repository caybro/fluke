TEMPLATE = lib
TARGET  = sessionplugin
QT += qml quick dbus
CONFIG += qt plugin c++11

uri = org.fluke.Session
load(qmlplugin)

SOURCES += \
    plugin.cpp \
    session.cpp \
    platform.cpp

HEADERS += session.h \
    platform.h

target.path = $$[QT_INSTALL_QML]/org/fluke/Session
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Session

INSTALLS += target pluginfiles
