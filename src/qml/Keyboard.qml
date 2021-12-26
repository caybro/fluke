import QtQuick 2.15
import QtQuick.VirtualKeyboard 2.15
import QtQuick.VirtualKeyboard.Settings 2.15

import org.fluke.Session 1.0

InputPanel {
    opacity: active ? 1.0 : 0.0
    visible: opacity != 0.0
    y: !Platform.isPC && active ? parent.height - height : parent.height // TODO make the OSK configurable
    anchors.left: parent.left
    anchors.right: parent.right
    Behavior on y { DefaultAnimation {} }
    Behavior on opacity { DefaultAnimation {} }
}
