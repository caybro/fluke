TEMPLATE = lib
TARGET  = powerplugin
QT += qml quick dbus
CONFIG += qt plugin c++11

uri = org.fluke.Power
load(qmlplugin)

SOURCES += \
    plugin.cpp \
    power.cpp

HEADERS += power.h

target.path = $$[QT_INSTALL_QML]/org/fluke/Power
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Power

INSTALLS += target pluginfiles
