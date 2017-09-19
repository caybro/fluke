#include <QDBusConnection>
#include <QDBusReply>
#include <QSet>
#include <QString>
#include <QDebug>

#include "power.h"

#define UPOWER_SERVICE QStringLiteral("org.freedesktop.UPower")
#define UPOWER_PATH QStringLiteral("/org/freedesktop/UPower")
#define UPOWER_IFACE QStringLiteral("org.freedesktop.UPower")
#define UPOWER_DEVICE_IFACE QStringLiteral("org.freedesktop.UPower.Device")
#define UPOWER_DISPLAYDEVICE_PATH QStringLiteral("/org/freedesktop/UPower/devices/DisplayDevice")

#define PROP_ON_BATTERY "OnBattery"
#define PROP_HAS_LID "LidIsPresent"
#define PROP_LID_CLOSED "LidIsClosed"

#define PROP_IS_PRESENT "IsPresent"
#define PROP_PERCENTAGE "Percentage"
#define PROP_STATE "State"
#define PROP_TIME_TO_EMPTY "TimeToEmpty"
#define PROP_TIME_TO_FULL "TimeToFull"
#define PROP_ICON_NAME "IconName"

#define DBUS_PROPS_IFACE QStringLiteral("org.freedesktop.DBus.Properties")

Power::Power(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<State>("State");

    // setup notifier signals
    auto conn = QDBusConnection::systemBus();
    conn.connect(UPOWER_SERVICE, UPOWER_PATH, DBUS_PROPS_IFACE,
                 QStringLiteral("PropertiesChanged"),
                 this, SLOT(onUPowerPropertiesChanged(QString, QVariantMap, QStringList)));

    // fill properties
    m_onBattery = checkUPowerProperty(PROP_ON_BATTERY);
    m_hasLid = checkUPowerProperty(PROP_HAS_LID);
    m_isLidClosed = checkUPowerProperty(PROP_LID_CLOSED);

    conn.connect(UPOWER_SERVICE, UPOWER_DISPLAYDEVICE_PATH, DBUS_PROPS_IFACE,
                 QStringLiteral("PropertiesChanged"),
                 this, SLOT(onDevicePropertiesChanged(QString, QVariantMap, QStringList)));

    QDBusInterface deviceIface(UPOWER_SERVICE, UPOWER_DISPLAYDEVICE_PATH, UPOWER_DEVICE_IFACE, QDBusConnection::systemBus());
    m_isPresent = deviceIface.property(PROP_IS_PRESENT).toBool();
    m_percentage = deviceIface.property(PROP_PERCENTAGE).toDouble();
    setState(deviceIface.property(PROP_STATE).toUInt());
    setRemainingTime(deviceIface.property(PROP_TIME_TO_EMPTY).toLongLong(), deviceIface.property(PROP_TIME_TO_FULL).toLongLong());
    m_iconName = deviceIface.property(PROP_ICON_NAME).toString();
}

bool Power::onBattery() const
{
    return m_onBattery;
}

bool Power::hasLid() const
{
    return m_hasLid;
}

bool Power::isLidClosed() const
{
    return m_isLidClosed;
}

double Power::percentage() const
{
    return m_percentage;
}

Power::State Power::state() const
{
    return m_state;
}

QString Power::remainingTime() const
{
    return m_remainingTime;
}

QString Power::iconName() const
{
    return m_iconName;
}

bool Power::isPresent() const
{
    return m_isPresent;
}

void Power::onUPowerPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated)
{
    Q_UNUSED(invalidated)
    if (interface != UPOWER_IFACE) {
        return;
    }

    if (changedProperties.contains(PROP_ON_BATTERY)) {
        m_onBattery = changedProperties.value(PROP_ON_BATTERY).toBool();
        Q_EMIT onBatteryChanged(m_onBattery);
    }
    if (changedProperties.contains(PROP_LID_CLOSED)) {
        m_isLidClosed = changedProperties.value(PROP_LID_CLOSED).toBool();
        Q_EMIT isLidClosedChanged(m_isLidClosed);
    }
}

void Power::onDevicePropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated)
{
    Q_UNUSED(invalidated)
    if (interface != UPOWER_DEVICE_IFACE) {
        return;
    }

    if (changedProperties.contains(PROP_IS_PRESENT)) {
        m_isPresent = changedProperties.value(PROP_IS_PRESENT).toBool();
        Q_EMIT isPresentChanged(m_isPresent);
    }
    if (changedProperties.contains(PROP_PERCENTAGE)) {
        m_percentage = changedProperties.value(PROP_PERCENTAGE).toDouble();
        Q_EMIT percentageChanged(m_percentage);
    }
    if (changedProperties.contains(PROP_STATE)) {
        setState(changedProperties.value(PROP_STATE).toUInt());
    }
    if (changedProperties.contains(PROP_TIME_TO_EMPTY) || changedProperties.contains(PROP_TIME_TO_FULL)) {
        setRemainingTime(changedProperties.value(PROP_TIME_TO_EMPTY, 0).toLongLong(),
                         changedProperties.value(PROP_TIME_TO_FULL, 0).toLongLong());
    }
    if (changedProperties.contains(PROP_ICON_NAME)) {
        m_iconName = changedProperties.value(PROP_ICON_NAME).toString();
        Q_EMIT iconNameChanged(m_iconName);
    }
}

bool Power::checkUPowerProperty(const QString &name)
{
    QDBusMessage msg = QDBusMessage::createMethodCall(UPOWER_SERVICE, UPOWER_PATH, DBUS_PROPS_IFACE, QStringLiteral("Get"));
    msg << UPOWER_IFACE;
    msg << name;
    QDBusReply<QVariant> reply = QDBusConnection::systemBus().asyncCall(msg);
    if (reply.isValid()) {
        return reply.value().toBool();
    } else {
        qWarning() << name << reply.error().name() << reply.error().message();
    }
    return false;
}

void Power::setState(uint state)
{
    if (state == 1 || state == 5) {
        m_state = Charging;
    } else if (state == 2 || state == 6) {
        m_state = Discharging;
    } else if (state == 3) {
        m_state = Empty;
    } else if (state == 4) {
        m_state = FullyCharged;
    } else if (state == 0) {
        m_state = Unknown;
    } else {
        m_state = Stable;
    }
    Q_EMIT stateChanged(m_state);
}

void Power::setRemainingTime(qint64 timeToEmpty, qint64 timeToFull)
{
    qint64 seconds;
    int minutes, hours;

    if (m_state == Discharging) {
        seconds = timeToEmpty;
    } else if (m_state == Charging) {
        seconds = timeToFull;
    } else return;

    minutes = seconds / 60;
    hours = minutes / 60;
    minutes %= 60;

    m_remainingTime = QStringLiteral("%1:%2").arg(hours).arg(minutes, 2, 10, QLatin1Char('0'));
    Q_EMIT remainingTimeChanged(m_remainingTime);
}
