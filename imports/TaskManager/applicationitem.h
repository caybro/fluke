#pragma once

#include <QObject>
#include <XdgDesktopFile>

class ApplicationItem
{
    Q_GADGET
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

    explicit ApplicationItem(const QString &appId);
    explicit ApplicationItem(XdgDesktopFile * desktopFile);
    virtual ~ApplicationItem() = default;

    QString appId() const;
    QString name() const;
    XdgDesktopFile * desktopFile() const;

    Q_INVOKABLE void launch(const QStringList &urls = {});

private:
    QString m_appId;
    XdgDesktopFile *m_desktopFile{nullptr};
};
