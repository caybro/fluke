#include <QDBusConnection>
#include <QString>
#include <QDebug>

#include "network.h"

#define NM_SERVICE QStringLiteral("org.freedesktop.NetworkManager")
#define NM_PATH QStringLiteral("/org/freedesktop/NetworkManager")
#define NM_IFACE QStringLiteral("org.freedesktop.NetworkManager")
#define NM_IFACE_CONNECTION_ACTIVE QStringLiteral("org.freedesktop.NetworkManager.Connection.Active")
#define NM_IFACE_AP QStringLiteral("org.freedesktop.NetworkManager.AccessPoint")
#define NM_IFACE_DEVICE_WIFI QStringLiteral("org.freedesktop.NetworkManager.Device.Wireless")

#define DBUS_PROPS_IFACE QStringLiteral("org.freedesktop.DBus.Properties")

#define PROP_WIFI_HW_ENABLED "WirelessHardwareEnabled"
#define PROP_WIFI_ENABLED "WirelessEnabled"
#define PROP_STATE "State"
#define PROP_PRIMARY_CONNECTION "PrimaryConnection"
#define PROP_PRIMARY_CONNECTION_TYPE "PrimaryConnectionType"
#define PROP_STRENGTH "Strength"
#define PROP_ACTIVE_AP "ActiveAccessPoint"

Network::Network(QObject *parent)
    : QObject(parent)
{
    QMetaObject::invokeMethod(this, "init");
}

void Network::init()
{
    QDBusInterface nmIface(NM_SERVICE, NM_PATH, NM_IFACE, QDBusConnection::systemBus());
    setWifiHWEnabled(nmIface.property(PROP_WIFI_HW_ENABLED).toBool());
    setWifiEnabled(nmIface.property(PROP_WIFI_ENABLED).toBool());
    setIsOnline(nmIface.property(PROP_STATE).toUInt() == 70);

    m_primaryConnectionType = nmIface.property(PROP_PRIMARY_CONNECTION_TYPE).toString();
    m_primaryConnectionPath = nmIface.property(PROP_PRIMARY_CONNECTION).value<QDBusObjectPath>().path();

    qDebug() << "!!! Primary connection + type:" << m_primaryConnectionPath << m_primaryConnectionType;

    QDBusConnection::systemBus().connect(NM_SERVICE, NM_PATH, DBUS_PROPS_IFACE,
                                         QStringLiteral("PropertiesChanged"),
                                         this, SLOT(onGlobalPropertiesChanged(QString, QVariantMap, QStringList)));

    processPrimaryConnection();
}

void Network::onGlobalPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated)
{
    Q_UNUSED(invalidated)
    if (interface != NM_IFACE) {
        return;
    }

    if (changedProperties.contains(PROP_WIFI_HW_ENABLED)) {
        setWifiHWEnabled(changedProperties.value(PROP_WIFI_HW_ENABLED).toBool());
    }
    if (changedProperties.contains(PROP_WIFI_ENABLED)) {
        setWifiEnabled(changedProperties.value(PROP_WIFI_ENABLED).toBool());
    }
    if (changedProperties.contains(PROP_STATE)) {
        setIsOnline(changedProperties.value(PROP_STATE).toUInt() == 70);
    }
    if (changedProperties.contains(PROP_PRIMARY_CONNECTION_TYPE)) {
        m_primaryConnectionType = changedProperties.value(PROP_PRIMARY_CONNECTION_TYPE).toString();
    }
    if (changedProperties.contains(PROP_PRIMARY_CONNECTION)) {
        m_primaryConnectionPath = changedProperties.value(PROP_PRIMARY_CONNECTION).value<QDBusObjectPath>().path();
        qDebug() << "!!! Primary connection changed:" << m_primaryConnectionPath;
        processPrimaryConnection();
    }
}

void Network::processPrimaryConnection()
{
    QDBusInterface primaryConn(NM_SERVICE, m_primaryConnectionPath, NM_IFACE_CONNECTION_ACTIVE, QDBusConnection::systemBus());
    const QString type = primaryConn.property("Type").toString();

    if (type != "802-11-wireless") {
        m_ssid = "ethernet";
        emit primaryConnectionChanged();
        return;
    }

    m_ssid = primaryConn.property("Id").toString();

    const QList<QDBusObjectPath> devices = primaryConn.property("Devices").value<QList<QDBusObjectPath>>();
    if (devices.isEmpty()) {
        qWarning() << "List of primary connection devices is empty, bailing out";
        return;
    }

    processDevice(devices.constFirst().path());

    emit primaryConnectionChanged();
}

