#include <QDebug>
#include <QFileInfo>

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
    return m_surfaceCount;
}

void ApplicationItem::launch(const QStringList &urls)
{
    if (m_desktopFile) {
        m_desktopFile->startDetached(urls);
    }
}

bool ApplicationItem::isRunning() const
{
    return m_surfaceCount > 0;
}

void ApplicationItem::incrementSurfaceCount()
{
    m_surfaceCount++;
    Q_EMIT surfaceCountChanged(m_surfaceCount);
}

void ApplicationItem::decrementSurfaceCount()
{
    m_surfaceCount--;
    Q_EMIT surfaceCountChanged(m_surfaceCount);
}
