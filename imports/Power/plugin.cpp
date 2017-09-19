#include <QQmlExtensionPlugin>
#include <QtQml>

#include "power.h"

class PowerPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("org.fluke.Power"));

        qmlRegisterSingletonType<Power>(uri, 1, 0, "Power", [](QQmlEngine*, QJSEngine*)
                -> QObject* { return new Power; });
    }
};

#include "plugin.moc"
