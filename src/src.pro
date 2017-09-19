TEMPLATE = app
TARGET = fluke

QT += gui qml waylandcompositor

SOURCES += main.cpp

OTHER_FILES = \
    qml/* \
    images/background.jpg \

RESOURCES += fluke.qrc

target.path = $$[QT_HOST_BINS]
sources.files = $$SOURCES $$HEADERS $$RESOURCES $$FORMS fluke.pro
sources.path = $$[QT_INSTALL_EXAMPLES]/wayland/fluke

INSTALLS += target
