TEMPLATE = lib
TARGET  = soundplugin
QT += qml
CONFIG += qt plugin c++11 link_pkgconfig
PKGCONFIG += libpulse libpulse-mainloop-glib

CONFIG += qmltypes
QML_IMPORT_NAME = org.fluke.Sound
QML_IMPORT_MAJOR_VERSION = 1

SOURCES += \
    plugin.cpp \
    sound.cpp \
    callbacks.cc \
    device.cc \
    pulseaudio.cc

HEADERS += sound.h \
    callbacks.hh \
    device.hh \
    pulseaudio.hh

target.path = $$[QT_INSTALL_QML]/org/fluke/Sound
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir $$OUT_PWD/plugins.qmltypes
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Sound

INSTALLS += target pluginfiles
