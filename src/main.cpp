#include <QUrl>
#include <QDebug>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QTranslator>
#include <QLibraryInfo>
#include <QIcon>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArrayLiteral("qtvirtualkeyboard"));
    qputenv("QT_XCB_GL_INTEGRATION", QByteArrayLiteral("xcb_egl"));
    //qputenv("QT_WAYLAND_DISABLE_WINDOWDECORATION", QByteArrayLiteral("1")); // TODO own window decoration
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArrayLiteral("Material"));

    //QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication app(argc, argv);
    app.setOrganizationName(QStringLiteral("caybro"));
    app.setApplicationDisplayName(QStringLiteral("Fluke"));
    app.setApplicationVersion(QStringLiteral("0.0.1"));

    qputenv("QT_WAYLAND_SHELL_INTEGRATION", QByteArrayLiteral("xdg-shell-v5")); // TODO still at v5 so that Qt 5.9 clients can connect
    qputenv("QT_QPA_PLATFORM", QByteArrayLiteral("wayland"));
    //qputenv("GDK_BACKEND", QByteArrayLiteral("wayland"));

    //QIcon::setThemeName("breeze");

    QTranslator qtTranslator;
    qtTranslator.load(QLocale::system(), QStringLiteral("qt_"), QString(), QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator appTrans;
    appTrans.load(QStringLiteral(":/translations/fluke_") + QLocale::system().name());
    app.installTranslator(&appTrans);

    QFontDatabase fd;
    if (!fd.families().contains(QLatin1String("FontAwesome"))) {
        if (QFontDatabase::addApplicationFont(QStringLiteral(":/fonts/FontAwesome.otf")) == -1) {
            qWarning("Failed to load FontAwesome from resources");
        }
    }

    QQmlApplicationEngine appEngine;
    QQmlContext *context = appEngine.rootContext();
#ifdef QT_QML_DEBUG
    context->setContextProperty(QStringLiteral("debugMode"), true);
#else
    context->setContextProperty(QStringLiteral("debugMode"), false);
#endif
    appEngine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}
