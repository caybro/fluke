/*
 *    Copyright 2011 Marco Martin <mart@kde.org>
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Library General Public
 *    License as published by the Free Software Foundation; either
 *    version 2 of the License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Library General Public License for more details.
 *
 *    You should have received a copy of the GNU Library General Public License
 *    along with this library; see the file COPYING.LIB.  If not, write to
 *    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *    Boston, MA 02110-1301, USA.
 */

#ifndef QICONITEM_H
#define QICONITEM_H

#include <QIcon>
#include <QQuickItem>
#include <QVariant>
#include <QtQmlIntegration/qqmlintegration.h>

class QIconItem : public QQuickItem
{
    Q_OBJECT
    QML_NAMED_ELEMENT(IconItem)

    Q_PROPERTY(QVariant icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(bool smooth READ smooth WRITE setSmooth NOTIFY smoothChanged)
    Q_PROPERTY(int implicitWidth READ implicitWidth CONSTANT)
    Q_PROPERTY(int implicitHeight READ implicitHeight CONSTANT)
    Q_PROPERTY(State state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY stateChanged)

public:

    enum State {
        DefaultState, ///The default state.
        ActiveState, ///Icon is active.
        DisabledState, ///Icon is disabled.
        SelectedState ///Icon is selected
    };
    Q_ENUM(State)

    QIconItem(QQuickItem *parent=nullptr);
    ~QIconItem() override = default;

    void setIcon(const QVariant &icon);
    QIcon icon() const;

    QIconItem::State state() const;
    void setState(State state);

    int implicitWidth() const;
    int implicitHeight() const;

    void setSmooth(const bool smooth);
    bool smooth() const;

    void setEnabled(bool enabled = true);
    bool enabled() const;

Q_SIGNALS:
    void iconChanged();
    void smoothChanged();
    void stateChanged(QIconItem::State state);

protected:
    QSGNode* updatePaintNode(QSGNode* node, UpdatePaintNodeData* data) override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    QIcon m_icon;
    bool m_smooth;
    State m_state;
    bool m_changed;
};

#endif
