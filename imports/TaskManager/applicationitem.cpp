#include <QDebug>
#include <QFileInfo>
#include <QProcess>

#include "applicationitem.h"

ApplicationItem::ApplicationItem(const QString &appId, QObject *parent)
    : QObject(parent),
      m_appId(appId)
{
  m_desktopFile = new XdgDesktopFile(XdgDesktopFile::ApplicationType, appId);
  if (!m_desktopFile->isValid()) {
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

QList<qint64> ApplicationItem::pids() const
{
    return m_surfaces.uniqueKeys();
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
    if (Q_LIKELY(m_desktopFile)) {
        QStringList execLine = m_desktopFile->expandExecString(urls);

        auto proc = new QProcess(this);
        connect(proc, &QProcess::started, this, [this, proc]() {
            if (proc->state() == QProcess::Running) {
                //qWarning() << "!!! Start app" << m_appId << "; PID:" << proc->processId();
                proc->setProperty("pid", proc->processId());
                m_surfaces.insert(proc->processId(), nullptr);
            }
        });
        connect(proc, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this, [this, proc]() {
            //qWarning() << "!!! Quit app" << m_appId << "; PID:" << proc->property("pid").toLongLong();
            m_surfaces.remove(proc->property("pid").toLongLong());
            emit surfaceCountChanged(this->surfaceCount());
        });
        proc->start(execLine.takeFirst(), execLine);
    }
}

void ApplicationItem::stop()
{
    if (!m_surfaces.isEmpty()) {
        m_surfaces.first()->client()->close();
    }
}

void ApplicationItem::setFavorite(bool favorite)
{
    if (m_favorite == favorite)
        return;

    m_favorite = favorite;
    emit isFavoriteChanged(m_favorite);
}

bool ApplicationItem::isFavorite() const
{
    return m_favorite;
}

int ApplicationItem::instanceCount() const
{
    return pids().count();
}

bool ApplicationItem::isRunning() const
{
    return !m_surfaces.isEmpty();
}

void ApplicationItem::incrementSurfaceCount(qint64 pid, QWaylandSurface *surface)
{
    if (m_surfaces.contains(pid) && !m_surfaces.value(pid)) {
        m_surfaces.replace(pid, surface);
    } else {
        m_surfaces.insert(pid, surface);
    }
    emit surfaceCountChanged(surfaceCount());
}

void ApplicationItem::decrementSurfaceCount(qint64 pid, QWaylandSurface *surface)
{
    m_surfaces.remove(pid, surface);

    emit surfaceCountChanged(surfaceCount());
    if (!m_surfaces.contains(pid)) {
        emit applicationQuit(m_appId);
    }
}
