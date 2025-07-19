#pragma once

#include <QAbstractItemModel>
#include <QtQmlIntegration/qqmlintegration.h>

class ModelUtils : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

 public:
  explicit ModelUtils(QObject *parent = nullptr);

  Q_INVOKABLE int roleByName(QAbstractItemModel *model,
                             const QString &roleName) const;
  Q_INVOKABLE QVariantMap get(QAbstractItemModel *model, int row) const;
  Q_INVOKABLE QVariant get(QAbstractItemModel *model, int row,
                           const QString &roleName) const;
};
