TEMPLATE = lib
TARGET  = networkplugin
QT += qml dbus
CONFIG += qt plugin c++11

uri = org.fluke.Network

SOURCES += \
    plugin.cpp \
    network.cpp

HEADERS += network.h

target.path = $$[QT_INSTALL_QML]/org/fluke/Network
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Network

INSTALLS += target pluginfiles
