import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings

import org.fluke.Session

InputPanel {
    opacity: active ? 1.0 : 0.0
    visible: opacity != 0.0
    y: !Platform.isPC && active ? parent.height - height : parent.height // TODO make the OSK configurable
    anchors.left: parent.left
    anchors.right: parent.right
    Behavior on y { DefaultAnimation {} }
    Behavior on opacity { DefaultAnimation {} }
}
