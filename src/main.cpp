#include <QUrl>
#include <QDebug>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QTranslator>
#include <QLibraryInfo>

int main(int argc, char *argv[])
{
    //qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
    qputenv("QT_XCB_GL_INTEGRATION", "xcb_egl");
    //qputenv("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1"); // TODO own window decoration
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");

    //QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    app.setOrganizationName("caybro");
    app.setApplicationDisplayName("Fluke");
    app.setApplicationVersion("0.0.1");

    qputenv("QT_WAYLAND_SHELL_INTEGRATION", "xdg-shell-v5");
    qputenv("QT_QPA_PLATFORM", "wayland");
    //qputenv("GDK_BACKEND", "wayland");

    QTranslator qtTranslator;
    qtTranslator.load(QLocale::system(), QStringLiteral("qt_"), QString(), QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    app.installTranslator(&qtTranslator);

    QTranslator appTrans;
    appTrans.load(QStringLiteral(":/translations/fluke_") + QLocale::system().name());
    app.installTranslator(&appTrans);

    QFontDatabase fd;
    if (!fd.families().contains(QLatin1String("FontAwesome"))) {
        if (QFontDatabase::addApplicationFont(":/fonts/FontAwesome.otf") == -1) {
            qWarning("Failed to load FontAwesome from resources");
        }
    }

    QQmlApplicationEngine appEngine(QUrl("qrc:///qml/main.qml"));

    return app.exec();
}
