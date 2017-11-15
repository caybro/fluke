#pragma once

#include <QAbstractListModel>

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
    void runApplication(const QString &appId, const QStringList &urls = {});
    void setSurfaceAppeared(const QString &appId);
    void setSurfaceVanished(const QString &appId);

private:
    void init();
    ApplicationItem * findAppItem(const QString &appId) const;
    QHash<int, QByteArray> m_roleNames;
    QVector<ApplicationItem *> m_items;
};
