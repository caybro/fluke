#pragma once

#include <QObject>
#include <QWaylandSurface>
#include <QtQmlIntegration/qqmlintegration.h>

#include <XdgDesktopFile>

class ApplicationItem: public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(bool running READ isRunning NOTIFY surfaceCountChanged)
    Q_PROPERTY(int surfaceCount READ surfaceCount NOTIFY surfaceCountChanged)
    Q_PROPERTY(bool favorite READ isFavorite WRITE setFavorite NOTIFY isFavoriteChanged)
public:
    enum RoleEnum {
        RoleAppId = Qt::UserRole + 1,
        RoleName,
        RoleComment,
        RoleIcon,
        RoleKeywords,
        RoleRunning,
        RoleInstanceCount,
        RoleFavorite,
        RolePid
    };
    Q_ENUM(RoleEnum)

    explicit ApplicationItem(const QString &appId, QObject *parent = nullptr);
    explicit ApplicationItem(XdgDesktopFile * desktopFile, QObject *parent = nullptr);
    ~ApplicationItem() = default;

    QString appId() const;
    QList<qint64> pids() const;
    QString name() const;
    XdgDesktopFile * desktopFile() const;
    int surfaceCount() const;
    int instanceCount() const;
    bool isRunning() const;
    bool isFavorite() const;
    void setFavorite(bool favorite);

    void incrementSurfaceCount(qint64 pid, QWaylandSurface *surface);
    void decrementSurfaceCount(qint64 pid, QWaylandSurface *surface);

    Q_INVOKABLE void launch(const QStringList &urls = {});
    Q_INVOKABLE void stop();

Q_SIGNALS:
    void surfaceCountChanged(int count);
    void isFavoriteChanged(bool favorite);
    void applicationQuit(const QString &appId);
    void pidsChanged();

private:
    QString m_appId;
    XdgDesktopFile *m_desktopFile{nullptr};
    QMultiMap<qint64, QWaylandSurface *> m_surfaces;
    bool m_favorite{false};
};
