#include <QQmlExtensionPlugin>
#include <QtQml>

#include "runner.h"

class TaskManagerPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("org.fluke.TaskManager"));

        qmlRegisterSingletonType<Runner>(uri, 1, 0, "Runner", [](QQmlEngine*, QJSEngine*)
                -> QObject* { return new Runner; });
    }
};

#include "plugin.moc"
