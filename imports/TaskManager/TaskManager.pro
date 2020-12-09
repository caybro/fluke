TEMPLATE = lib
TARGET  = taskmanagerplugin
QT += qml waylandcompositor
CONFIG += qt plugin c++14 link_pkgconfig
PKGCONFIG += Qt5Xdg

CONFIG += qmltypes
QML_IMPORT_NAME = org.fluke.TaskManager
QML_IMPORT_MAJOR_VERSION = 1

SOURCES += \
    plugin.cpp \
    runner.cpp \
    applicationsmodel.cpp \
    applicationitem.cpp \
    applicationsfilteredmodel.cpp \
    imagetexturescache.cpp \
    managedtexturenode.cpp \
    qiconitem.cpp

HEADERS += runner.h \
    applicationsmodel.h \
    applicationitem.h \
    applicationsfilteredmodel.h \
    imagetexturescache.h \
    managedtexturenode.h \
    qiconitem.h

target.path = $$[QT_INSTALL_QML]/org/fluke/TaskManager
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir $$OUT_PWD/plugins.qmltypes
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/TaskManager

INSTALLS += target pluginfiles
