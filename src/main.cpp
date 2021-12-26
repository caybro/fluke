#include <QDebug>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QIcon>
#include <QLibraryInfo>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>
#include <QUrl>

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArrayLiteral("qtvirtualkeyboard"));
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArrayLiteral("Material"));
    qputenv("QT_QUICK_CONTROLS_MATERIAL_ACCENT", QByteArrayLiteral("Blue"));

    qunsetenv("QT_SCREEN_SCALE_FACTORS");
    qunsetenv("QT_SCALE_FACTOR");
    qunsetenv("QT_AUTO_SCREEN_SCALE_FACTOR");

    // ShareOpenGLContexts is needed for using the threaded renderer
    // on Nvidia EGLStreams
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts, true);
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication app(argc, argv);
    app.setOrganizationName(QStringLiteral("caybro"));
    app.setApplicationDisplayName(QStringLiteral("Fluke"));
    app.setApplicationVersion(QStringLiteral("0.0.1"));

    qputenv("QT_QPA_PLATFORM", QByteArrayLiteral("wayland"));
    qunsetenv("QT_IM_MODULE");
    //qputenv("GDK_BACKEND", QByteArrayLiteral("wayland"));

    QIcon::setThemeName(QStringLiteral("Adwaita"));

    QTranslator qtTranslator;
    qtTranslator.load(QLocale::system(), QStringLiteral("qt_"), QString(), QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator appTrans;
    appTrans.load(QLocale(), QStringLiteral("fluke"), QStringLiteral("_"), QStringLiteral(":/translations/"));
    app.installTranslator(&appTrans);

    QFontDatabase fd;
    if (!fd.families().contains(QLatin1String("FontAwesomeSolid5"))) {
        if (QFontDatabase::addApplicationFont(QStringLiteral(":/fonts/FontAwesomeSolid5.otf")) == -1) {
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
    appEngine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
