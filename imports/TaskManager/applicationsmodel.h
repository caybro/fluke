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

    Q_INVOKABLE int count() const;
    Q_INVOKABLE ApplicationItem * get(int i) const;
    Q_INVOKABLE void runApplication(int i);

private:
    void init();
    QHash<int, QByteArray> m_roleNames;
    QVector<ApplicationItem *> m_items;
};
