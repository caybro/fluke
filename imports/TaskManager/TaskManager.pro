TEMPLATE = lib
TARGET  = taskmanagerplugin
QT += qml quick
CONFIG += qt plugin c++11

uri = org.fluke.TaskManager
load(qmlplugin)

SOURCES += \
    plugin.cpp \
    runner.cpp

HEADERS += runner.h

target.path = $$[QT_INSTALL_QML]/org/fluke/TaskManager
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/TaskManager

INSTALLS += target pluginfiles
