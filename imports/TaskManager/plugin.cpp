#include <QQmlExtensionPlugin>
#include <QtQml>

#include "runner.h"
#include "applicationsmodel.h"
#include "applicationsfilteredmodel.h"
#include "applicationitem.h"
#include "qiconitem.h"

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
        qmlRegisterSingletonType<ApplicationsModel>(uri, 1, 0, "Applications", [](QQmlEngine*, QJSEngine*)
                -> QObject* { return new ApplicationsModel; });
        qmlRegisterType<ApplicationsFilteredModel>(uri, 1, 0, "ApplicationsFilteredModel");
        qmlRegisterType<QIconItem>(uri, 1, 0, "IconItem");
        qmlRegisterUncreatableType<ApplicationItem>(uri, 1, 0, "ApplicationItem", "Cannot create ApplicationItem in QML");
    }
};

#include "plugin.moc"