void Network::processDevice(const QString &devicePath)
{
    QDBusInterface deviceIface(NM_SERVICE, devicePath, NM_IFACE_DEVICE_WIFI, QDBusConnection::systemBus());
    const QString activeApPath = deviceIface.property(PROP_ACTIVE_AP).value<QDBusObjectPath>().path();
    qDebug() << "!!! ACTIVE AP:" << activeApPath;

    for (const auto & ap: deviceIface.property("AccessPoints").value<QList<QDBusObjectPath>>()) {
        m_accessPoints.append(ap.path());
    }
    emit accessPointsChanged();
    QDBusConnection::systemBus().connect(NM_SERVICE, devicePath, NM_IFACE_DEVICE_WIFI,
                                         QStringLiteral("AccessPointAdded"),
                                         this, SLOT(addAccessPoint(QDBusObjectPath)));
    QDBusConnection::systemBus().connect(NM_SERVICE, devicePath, NM_IFACE_DEVICE_WIFI,
                                         QStringLiteral("AccessPointRemoved"),
                                         this, SLOT(removeAccessPoint(QDBusObjectPath)));

    onDevicePropertiesChanged(NM_IFACE_DEVICE_WIFI, {{PROP_ACTIVE_AP, QDBusObjectPath(activeApPath)}}, {});
}

void Network::onDevicePropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated)
{
    Q_UNUSED(invalidated)
    if (interface != NM_IFACE_DEVICE_WIFI) {
        return;
    }

    if (changedProperties.contains(PROP_ACTIVE_AP)) {
        const QString activeApPath = changedProperties.value(PROP_ACTIVE_AP).value<QDBusObjectPath>().path();
        QDBusInterface apIface(NM_SERVICE, activeApPath, NM_IFACE_AP, QDBusConnection::systemBus());
        m_strength = apIface.property(PROP_STRENGTH).toInt();

        QDBusConnection::systemBus().connect(NM_SERVICE, activeApPath, DBUS_PROPS_IFACE,
                                             QStringLiteral("PropertiesChanged"),
                                             this, SLOT(onApPropertiesChanged(QString, QVariantMap, QStringList)));

        emit primaryConnectionChanged();
    }
}

void Network::onApPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated)
{
    Q_UNUSED(invalidated)
    if (interface != NM_IFACE_AP) {
        return;
    }

    if (changedProperties.contains(PROP_STRENGTH)) {
        m_strength = changedProperties.value(PROP_STRENGTH).toInt();
        emit primaryConnectionChanged();
    }
}

bool Network::isWifiHWEnabled() const
{
    return m_wifiHWEnabled;
}

void Network::setWifiHWEnabled(bool enabled)
{
    if (enabled == m_wifiHWEnabled)
        return;

    m_wifiHWEnabled = enabled;
    emit wifiHWEnabledChanged();
}

bool Network::isWifiEnabled() const
{
    return m_wifiEnabled;
}

void Network::setWifiEnabled(bool enabled)
{
    if (enabled == m_wifiEnabled)
        return;

    m_wifiEnabled = enabled;
    emit wifiEnabledChanged();
}

bool Network::isOnline() const
{
    return m_online;
}

QString Network::ssid() const
{
    return m_ssid;
}

uint Network::strength() const
{
    return m_strength;
}

void Network::setIsOnline(bool online)
{
    if (m_online == online)
        return;

    m_online = online;
    emit onlineChanged();
}

QStringList Network::accessPoints() const
{
    return m_accessPoints;
}

void Network::addAccessPoint(const QDBusObjectPath &ap)
{
    m_accessPoints.append(ap.path());
    emit accessPointsChanged();
}

void Network::removeAccessPoint(const QDBusObjectPath &ap)
{
    m_accessPoints.removeAll(ap.path());
    emit accessPointsChanged();
}
