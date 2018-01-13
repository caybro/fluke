#include "platform.h"

#include <QDBusConnection>
#include <QSet>
#include <QString>

Platform::Platform(QObject *parent)
    : QObject(parent), m_isPC(true), m_isMultiSession(true)
{
    QMetaObject::invokeMethod(this, "init");
}

void Platform::init()
{
    QDBusInterface iface(QStringLiteral("org.freedesktop.hostname1"), QStringLiteral("/org/freedesktop/hostname1"),
                         QStringLiteral("org.freedesktop.hostname1"), QDBusConnection::systemBus(), this);
    QDBusInterface seatIface(QStringLiteral("org.freedesktop.login1"), QStringLiteral("/org/freedesktop/login1/seat/self"),
                             QStringLiteral("org.freedesktop.login1.Seat"), QDBusConnection::systemBus(), this);

    // From the source at https://cgit.freedesktop.org/systemd/systemd/tree/src/hostname/hostnamed.c#n130
    // "vm\0"
    // "container\0"
    // "desktop\0"
    // "laptop\0"
    // "server\0"
    // "tablet\0"
    // "handset\0"
    // "watch\0"
    // "embedded\0",
    m_chassis = iface.property("Chassis").toString();

    // A PC is not a handset, tablet or watch.
    m_isPC = !QSet<QString>{QStringLiteral("handset"), QStringLiteral("tablet"), QStringLiteral("watch")}.contains(m_chassis);
    m_isMultiSession = seatIface.property("CanMultiSession").toBool() && seatIface.property("CanGraphical").toBool();
}

QString Platform::chassis() const
{
    return m_chassis;
}

bool Platform::isPC() const
{
    return m_isPC;
}

bool Platform::isMultiSession() const
{
    return m_isMultiSession;
}
