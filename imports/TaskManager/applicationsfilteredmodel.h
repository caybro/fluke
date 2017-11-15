#pragma once

#include <QSortFilterProxyModel>

class ApplicationsFilteredModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)
    Q_PROPERTY(bool showRunning READ showRunning WRITE setShowRunning NOTIFY showRunningChanged)
public:
    ApplicationsFilteredModel(QObject *parent = nullptr);
    ~ApplicationsFilteredModel() = default;

    QString filterString() const;
    void setFilterString(const QString &filterString);

    bool showRunning() const;
    void setShowRunning(bool showRunning);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

Q_SIGNALS:
    void filterStringChanged(const QString &filterString);
    void showRunningChanged(bool showRunning);

private:
    QString m_filterString;
    bool m_showRunning{false};
};
