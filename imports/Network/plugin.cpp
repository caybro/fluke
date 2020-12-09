#include <QQmlEngineExtensionPlugin>

class NetworkPlugin : public QQmlEngineExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlEngineExtensionInterface_iid)
};

#include "plugin.moc"
