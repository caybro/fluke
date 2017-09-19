#include <QQmlExtensionPlugin>
#include <QtQml>

#include "session.h"
#include "platform.h"

class SessionPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("org.fluke.Session"));

        qmlRegisterSingletonType<Session>(uri, 1, 0, "Session", [](QQmlEngine*, QJSEngine*)
                -> QObject* { return new Session; });
        qmlRegisterSingletonType<Platform>(uri, 1, 0, "Platform", [](QQmlEngine*, QJSEngine*)
                -> QObject* { return new Platform; });
    }
};

#include "plugin.moc"
