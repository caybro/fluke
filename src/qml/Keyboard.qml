import QtQuick 2.12
import QtQuick.VirtualKeyboard 2.12

import org.fluke.Session 1.0

InputPanel {
    opacity: active ? 1.0 : 0.0
    visible: opacity != 0.0
    y: !Platform.isPC && active ? parent.height - height : parent.height // TODO make the OSD configurable
    anchors.left: parent.left
    anchors.right: parent.right
    Behavior on y { DefaultAnimation {} }
    Behavior on opacity { DefaultAnimation {} }
}
