TEMPLATE = lib
TARGET  = soundplugin
QT += qml quick
CONFIG += qt plugin c++11 link_pkgconfig
PKGCONFIG += libpulse libpulse-mainloop-glib

uri = org.fluke.Sound
load(qmlplugin)

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
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/Sound

INSTALLS += target pluginfiles
