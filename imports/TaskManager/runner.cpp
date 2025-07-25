#include <QDebug>
#include <QProcess>

#include <XdgDefaultApps>
#include <XdgDesktopFile>

#include "runner.h"

Runner::Runner(QObject *parent)
    : QObject(parent)
{
}

void Runner::runCommand(const QString &command, const QStringList &args)
{
    QProcess::startDetached(command, args);
}

void Runner::runDefaultTerminal()
{
  auto terminal = XdgDefaultApps::terminal();
  auto result = false;
  if (terminal) {
    result = terminal->startDetached();
  } else {
    const auto terminals = XdgDefaultApps::terminals();
    if (!terminals.isEmpty()) {
      terminal = terminals.constFirst();
      result = terminal->startDetached();
    }
  }
  qInfo() << "RUNNER: Terminal" << (terminal ? terminal->fileName() : "") << "started succesfully:" << result;
}
