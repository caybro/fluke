#include <QDebug>

#include "applicationsmodel.h"

ApplicationsModel::ApplicationsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames = {
        {ApplicationItem::RoleAppId, QByteArrayLiteral("appId")},
        {ApplicationItem::RoleName, "name"},
        {ApplicationItem::RoleComment, "comment"},
        {ApplicationItem::RoleIcon, "icon"},
        {ApplicationItem::RoleKeywords, "keywords"},
        {ApplicationItem::RoleRunning, "running"},
        {ApplicationItem::RoleFavorite, "favorite"}
    };
    init();
}

ApplicationsModel::~ApplicationsModel()
{
    qDeleteAll(m_items);
    m_items.clear();
}

int ApplicationsModel::rowCount(const QModelIndex &) const
{
    return m_items.count();
}

QVariant ApplicationsModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        const int row = index.row();
        if (row >= 0 && row < m_items.count()) {
            const auto item = m_items.at(row);
            if (item) {
                switch (role) {
                case ApplicationItem::RoleAppId: return item->appId();
                case ApplicationItem::RoleName:
                case Qt::DisplayRole:
                    return item->desktopFile()->name();
                case ApplicationItem::RoleComment:
                case Qt::ToolTipRole: {
                    const QString comment = item->desktopFile()->comment();
                    if (!comment.isEmpty()) {
                        return comment;
                    }
                    return item->desktopFile()->localizedValue(QStringLiteral("GenericName")).toString();
                }
                case ApplicationItem::RoleIcon: return item->desktopFile()->iconName();
                case ApplicationItem::RoleKeywords: return item->desktopFile()->localizedValue(QStringLiteral("Keywords")).toStringList();
                case ApplicationItem::RoleRunning: return false; // TODO
                case ApplicationItem::RoleFavorite: return false; // TODO
                }
            }
        }
    }
    return QVariant();
}

QHash<int, QByteArray> ApplicationsModel::roleNames() const
{
    return m_roleNames;
}

void ApplicationsModel::runApplication(const QString &appId)
{
    auto it = std::find_if(m_items.constBegin(), m_items.constEnd(), [appId](ApplicationItem *appItem) {
        return appItem->appId() == appId;
    });
    if (it != m_items.constEnd()) {
        (*it)->launch();
    }
}

void ApplicationsModel::init()
{
    beginResetModel();
    for(XdgDesktopFile * desktopFile: XdgDesktopFileCache::getAllFiles()) {
        if (desktopFile->type() == XdgDesktopFile::ApplicationType
                && desktopFile->isValid()
                && !desktopFile->value(QStringLiteral("NoDisplay")).toBool()) {
            m_items.append(new ApplicationItem(desktopFile));
            qDebug() << "!!! Inserted application item" << m_items.last()->appId() << m_items.last()->desktopFile()->name() <<
                        m_items.last()->desktopFile()->iconName();
        }
    }
    endResetModel();
}
