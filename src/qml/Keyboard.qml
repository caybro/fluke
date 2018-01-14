import QtQuick 2.6
import QtQuick.VirtualKeyboard 2.1

import org.fluke.Session 1.0

Item {
    id: root
    height: inputPanel.height
    enabled: !Platform.isPC
    visible: enabled

    InputPanel {
        id: inputPanel
        anchors.left: parent.left
        anchors.right: parent.right

        states: [
            State {
                name: "active"
                when: inputPanel.active
                PropertyChanges { target: inputPanel; y: 0; visible: true }
            },
            State {
                name: "hidden"
                when: !inputPanel.active
                PropertyChanges { target: inputPanel; y: height; visible: false }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"; to: "active"
                NumberAnimation { target: inputPanel; property: "y"; duration: 200 }
            },
            Transition {
                from: "active"; to: "hidden"
                // keep it visible until the trantision finishes
                PropertyAction { target: inputPanel; property: "visible"; value: true }
                NumberAnimation { target: inputPanel; property: "y"; duration: 200 }
            }
        ]
    }
}
