#include <QDebug>
#include <QFileInfo>

#include <QWaylandClient>

#include "applicationitem.h"

ApplicationItem::ApplicationItem(const QString &appId, QObject *parent)
    : QObject(parent),
      m_appId(appId)
{
    m_desktopFile = XdgDesktopFileCache::getFile(appId + ".desktop");
    if (!m_desktopFile) {
        qWarning() << "Could not find desktop file with appId:" << appId;
    }
}

ApplicationItem::ApplicationItem(XdgDesktopFile *desktopFile, QObject *parent)
    : QObject(parent),
      m_desktopFile(desktopFile)
{
    QFileInfo fi(m_desktopFile->fileName());
    m_appId = fi.completeBaseName();
}

QString ApplicationItem::appId() const
{
    return m_appId;
}

QString ApplicationItem::name() const
{
    return m_desktopFile->name();
}

XdgDesktopFile *ApplicationItem::desktopFile() const
{
    return m_desktopFile;
}

int ApplicationItem::surfaceCount() const
{
    return m_surfaces.count();
}

void ApplicationItem::launch(const QStringList &urls)
{
    if (m_desktopFile) {
        m_desktopFile->startDetached(urls);
    }
}

void ApplicationItem::stop()
{
    if (!m_surfaces.isEmpty()) {
        m_surfaces.last()->client()->close();
    }
}

int ApplicationItem::instanceCount() const
{
    QSet<QWaylandClient *> clients;
    for(QWaylandSurface *surface: qAsConst(m_surfaces)) {
        clients.insert(surface->client());
    }
    return clients.count();
}

bool ApplicationItem::isRunning() const
{
    return !m_surfaces.isEmpty();
}

void ApplicationItem::incrementSurfaceCount(QWaylandSurface *surface)
{
    m_surfaces.append(surface);
    Q_EMIT surfaceCountChanged(surfaceCount());
}

void ApplicationItem::decrementSurfaceCount(QWaylandSurface *surface)
{
    m_surfaces.removeAll(surface);
    Q_EMIT surfaceCountChanged(surfaceCount());
}
