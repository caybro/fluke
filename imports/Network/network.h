#pragma once

#include <QDBusInterface>

class Network: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool wifiHWEnabled READ isWifiHWEnabled NOTIFY wifiHWEnabledChanged)
    Q_PROPERTY(bool wifiEnabled READ isWifiEnabled WRITE setWifiEnabled NOTIFY wifiEnabledChanged)
    Q_PROPERTY(bool online READ isOnline NOTIFY onlineChanged)
    Q_PROPERTY(QString ssid READ ssid NOTIFY primaryConnectionChanged)
    Q_PROPERTY(uint strength READ strength NOTIFY primaryConnectionChanged)
    Q_PROPERTY(QStringList accessPoints READ accessPoints NOTIFY accessPointsChanged)
    Q_PROPERTY(QString activeAp READ activeAp NOTIFY primaryConnectionChanged)

public:
    explicit Network(QObject *parent = nullptr);
    ~Network() = default;

    bool isWifiHWEnabled() const;
    bool isWifiEnabled() const;
    void setWifiEnabled(bool enabled);
    bool isOnline() const;
    QString ssid() const;
    uint strength() const;
    QStringList accessPoints() const;
    QString activeAp() const;

    Q_INVOKABLE QVariantMap apData(const QString &ap) const;

signals:
    void wifiHWEnabledChanged();
    void wifiEnabledChanged();
    void onlineChanged();
    void primaryConnectionChanged();
    void accessPointsChanged();

private slots:
    void init();
    void onGlobalPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);
    void onDevicePropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);
    void onApPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);
    void addAccessPoint(const QDBusObjectPath &ap);
    void removeAccessPoint(const QDBusObjectPath &ap);

private:
    void setWifiHWEnabled(bool enabled);
    void updateWifiEnabled(bool enabled);
    void setIsOnline(bool online);

    void processPrimaryConnection();
    void processDevice(const QString &devicePath);

    bool m_wifiHWEnabled{false};
    bool m_wifiEnabled{false};
    QString m_primaryConnectionType;
    QString m_primaryConnectionPath;
    bool m_online{false};
    QString m_ssid;
    int m_strength{0};
    QStringList m_accessPoints;
    QString m_activeAp;
};
