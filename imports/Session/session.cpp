#include <QDebug>

#include <QDBusConnection>
#include <QDBusReply>

#include "session.h"

constexpr auto LOGIN1_SERVICE = "org.freedesktop.login1";
constexpr auto LOGIN1_PATH = "/org/freedesktop/login1";
constexpr auto LOGIN1_IFACE = "org.freedesktop.login1.Manager";
constexpr auto LOGIN1_SESSION_AUTO_PATH = "/org/freedesktop/login1/session/auto";

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

void Session::logout()
{
    makeLogin1Call(QStringLiteral("TerminateSession"), {LOGIN1_SESSION_AUTO_PATH});
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

