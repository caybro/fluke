#include <QStringList>

#include "applicationsfilteredmodel.h"
#include "applicationitem.h"

ApplicationsFilteredModel::ApplicationsFilteredModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
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
    emit filterStringChanged(m_filterString);
}

bool ApplicationsFilteredModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (sourceParent.isValid() || m_filterString.isEmpty()) {
        return true;
    }

    const QModelIndex &sourceIndex = sourceModel()->index(sourceRow, 0);

    const QString &appId = sourceIndex.data(ApplicationItem::RoleAppId).toString();
    const QString &appName = sourceIndex.data(ApplicationItem::RoleName).toString();
    const QString &comment = sourceIndex.data(ApplicationItem::RoleComment).toString();
    const QStringList &keywords = sourceIndex.data(ApplicationItem::RoleKeywords).toStringList();

    return appId.contains(m_filterString, filterCaseSensitivity()) ||
            appName.contains(m_filterString, filterCaseSensitivity()) ||
            comment.contains(m_filterString, filterCaseSensitivity()) ||
            !keywords.filter(m_filterString, filterCaseSensitivity()).isEmpty();
}
