TEMPLATE = app
TARGET = fluke

QT += gui qml waylandcompositor
QT -= widgets
CONFIG += qtquickcompiler

SOURCES += main.cpp

OTHER_FILES = \
    qml/* \
    qml/Indicators/*.qml \
    images/background.jpg

RESOURCES += fluke.qrc

lupdate_only {
    SOURCES += ../imports/*/*.cpp
}

TRANSLATIONS = translations/fluke_base.ts \
               translations/fluke_cs.ts

target.path = $$[QT_HOST_BINS]
sources.files = $$SOURCES $$HEADERS $$RESOURCES $$FORMS fluke.pro
sources.path = $$[QT_INSTALL_EXAMPLES]/wayland/fluke

INSTALLS += target

