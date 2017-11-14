#pragma once

#include <QAbstractListModel>

#include "applicationitem.h"

class ApplicationsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    ApplicationsModel(QObject *parent = nullptr);
    ~ApplicationsModel();

    Q_INVOKABLE void runApplication(const QString &appId);

protected:
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    void init();
    QHash<int, QByteArray> m_roleNames;
    QVector<ApplicationItem *> m_items;
};
