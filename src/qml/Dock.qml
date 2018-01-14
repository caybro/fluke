import QtQuick 2.9
import QtQuick.Controls 2.2
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
                        text: model.running ? "\uf111" : ""
                        color: Material.accent
                        font.pixelSize: 7
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
            }
            addDisplaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200 }
            }
            removeDisplaced: addDisplaced
        }

        Button {
            Layout.fillHeight: true
            Layout.topMargin: -12
            anchors.verticalCenter: parent.verticalCenter
            flat: true
            text: "\uf00a"
            ToolTip.text: qsTr("Applications")
            ToolTip.visible: hovered
            font.pixelSize: 24
            onClicked: dock.showLauncher()
        }
    }
}
