#pragma once

#include <QDBusInterface>
#include <QtQmlIntegration/qqmlintegration.h>

/**
 * @brief The Platform class
 *
 * Wrapper around platform detection support (org.freedesktop.hostname1)
 */
class Platform: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    /**
     * The chassis property
     *
     * Supported values include: "laptop", "computer", "handset" or "tablet"
     * For full list see: http://www.freedesktop.org/wiki/Software/systemd/hostnamed/
     */
    Q_PROPERTY(QString chassis READ chassis CONSTANT)
    /**
     * Whether the machine is an ordinary PC (desktop, laptop or server)
     */
    Q_PROPERTY(bool isPC READ isPC CONSTANT)
    /**
     * Whether the system is capable of running multiple (graphical) sessions
     */
    Q_PROPERTY(bool isMultiSession READ isMultiSession CONSTANT)

public:
    Platform(QObject *parent = nullptr);
    ~Platform() = default;

    QString chassis() const;
    bool isPC() const;

    bool isMultiSession() const;

private Q_SLOTS:
    void init();

private:
    QString m_chassis;
    bool m_isPC;
    bool m_isMultiSession;
};
