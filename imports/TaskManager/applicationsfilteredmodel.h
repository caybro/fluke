#pragma once

#include <QSortFilterProxyModel>
#include <QtQmlIntegration/qqmlintegration.h>

class ApplicationsFilteredModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)
    Q_PROPERTY(bool showRunning READ showRunning WRITE setShowRunning NOTIFY showRunningChanged)
    Q_PROPERTY(bool showFavorite READ showFavorite WRITE setShowFavorite NOTIFY showFavoriteChanged)
    Q_PROPERTY(bool showFavoriteAndRunning READ showFavoriteAndRunning WRITE setShowFavoriteAndRunning NOTIFY showFavoriteAndRunningChanged)
public:
    ApplicationsFilteredModel(QObject *parent = nullptr);
    ~ApplicationsFilteredModel() override = default;

    QString filterString() const;
    void setFilterString(const QString &filterString);

    bool showRunning() const;
    void setShowRunning(bool showRunning);

    bool showFavorite() const;
    void setShowFavorite(bool showFavorite);

    bool showFavoriteAndRunning() const;
    void setShowFavoriteAndRunning(bool showFavoriteAndRunning);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

Q_SIGNALS:
    void filterStringChanged(const QString &filterString);
    void showRunningChanged(bool showRunning);
    void showFavoriteChanged(bool showFavorite);
    void showFavoriteAndRunningChanged(bool showFavoriteAndRunning);

private:
    QString m_filterString;
    bool m_showRunning{false};
    bool m_showFavorite{false};
    bool m_showFavoriteAndRunning{false};
};
