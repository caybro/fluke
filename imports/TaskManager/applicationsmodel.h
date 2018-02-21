#pragma once

#include <QAbstractListModel>
#include <QWaylandSurface>
#include <QSettings>

#include "applicationitem.h"

class ApplicationsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    ApplicationsModel(QObject *parent = nullptr);
    ~ApplicationsModel() override;

protected:
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

public Q_SLOTS:
    void startApplication(const QString &appId, const QStringList &urls = {});
    void stopApplication(const QString &appId);
    QString setSurfaceAppeared(qint64 pid, QWaylandSurface *surface);
    void setSurfaceVanished(qint64 pid, QWaylandSurface *surface);
    void setApplicationFavorite(const QString &appId, bool favorite);

Q_SIGNALS:
    void applicationQuit(const QString &appId);

private:
    void init();
    ApplicationItem * findAppItem(const QString &appId) const;
    ApplicationItem * findAppItem(qint64 pid) const;
    void loadSettings();
    void saveSettings();
    QHash<int, QByteArray> m_roleNames;
    QVector<ApplicationItem *> m_items;
    QSettings m_settings;
    QStringList m_favoriteAppIds;
};
