#include <QDebug>

#include <QDBusConnection>
#include <QDBusReply>

#include "session.h"

#define LOGIN1_SERVICE QStringLiteral("org.freedesktop.login1")
#define LOGIN1_PATH QStringLiteral("/org/freedesktop/login1")
#define LOGIN1_IFACE QStringLiteral("org.freedesktop.login1.Manager")
#define LOGIN1_SESSION_IFACE QStringLiteral("org.freedesktop.login1.Session")

Session::Session(QObject *parent)
    : QObject(parent)
{
}

bool Session::checkLogin1Call(const QString &method) const
{
    QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE, LOGIN1_PATH, LOGIN1_IFACE, method);
    QDBusReply<QString> reply = QDBusConnection::systemBus().call(msg);
    return reply.isValid() && (reply == QStringLiteral("yes") || reply == QStringLiteral("challenge"));
}

void Session::makeLogin1Call(const QString &method, const QVariantList &args)
{
    QDBusMessage msg = QDBusMessage::createMethodCall(LOGIN1_SERVICE,
                                                      LOGIN1_PATH,
                                                      LOGIN1_IFACE,
                                                      method);
    msg.setArguments(args);
    QDBusConnection::systemBus().asyncCall(msg);
}

bool Session::canHibernate() const
{
    return checkLogin1Call(QStringLiteral("CanHibernate"));
}

bool Session::canSuspend() const
{
    return checkLogin1Call(QStringLiteral("CanSuspend"));
}

bool Session::canHybridSleep() const
{
    return checkLogin1Call(QStringLiteral("CanHybridSleep"));
}

bool Session::canReboot() const
{
    return checkLogin1Call(QStringLiteral("CanReboot"));
}

bool Session::canShutdown() const
{
    return checkLogin1Call(QStringLiteral("CanPowerOff"));
}

bool Session::canLock() const
{
    // FIXME real locking
    return true;
}

void Session::reboot()
{
    makeLogin1Call(QStringLiteral("Reboot"), {false});
}

void Session::shutdown()
{
    makeLogin1Call(QStringLiteral("PowerOff"), {false});
}

void Session::suspend()
{
    makeLogin1Call(QStringLiteral("Suspend"), {false});
}

void Session::hibernate()
{
    makeLogin1Call(QStringLiteral("Hibernate"), {false});
}

void Session::hybridSleep()
{
    makeLogin1Call(QStringLiteral("HybridSleep"), {false});
}

