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
        Applications.startApplication(appId);
        hide();
    }

    Behavior on opacity { NumberAnimation { duration: 200 } }

    Keys.onEscapePressed: hide()
    Keys.enabled: true
    Keys.forwardTo: searchField.activeFocus ? null : searchField

    onVisibleChanged: {
        if (visible) {
            searchField.selectAll();
        }
    }

    ApplicationsFilteredModel {
        id: filterModel
        sourceModel: Applications
        filterString: searchField.text
        showRunning: tabRunning.checked
        showFavorite: tabFavorite.checked
    }

    Component {
        id: appItemComponent
        ItemDelegate {
            id: appDelegate
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight
            highlighted: GridView.isCurrentItem

            readonly property string appId: model.appId
            readonly property bool favorite: model.favorite
            readonly property bool running: model.running

            contentItem: ColumnLayout {
                spacing: 0
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
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    // @disable-check M306
                    text: Array(Math.min(model.instanceCount+1, 4)).join("\uf111\u2009") // up to 3 dots + small space
                    color: Material.accent
                    visible: model.running && !filterModel.showRunning
                    font.pixelSize: 7
                }
            }

            ToolTip.text: model.comment
            ToolTip.visible: hovered && model.comment
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.LeftButton
                onPressed: {
                    if (mouse.buttons == Qt.RightButton) {
                        contextMenu.currentItem = appDelegate;
                        contextMenu.open();
                        mouse.accepted = true;
                    } else {
                        mouse.accepted = false;
                    }
                }
            }

            onClicked: {
                launchApp(appId);
            }
        }
    }

    ContextMenu {
        id: contextMenu
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

        GridView {
            id: gridView
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: filterModel
            delegate: appItemComponent
            cellWidth: parent.width / 6
            clip: true
            currentIndex: 0
            activeFocusOnTab: true

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200 }
            }
            moveDisplaced: displaced

            ScrollBar.vertical: ScrollBar {}

            Keys.onPressed: {
                if (gridView.currentItem) {
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        event.accepted = true;
                        launchApp(gridView.currentItem.appId);
                    } else if (event.key === Qt.Key_Home) {
                        gridView.currentIndex = 0;
                    } else if (event.key === Qt.Key_End) {
                        gridView.currentIndex = gridView.count - 1;
                    }
                }
            }
        }

        TabBar {
            Layout.preferredWidth: parent.width / 3
            anchors.horizontalCenter: parent.horizontalCenter
            activeFocusOnTab: true
            onCurrentIndexChanged: searchField.clear()
            TabButton {
                id: tabAll
                text: qsTr("All", "all applications")
            }
            TabButton {
                id: tabRunning
                text: qsTr("Running", "running applications")
            }
            TabButton {
                id: tabFavorite
                text: qsTr("Favorite", "favorite applications")
            }
        }
    }
}
