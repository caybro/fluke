TEMPLATE = lib
TARGET  = taskmanagerplugin
QT += qml quick waylandcompositor
CONFIG += qt plugin c++11 link_pkgconfig
PKGCONFIG += Qt5Xdg

uri = org.fluke.TaskManager

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
pluginfiles.files += $$_PRO_FILE_PWD_/qmldir
pluginfiles.path = $$[QT_INSTALL_QML]/org/fluke/TaskManager

INSTALLS += target pluginfiles
