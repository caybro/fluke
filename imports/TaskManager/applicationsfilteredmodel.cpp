#include <QStringList>

#include "applicationsfilteredmodel.h"
#include "applicationitem.h"

ApplicationsFilteredModel::ApplicationsFilteredModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);

    connect(sourceModel(), &QAbstractItemModel::dataChanged, this, &ApplicationsFilteredModel::invalidate);
    connect(sourceModel(), &QAbstractItemModel::modelReset, this, &ApplicationsFilteredModel::invalidate);

    sort(0);
}

QString ApplicationsFilteredModel::filterString() const
{
    return m_filterString;
}

void ApplicationsFilteredModel::setFilterString(const QString &filterString)
{
    if (m_filterString == filterString)
        return;

    m_filterString = filterString;
    invalidateFilter();
    Q_EMIT filterStringChanged(m_filterString);
}

bool ApplicationsFilteredModel::showRunning() const
{
    return m_showRunning;
}

void ApplicationsFilteredModel::setShowRunning(bool showRunning)
{
    if (m_showRunning == showRunning)
        return;

    m_showRunning = showRunning;
    invalidateFilter();
    Q_EMIT showRunningChanged(m_showRunning);
}

bool ApplicationsFilteredModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (sourceParent.isValid()) {
        return true;
    }

    const QModelIndex &sourceIndex = sourceModel()->index(sourceRow, 0);

    bool running = sourceIndex.data(ApplicationItem::RoleRunning).toBool();
    const bool showOnlyRunning = m_showRunning ? m_showRunning && running : true;

    if (m_filterString.isEmpty()) {
        return showOnlyRunning;
    }

    const QString &appId = sourceIndex.data(ApplicationItem::RoleAppId).toString();
    const QString &appName = sourceIndex.data(ApplicationItem::RoleName).toString();
    const QString &comment = sourceIndex.data(ApplicationItem::RoleComment).toString();
    const QStringList &keywords = sourceIndex.data(ApplicationItem::RoleKeywords).toStringList();

    // filter by search string
    return showOnlyRunning && (appId.contains(m_filterString, filterCaseSensitivity()) ||
                               appName.contains(m_filterString, filterCaseSensitivity()) ||
                               comment.contains(m_filterString, filterCaseSensitivity()) ||
                               !keywords.filter(m_filterString, filterCaseSensitivity()).isEmpty());
}
