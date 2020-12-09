TEMPLATE = lib
TARGET  = networkplugin
QT += qml dbus
CONFIG += qt plugin c++11

CONFIG += qmltypes
QML_IMPORT_NAME = org.fluke.Network
QML_IMPORT_MAJOR_VERSION = 1

SOURCES += \
    plugin.cpp \
    network.cpp

HEADERS += network.h

target.path = $$[QT_INSTALL_QML]/org/fluke/Network
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir $$OUT_PWD/plugins.qmltypes
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Network

INSTALLS += target pluginfiles
