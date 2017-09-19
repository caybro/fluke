#pragma once

#include <QObject>

class Runner: public QObject
{
    Q_OBJECT
public:
    explicit Runner(QObject * parent = nullptr);
    ~Runner() = default;

    Q_INVOKABLE void runCommand(const QString &command, const QStringList &args = {});
};
