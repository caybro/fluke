#include <QDebug>

#include "applicationsmodel.h"

ApplicationsModel::ApplicationsModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_settings(QStringLiteral("caybro"), QStringLiteral("fluke"))
{
    m_roleNames = {
        {ApplicationItem::RoleAppId, QByteArrayLiteral("appId")},
        {ApplicationItem::RoleName, QByteArrayLiteral("name")},
        {ApplicationItem::RoleComment, QByteArrayLiteral("comment")},
        {ApplicationItem::RoleIcon, QByteArrayLiteral("icon")},
        {ApplicationItem::RoleKeywords, QByteArrayLiteral("keywords")},
        {ApplicationItem::RoleRunning, QByteArrayLiteral("running")},
        {ApplicationItem::RoleFavorite, QByteArrayLiteral("favorite")},
        {ApplicationItem::RoleInstanceCount, QByteArrayLiteral("instanceCount")}
    };
    loadSettings();
    init();
}

ApplicationsModel::~ApplicationsModel()
{
    saveSettings();
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
                case ApplicationItem::RoleAppId:
                    return item->appId();
                case ApplicationItem::RoleName:
                case Qt::DisplayRole:
                    return item->name();
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
                case ApplicationItem::RoleRunning: return item->isRunning();
                case ApplicationItem::RoleFavorite: return item->isFavorite();
                case ApplicationItem::RoleInstanceCount: return item->instanceCount();
                }
            }
        }
    }
    return QVariant();
}

bool ApplicationsModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid() && role == ApplicationItem::RoleFavorite) {
        const int row = index.row();
        if (row >= 0 && row < m_items.count()) {
            const auto item = m_items.at(row);
            item->setFavorite(value.toBool());
            return true;
        }
    }
    return QAbstractListModel::setData(index, value, role);
}

QHash<int, QByteArray> ApplicationsModel::roleNames() const
{
    return m_roleNames;
}

void ApplicationsModel::setSurfaceAppeared(const QString &appId, QWaylandSurface *surface)
{
    qInfo() << "!!! Surface appeared" << appId << surface << surface->client()->processId();
    if (appId.isEmpty())
        return;

    auto appItem = findAppItem(appId);
    if (appItem) {
        appItem->incrementSurfaceCount(surface);
    }
}

void ApplicationsModel::setSurfaceVanished(const QString &appId, QWaylandSurface *surface)
{
    qInfo() << "!!! Surface vanished" << appId << surface;
    if (appId.isEmpty())
        return;

    auto appItem = findAppItem(appId);
    if (appItem) {
        appItem->decrementSurfaceCount(surface);
    }
}

void ApplicationsModel::setApplicationFavorite(const QString &appId, bool favorite)
{
    auto item = findAppItem(appId);
    if (item) {
        item->setFavorite(favorite);

        if (favorite) {
            m_favoriteAppIds.append(appId);
        } else {
            m_favoriteAppIds.removeAll(appId);
        }
    }
}

void ApplicationsModel::startApplication(const QString &appId, const QStringList &urls)
{
    auto item = findAppItem(appId);
    if (item) {
        item->launch(urls);
    }
}

void ApplicationsModel::stopApplication(const QString &appId)
{
    auto item = findAppItem(appId);
    if (item) {
        item->stop();
    }
}

void ApplicationsModel::init()
{
    beginResetModel();
    for(XdgDesktopFile * desktopFile: XdgDesktopFileCache::getAllFiles()) {
        if (desktopFile->type() == XdgDesktopFile::ApplicationType
                && desktopFile->isValid()
                && !desktopFile->value(QStringLiteral("NoDisplay")).toBool()) {
            auto item = new ApplicationItem(desktopFile);
            m_items.append(item);
            connect(item, &ApplicationItem::surfaceCountChanged, [this, item]() {
                const QModelIndex idx = index(m_items.indexOf(item));
                Q_EMIT dataChanged(idx, idx, {ApplicationItem::RoleRunning, ApplicationItem::RoleInstanceCount});
            });
            connect(item, &ApplicationItem::isFavoriteChanged, [this, item]() {
                const QModelIndex idx = index(m_items.indexOf(item));
                Q_EMIT dataChanged(idx, idx, {ApplicationItem::RoleFavorite});
            });
            connect(item, &ApplicationItem::applicationQuit, this, &ApplicationsModel::applicationQuit);
            item->setFavorite(m_favoriteAppIds.contains(item->appId()));

            qDebug() << "!!! Inserted application item" << item->appId() << item->desktopFile()->name() <<
                        item->desktopFile()->iconName();
        }
    }
    endResetModel();
}

ApplicationItem *ApplicationsModel::findAppItem(const QString &appId) const
{
    const auto it = std::find_if(m_items.constBegin(), m_items.constEnd(), [appId](ApplicationItem *appItem) {
        return appItem->appId() == appId;
    });
    if (it != m_items.constEnd()) {
        return (*it);
    }
    return nullptr;
}

void ApplicationsModel::loadSettings()
{
    m_favoriteAppIds = m_settings.value(QStringLiteral("Favorites")).toStringList();
}

void ApplicationsModel::saveSettings()
{
    m_favoriteAppIds.removeDuplicates();
    m_settings.setValue(QStringLiteral("Favorites"), QVariant(m_favoriteAppIds));
}
