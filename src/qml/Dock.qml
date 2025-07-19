import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import org.fluke.TaskManager

Pane {
    id: dock
    height: 64
    opacity: visible ? 0.9 : 0.0
    padding: 0
    activeFocusOnTab: false
    enabled: visible
    hoverEnabled: true

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

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
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
                        Layout.alignment: Qt.AlignCenter
                        icon: model.icon
                        width: 32
                        height: width
                    }
                    Label {
                        Layout.alignment: Qt.AlignCenter
                        text: Array(Math.min(model.instanceCount+1, 4)).join("\uf111\u2009") // up to 3 dots + small space
                        color: Material.accent
                        font.pixelSize: 7
                        visible: model.running
                    }
                }

                ToolTip.text: "%1 (%2)".arg(model.comment).arg(model.name)
                ToolTip.visible: hovered && model.comment

                ContextMenu.menu: LauncherContextMenu {
                    currentItem: appDelegate
                }

                onClicked: {
                    if (!model.running) {
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
            Layout.topMargin: -6
            Layout.alignment: Qt.AlignCenter
            flat: true
            icon.source: "qrc:/icons/material/apps-24px.svg"
            icon.height: 32
            icon.width: 32
            ToolTip.text: qsTr("Applications")
            ToolTip.visible: hovered
            onClicked: dock.showLauncher()
        }
    }
}
