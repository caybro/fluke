import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.fluke.TaskManager

Pane {
    id: root
    visible: opacity > 0.0
    enabled: visible
    focus: visible

    function show() {
        opacity = 0.8;
    }

    function hide() {
        opacity = 0.0;
    }

    function launchApp(appId) {
        Applications.startApplication(appId);
        hide();
    }

    signal activateApplication(string appId)

    Behavior on opacity { DefaultAnimation {} }

    Keys.onEscapePressed: hide()
    Keys.enabled: true
    Keys.forwardTo: searchField.activeFocus ? null : searchField

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        onClicked: {
            if (mouse.button === Qt.BackButton) {
                hide();
            }
        }
    }

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
            padding: 0
            hoverEnabled: true

            readonly property string appId: model.appId
            readonly property bool favorite: model.favorite
            readonly property bool running: model.running

            contentItem: ColumnLayout {
                spacing: 0
                IconItem {
                    Layout.alignment: Qt.AlignHCenter
                    icon: model.icon
                    width: 64
                    height: width
                }
                Label {
                    Layout.preferredWidth: parent.width
                    text: model.name
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: Array(Math.min(model.instanceCount+1, 4)).join("\uf111\u2009") // up to 3 dots + small space
                    color: Material.accent
                    visible: model.running && !filterModel.showRunning
                    font.pixelSize: 7
                }
            }

            ToolTip.text: model.comment
            ToolTip.visible: hovered && model.comment
            ToolTip.delay: 500

            ContextMenu.menu: LauncherContextMenu {
                currentItem: appDelegate
            }

            onClicked: {
                if (!running) {
                    launchApp(appId);
                } else {
                    root.activateApplication(appId);
                    hide();
                }
            }

            GridView.onRemove: SequentialAnimation {
                PropertyAction { target: appDelegate; property: "GridView.delayRemove"; value: true }
                DefaultAnimation { target: appDelegate; properties: "opacity,scale"; to: 0 }
                PropertyAction { target: appDelegate; property: "GridView.delayRemove"; value: false }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        TextField {
            id: searchField
            selectByMouse: true
            Layout.preferredWidth: parent.width / 3
            Layout.alignment: Qt.AlignHCenter
            focus: true
            placeholderText: qsTr("Type to search...")
            activeFocusOnTab: true
            onAccepted: {
                if (gridView.count > 0) {
                    launchApp(gridView.currentItem.appId);
                }
            }
            KeyNavigation.down: gridView
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
            snapMode: GridView.SnapToRow

            displaced: Transition {
                DefaultAnimation { properties: "x,y" }
            }

            ScrollIndicator.vertical: ScrollIndicator {}

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
            KeyNavigation.down: tabBar
        }

        TabBar {
            id: tabBar
            Layout.preferredWidth: parent.width / 3
            Layout.alignment: Qt.AlignHCenter
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
