TEMPLATE = lib
TARGET  = powerplugin
QT += qml dbus
CONFIG += qt plugin c++11

CONFIG += qmltypes
QML_IMPORT_NAME = org.fluke.Power
QML_IMPORT_MAJOR_VERSION = 1

SOURCES += \
    plugin.cpp \
    power.cpp

HEADERS += power.h

target.path = $$[QT_INSTALL_QML]/org/fluke/Power
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir $$OUT_PWD/plugins.qmltypes
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Power

INSTALLS += target pluginfiles
