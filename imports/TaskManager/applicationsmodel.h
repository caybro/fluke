#pragma once

#include <QAbstractListModel>
#include <QWaylandSurface>

#include "applicationitem.h"

class ApplicationsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    ApplicationsModel(QObject *parent = nullptr);
    ~ApplicationsModel();

protected:
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

public Q_SLOTS:
    void startApplication(const QString &appId, const QStringList &urls = {});
    void stopApplication(const QString &appId);
    void setSurfaceAppeared(const QString &appId, QWaylandSurface *surface);
    void setSurfaceVanished(const QString &appId, QWaylandSurface *surface);

private:
    void init();
    ApplicationItem * findAppItem(const QString &appId) const;
    QHash<int, QByteArray> m_roleNames;
    QVector<ApplicationItem *> m_items;
};
