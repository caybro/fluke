#pragma once

#include <QObject>
#include <QmlTypeAndRevisionsRegistration>

class Session: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Session(QObject * parent = nullptr);
    ~Session() = default;

    /**
     * @return whether the system is capable of hibernating
     */
    Q_INVOKABLE bool canHibernate() const;

    /**
     * @return whether the system is capable of suspending
     */
    Q_INVOKABLE bool canSuspend() const;

    /**
     * @return whether the system is capable of hybrid sleep
     */
    Q_INVOKABLE bool canHybridSleep() const;

    /**
     * @return whether the system is capable of rebooting
     */
    Q_INVOKABLE bool canReboot() const;

    /**
     * @return whether the system is capable of shutting down
     */
    Q_INVOKABLE bool canShutdown() const;

    /**
     * @return whether the system is capable of locking the session
     */
    Q_INVOKABLE bool canLock() const;

    /**
     * Reboot the system.
     *
     * This method directly reboots the system without user's confirmation.
     * Ordinary applications should avoid calling this method. Please call
     * RequestReboot() to ask the user to decide reboot or not.
     */
    Q_INVOKABLE void reboot();

    /**
     * Shutdown the system.
     *
     * This method directly shuts down the system without user's confirmation.
     * Ordinary applications should avoid calling this method. Please call
     * RequestShutdown() to ask the user to decide shutdown or not.
     */
    Q_INVOKABLE void shutdown();

    /**
     * Suspend the system
     *
     * This method puts the system into sleep without user's confirmation.
     */
    Q_INVOKABLE void suspend();

    /**
     * Hibernate the system
     *
     * This method puts the system into hibernation without user's confirmation.
     */
    Q_INVOKABLE void hibernate();

    /**
     * Hybrid sleep
     *
     * This method puts the system into hybrid sleep without user's confirmation.
     */
    Q_INVOKABLE void hybridSleep();

private:
    bool checkLogin1Call(const QString &method) const;
    void makeLogin1Call(const QString &method, const QVariantList &args);
};
