#pragma once

#include <QSortFilterProxyModel>

class ApplicationsFilteredModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)

public:
    ApplicationsFilteredModel(QObject *parent = nullptr);
    ~ApplicationsFilteredModel() = default;

    QString filterString() const;
    void setFilterString(const QString &filterString);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

Q_SIGNALS:
    void filterStringChanged(const QString &filterString);

private:
    QString m_filterString;
};
