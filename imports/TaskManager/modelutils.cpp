#include "modelutils.h"

namespace {
constexpr auto kNoRoleFound = -1;
}

ModelUtils::ModelUtils(QObject *parent)
    : QObject{parent}
{}

int ModelUtils::roleByName(QAbstractItemModel *model, const QString &roleName) const
{
  if (!model)
    return kNoRoleFound;

  return model->roleNames().key(roleName.toUtf8(), kNoRoleFound);
}

QVariantMap ModelUtils::get(QAbstractItemModel *model, int row) const
{
  if (!model)
    return {};

  QVariantMap map;

  const auto modelIndex = model->index(row, 0);
  const auto roles = model->roleNames();

  for (auto it = roles.begin(); it != roles.end(); ++it)
    map.insert(it.value(), model->data(modelIndex, it.key()));

  return map;
}

QVariant ModelUtils::get(QAbstractItemModel *model, int row, const QString &roleName) const
{
  if (auto role = roleByName(model, roleName); role != kNoRoleFound)
    return model->data(model->index(row, 0), role);

  return {};
}
