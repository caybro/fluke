#pragma once

#include <QObject>
#include <QWaylandSurface>

#include <XdgDesktopFile>

class ApplicationItem: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ isRunning NOTIFY surfaceCountChanged)
    Q_PROPERTY(int surfaceCount READ surfaceCount NOTIFY surfaceCountChanged)
public:
    enum RoleEnum {
        RoleAppId = Qt::UserRole + 1,
        RoleName,
        RoleComment,
        RoleIcon,
        RoleKeywords,
        RoleRunning,
        RoleFavorite
    };
    Q_ENUM(RoleEnum)

    explicit ApplicationItem(const QString &appId, QObject *parent = nullptr);
    explicit ApplicationItem(XdgDesktopFile * desktopFile, QObject *parent = nullptr);
    virtual ~ApplicationItem() = default;

    QString appId() const;
    QString name() const;
    XdgDesktopFile * desktopFile() const;
    int surfaceCount() const;
    bool isRunning() const;
    void incrementSurfaceCount(QWaylandSurface *surface);
    void decrementSurfaceCount(QWaylandSurface *surface);

    Q_INVOKABLE void launch(const QStringList &urls = {});
    Q_INVOKABLE void stop();

Q_SIGNALS:
    void surfaceCountChanged(int count);

private:
    QString m_appId;
    XdgDesktopFile *m_desktopFile{nullptr};
    QVector<QWaylandSurface *> m_surfaces;
};
