import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import org.kde.kquickcontrolsaddons 2.0

import org.fluke.TaskManager 1.0

Pane {
    id: dock
    height: 70
    opacity: 0.9
    padding: 3
    activeFocusOnTab: false

    readonly property alias count: view.count
    property string activeApp

    signal activateApplication(string appId)

    ContextMenu {
        id: contextMenu
    }

    ListView {
        id: view
        implicitWidth: childrenRect.width
        orientation: ListView.Horizontal
        model: ApplicationsFilteredModel {
            sourceModel: Applications
            showFavoriteAndRunning: true
        }
        delegate: ItemDelegate {
            id: appDelegate
            highlighted: appId == dock.activeApp

            readonly property string appId: model.appId
            readonly property bool favorite: model.favorite
            readonly property bool running: model.running

            contentItem: ColumnLayout {
                spacing: 0
                QIconItem {
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon: model.icon
                    width: 32
                    height: width
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uf111"
                    color: Material.accent
                    visible: model.running
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
                if (!running) {
                    Applications.startApplication(appId);
                } else {
                    dock.activateApplication(appId)
                }
            }
        }
        addDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 200 }
        }
        removeDisplaced: addDisplaced
    }
}
