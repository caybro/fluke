#include <QDebug>
#include <QFileInfo>

#include "applicationitem.h"

ApplicationItem::ApplicationItem(const QString &appId)
    : m_appId(appId)
{
    m_desktopFile = XdgDesktopFileCache::getFile(appId + ".desktop");
    if (!m_desktopFile) {
        qWarning() << "Could not find desktop file with appId:" << appId;
    }
}

ApplicationItem::ApplicationItem(XdgDesktopFile *desktopFile)
    : m_desktopFile(desktopFile)
{
    QFileInfo fi(m_desktopFile->fileName());
    m_appId = fi.completeBaseName();
}

QString ApplicationItem::appId() const
{
    return m_appId;
}

XdgDesktopFile *ApplicationItem::desktopFile() const
{
    return m_desktopFile;
}

void ApplicationItem::launch(const QStringList &urls)
{
    if (m_desktopFile) {
        m_desktopFile->startDetached(urls);
    }
}
