TEMPLATE = subdirs
SUBDIRS += imports src
src.depends = imports # build plugins/libs first
DEFINES *= QT_USE_QSTRINGBUILDER
