import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

import org.fluke.TaskManager 1.0

import org.kde.kquickcontrolsaddons 2.0

Pane {
    id: root
    visible: opacity > 0.0
    enabled: visible
    focus: visible

    function show() {
        opacity = 0.9;
    }

    function hide() {
        opacity = 0.0;
    }

    Behavior on opacity { NumberAnimation { duration: 200 } }

    Keys.onEscapePressed: hide()

    Component {
        id: appItemComponent
        ItemDelegate {
            id: appDelegate
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            contentItem: ColumnLayout {
                QIconItem {
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon: model.icon
                    width: 48
                    height: width
                }
                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: model.name
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                ToolTip.text: model.comment
                ToolTip.visible: appDelegate.hovered && model.comment
            }

            onClicked: {
                Applications.runApplication(index);
                hide();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 30

        TextField {
            Layout.preferredWidth: parent.width / 3
            anchors.horizontalCenter: parent.horizontalCenter
            id: filter
            focus: true
            placeholderText: qsTr("Type to search...")
        }

        GridView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: Applications
            delegate: appItemComponent
            cellWidth: parent.width / 5
            clip: true

            ScrollBar.vertical: ScrollBar { }
        }

        TabBar {
            Layout.preferredWidth: parent.width / 3
            anchors.horizontalCenter: parent.horizontalCenter
            TabButton {
                text: qsTr("All")
            }
            TabButton {
                text: qsTr("Favorite")
            }
        }
    }
}
