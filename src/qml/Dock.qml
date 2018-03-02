import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import org.fluke.TaskManager 1.0

Pane {
    id: dock
    height: 70
    opacity: visible ? 0.9 : 0.0
    padding: 3
    activeFocusOnTab: false
    enabled: visible

    readonly property int count: view.count + 1
    property string activeApp

    signal showLauncher()
    signal activateApplication(string appId)

    background: Rectangle {
        color: Material.background
        radius: 5
        Behavior on color { ColorAnimation {} }
    }

    Behavior on y { DefaultAnimation {} }
    Behavior on opacity { DefaultAnimation {} }

    function show() {
        dock.y = Qt.binding(function () { return parent.height - dock.height + dock.background.radius; });
    }

    function hide() {
        dock.y = Qt.binding(function () { return parent.height; });
    }

    ContextMenu {
        id: contextMenu
    }

    RowLayout {
        anchors.fill: parent
        spacing: 3
        ListView {
            id: view
            Layout.fillHeight: true
            implicitWidth: childrenRect.width
            orientation: ListView.Horizontal
            spacing: 3
            model: ApplicationsFilteredModel {
                sourceModel: Applications
                showFavoriteAndRunning: true
            }
            visible: count > 0
            delegate: ItemDelegate {
                id: appDelegate
                highlighted: appId == dock.activeApp

                readonly property string appId: model.appId
                readonly property bool favorite: model.favorite
                readonly property bool running: model.running

                contentItem: ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    IconItem {
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon: model.icon
                        width: 32
                        height: width
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        // @disable-check M306
                        text: Array(Math.min(model.instanceCount+1, 4)).join("\uf111\u2009") // up to 3 dots + small space
                        color: Material.accent
                        font.pixelSize: 7
                        visible: model.running
                    }
                }

                ToolTip.text: "%1 (%2)".arg(model.comment).arg(model.name)
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
                    if (!running) {
                        Applications.startApplication(appId);
                    } else {
                        dock.activateApplication(appId);
                    }
                }

                ListView.onRemove: SequentialAnimation {
                    PropertyAction { target: appDelegate; property: "ListView.delayRemove"; value: true }
                    DefaultAnimation { target: appDelegate; properties: "opacity,scale"; to: 0 }
                    PropertyAction { target: appDelegate; property: "ListView.delayRemove"; value: false }
                }
            }
            displaced: Transition {
                DefaultAnimation { properties: "x,y" }
            }
        }

        Button {
            Layout.fillHeight: true
            Layout.topMargin: -12
            anchors.verticalCenter: parent.verticalCenter
            flat: true
            icon.name: "view-app-grid-symbolic"
            icon.height: 32
            ToolTip.text: qsTr("Applications")
            ToolTip.visible: hovered
            onClicked: dock.showLauncher()
        }
    }
}
