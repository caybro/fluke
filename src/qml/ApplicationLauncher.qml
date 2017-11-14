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

    function launchApp(appId) {
        Applications.runApplication(appId);
        hide();
    }

    Behavior on opacity { NumberAnimation { duration: 200 } }

    Keys.onEscapePressed: hide()

    onVisibleChanged: {
        if (visible) {
            searchField.selectAll()
        }
    }

    ApplicationsFilteredModel {
        id: filterModel
        sourceModel: Applications
        filterString: searchField.text
    }

    Component {
        id: appItemComponent
        ItemDelegate {
            id: appDelegate
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            readonly property string appId: model.appId

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

            onClicked: launchApp(appId)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 30

        TextField {
            id: searchField
            selectByMouse: true
            Layout.preferredWidth: parent.width / 3
            anchors.horizontalCenter: parent.horizontalCenter
            focus: true
            placeholderText: qsTr("Type to search...")
            activeFocusOnTab: true
            onAccepted: {
                if (gridView.count > 0) {
                    launchApp(gridView.currentItem.appId);
                }
            }
        }

        Component {
            id: highlightComponent
            Rectangle {
                width: GridView.view.cellWidth; height: GridView.view.cellHeight
                color: Material.primary; radius: 5
                x: GridView.view.currentItem.x
                y: GridView.view.currentItem.y
                Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
                Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
            }
        }

        GridView {
            id: gridView
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: filterModel
            delegate: appItemComponent
            cellWidth: parent.width / 5
            clip: true
            currentIndex: 0
            highlight: gridView.activeFocus ? highlightComponent : undefined
            activeFocusOnTab: true

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200 }
            }
            moveDisplaced: displaced

            ScrollBar.vertical: ScrollBar { }

            Keys.onPressed: {
                if (gridView.currentItem && (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
                    launchApp(gridView.currentItem.appId);
                }
            }
        }

        TabBar {
            Layout.preferredWidth: parent.width / 3
            anchors.horizontalCenter: parent.horizontalCenter
            activeFocusOnTab: true
            TabButton {
                text: qsTr("All")
            }
            TabButton {
                text: qsTr("Favorite")
            }
        }
    }
}
