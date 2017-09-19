import QtQuick 2.6
import QtQuick.VirtualKeyboard 2.1

InputPanel {
    id: inputPanel
    objectName: "inputPanel"
    visible: active
    y: active ? parent.height - inputPanel.height : parent.height
    anchors.left: parent.left
    anchors.right: parent.right
}
