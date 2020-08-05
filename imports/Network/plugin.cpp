#include <QQmlExtensionPlugin>
#include <QtQml>

#include "network.h"

class NetworkPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("org.fluke.Network"));

        qmlRegisterSingletonType<Network>(uri, 1, 0, "Network", [](QQmlEngine*, QJSEngine*)
                -> QObject* { return new Network; });
    }
};

#include "plugin.moc"
