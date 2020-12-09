TEMPLATE = lib
TARGET  = sessionplugin
QT += qml dbus
CONFIG += qt plugin c++11

CONFIG += qmltypes
QML_IMPORT_NAME = org.fluke.Session
QML_IMPORT_MAJOR_VERSION = 1

SOURCES += \
    plugin.cpp \
    session.cpp \
    platform.cpp \
    #geolocation.cpp

HEADERS += session.h \
    platform.h \
    #geolocation.h

target.path = $$[QT_INSTALL_QML]/org/fluke/Session
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir $$OUT_PWD/plugins.qmltypes
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Session

INSTALLS += target pluginfiles
