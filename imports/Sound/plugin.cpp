#include <QQmlExtensionPlugin>
#include <QtQml>

#include "sound.h"

class SoundPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("org.fluke.Sound"));

        qmlRegisterSingletonType<Sound>(uri, 1, 0, "Sound", [](QQmlEngine*, QJSEngine*)
                -> QObject* { return new Sound; });
    }
};

#include "plugin.moc"
