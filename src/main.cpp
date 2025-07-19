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
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArrayLiteral("Material"));
    qputenv("QT_QUICK_CONTROLS_MATERIAL_ACCENT", QByteArrayLiteral("Blue"));

    qunsetenv("QT_SCREEN_SCALE_FACTORS");
    qunsetenv("QT_SCALE_FACTOR");
    qunsetenv("QT_AUTO_SCREEN_SCALE_FACTOR");

    // ShareOpenGLContexts is needed for using the threaded renderer
    // on Nvidia EGLStreams
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts, true);
    QGuiApplication app(argc, argv);
    app.setOrganizationName(QStringLiteral("caybro"));
    app.setApplicationDisplayName(QStringLiteral("Fluke"));
    app.setApplicationVersion(QStringLiteral("0.0.2"));

    qputenv("QT_IM_MODULES", QByteArrayLiteral("qtvirtualkeyboard"));

    qputenv("XDG_CURRENT_DESKTOP", QByteArrayLiteral("fluke"));
    qputenv("QT_IM_MODULES", "qtvirtualkeyboard");

    qputenv("QT_QPA_PLATFORM", QByteArrayLiteral("wayland"));
    qunsetenv("QT_IM_MODULE");
    qputenv("GDK_BACKEND", QByteArrayLiteral("wayland"));

    QIcon::setThemeName(QStringLiteral("Adwaita"));

    QTranslator qtTranslator;
    if (qtTranslator.load(QLocale::system(), QStringLiteral("qt_"), QString(), QLibraryInfo::path(QLibraryInfo::TranslationsPath)))
      app.installTranslator(&qtTranslator);

    QTranslator appTrans;
    if (appTrans.load(QLocale(), QStringLiteral("fluke"), QStringLiteral("_"), QStringLiteral(":/translations/")))
      app.installTranslator(&appTrans);

    if (!QFontDatabase::families().contains(QLatin1String("FontAwesomeSolid5"))) {
        if (QFontDatabase::addApplicationFont(QStringLiteral(":/fonts/FontAwesomeSolid5.otf")) == -1) {
            qWarning("Failed to load FontAwesome from resources");
        }
    }

    QQmlApplicationEngine appEngine;
    auto context = appEngine.rootContext();
#ifdef QT_QML_DEBUG
    context->setContextProperty(QStringLiteral("debugMode"), true);
#else
    context->setContextProperty(QStringLiteral("debugMode"), false);
#endif

    const auto url = QUrl(QStringLiteral("qrc:/qml/main.qml"));

    QObject::connect(&appEngine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                       if (!obj && url == objUrl)
                         QCoreApplication::exit(EXIT_FAILURE);
                     }, Qt::QueuedConnection);

    appEngine.load(url);

    return app.exec();
}
