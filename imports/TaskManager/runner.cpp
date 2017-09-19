#include <QDebug>
#include <QProcess>

#include "runner.h"

Runner::Runner(QObject *parent)
    : QObject(parent)
{
}

void Runner::runCommand(const QString &command, const QStringList &args)
{
    QProcess::startDetached(command, args);
}
