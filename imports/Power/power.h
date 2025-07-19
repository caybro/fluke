#pragma once

#include <QDBusInterface>
#include <QtQmlIntegration/qqmlintegration.h>

class Power: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool isPresent READ isPresent NOTIFY isPresentChanged)
    Q_PROPERTY(bool onBattery READ onBattery NOTIFY onBatteryChanged)
    Q_PROPERTY(bool hasLid READ hasLid CONSTANT)
    Q_PROPERTY(bool isLidClosed READ isLidClosed NOTIFY isLidClosedChanged)

    Q_PROPERTY(double percentage READ percentage NOTIFY percentageChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString remainingTime READ remainingTime NOTIFY remainingTimeChanged)
    Q_PROPERTY(QString iconName READ iconName NOTIFY iconNameChanged)

    Q_PROPERTY(int screenBacklight READ screenBacklight WRITE setScreenBacklight NOTIFY screenBacklightChanged)

public:
    enum State {
        Unknown = 0,
        Stable,
        Empty,
        Discharging,
        Charging,
        FullyCharged
    };
    Q_ENUM(State)

    Power(QObject *parent = nullptr);
    ~Power() = default;

    bool isPresent() const;
    bool onBattery() const;
    bool hasLid() const;
    bool isLidClosed() const;

    double percentage() const;
    State state() const;
    QString remainingTime() const;
    QString iconName() const;

    int screenBacklight() const;
    void setScreenBacklight(int backlight);

Q_SIGNALS:
    void isPresentChanged(bool isPresent);
    void onBatteryChanged(bool onBattery);
    void isLidClosedChanged(bool isLidClosed);
    void percentageChanged(double percentage);
    void stateChanged(Power::State state);
    void remainingTimeChanged(const QString &remainingTime);
    void iconNameChanged(const QString &iconName);

    void screenBacklightChanged();

private Q_SLOTS:
    void onUPowerPropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);
    void onDevicePropertiesChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);
    void onBacklightPropertyChanged(const QString &interface, const QVariantMap &changedProperties, const QStringList &invalidated);

private:
    bool checkUPowerProperty(const QString &name);
    void setState(uint state);
    void setRemainingTime(qint64 timeToEmpty, qint64 timeToFull);

    bool m_isPresent{true};
    bool m_onBattery{false};
    bool m_hasLid{false};
    bool m_isLidClosed{false};
    double m_percentage{100.0};
    State m_state{Unknown};
    QString m_remainingTime;
    QString m_iconName;

    QDBusInterface m_gsdPowerIface;
};
