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
    //qputenv("QT_WAYLAND_DISABLE_WINDOWDECORATION", QByteArrayLiteral("1")); // TODO own window decoration
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArrayLiteral("Material"));

    qunsetenv("QT_SCREEN_SCALE_FACTORS");

    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication app(argc, argv);
    app.setOrganizationName(QStringLiteral("caybro"));
    app.setApplicationDisplayName(QStringLiteral("Fluke"));
    app.setApplicationVersion(QStringLiteral("0.0.1"));

    qputenv("QT_QPA_PLATFORM", QByteArrayLiteral("wayland"));
    qunsetenv("QT_IM_MODULE");
    //qputenv("GDK_BACKEND", QByteArrayLiteral("wayland"));

    QIcon::setThemeName("Adwaita");

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
    appEngine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}
