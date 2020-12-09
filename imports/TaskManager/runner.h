#pragma once

#include <QObject>
#include <QmlTypeAndRevisionsRegistration>

class Runner: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit Runner(QObject * parent = nullptr);
    ~Runner() = default;

    Q_INVOKABLE void runCommand(const QString &command, const QStringList &args = {});
};
