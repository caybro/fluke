#pragma once

#include <QObject>

class Session: public QObject
{
    Q_OBJECT
public:
    explicit Session(QObject * parent = nullptr);
    ~Session() = default;

    /**
     * @return whether the system is capable of hibernating
     */
    Q_SCRIPTABLE bool canHibernate() const;

    /**
     * @return whether the system is capable of suspending
     */
    Q_SCRIPTABLE bool canSuspend() const;

    /**
     * @return whether the system is capable of hybrid sleep
     */
    Q_SCRIPTABLE bool canHybridSleep() const;

    /**
     * @return whether the system is capable of rebooting
     */
    Q_SCRIPTABLE bool canReboot() const;

    /**
     * @return whether the system is capable of shutting down
     */
    Q_SCRIPTABLE bool canShutdown() const;

    /**
     * @return whether the system is capable of locking the session
     */
    Q_SCRIPTABLE bool canLock() const;

    /**
     * Reboot the system.
     *
     * This method directly reboots the system without user's confirmation.
     * Ordinary applications should avoid calling this method. Please call
     * RequestReboot() to ask the user to decide reboot or not.
     */
    Q_SCRIPTABLE void reboot();

    /**
     * Shutdown the system.
     *
     * This method directly shuts down the system without user's confirmation.
     * Ordinary applications should avoid calling this method. Please call
     * RequestShutdown() to ask the user to decide shutdown or not.
     */
    Q_SCRIPTABLE void shutdown();

    /**
     * Suspend the system
     *
     * This method puts the system into sleep without user's confirmation.
     */
    Q_SCRIPTABLE void suspend();

    /**
     * Hibernate the system
     *
     * This method puts the system into hibernation without user's confirmation.
     */
    Q_SCRIPTABLE void hibernate();

    /**
     * Hybrid sleep
     *
     * This method puts the system into hybrid sleep without user's confirmation.
     */
    Q_SCRIPTABLE void hybridSleep();

private:
    bool checkLogin1Call(const QString &method) const;
    void makeLogin1Call(const QString &method, const QVariantList &args);
};
