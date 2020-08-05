#pragma once

#include <QDBusInterface>

class Network: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool wifiHWEnabled READ isWifiHWEnabled NOTIFY wifiHWEnabledChanged)
    Q_PROPERTY(bool wifiEnabled READ isWifiEnabled NOTIFY wifiEnabledChanged)
    Q_PROPERTY(bool online READ isOnline NOTIFY onlineChanged)
    Q_PROPERTY(QString ssid READ ssid NOTIFY primaryConnectionChanged)
    Q_PROPERTY(uint strength READ strength NOTIFY primaryConnectionChanged)

public:
    explicit Network(QObject *parent = nullptr);
    ~Network() = default;

    bool isWifiHWEnabled() const;
    bool isWifiEnabled() const;
    bool isOnline() const;
    QString ssid() const;
    uint strength() const;

signals:
    void wifiHWEnabledChanged();
    void wifiEnabledChanged();
    void onlineChanged();
    void primaryConnectionChanged();

private slots:
    void init();
    void onGlobalPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);
    void onApPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);

private:
    void setWifiHWEnabled(bool enabled);
    void setWifiEnabled(bool enabled);
    void setIsOnline(bool online);

    void processPrimaryConnection();

    bool m_wifiHWEnabled{false};
    bool m_wifiEnabled{false};
    QString m_primaryConnectionType;
    QString m_primaryConnectionPath;
    bool m_online{false};
    QString m_ssid;
    int m_strength{0};
};
