import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "Indicators" as Indicators

import org.fluke.Sound 1.0

ToolBar {
    id: panel
    opacity: appLauncherVisible ? 0.9 : 1.0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    background: Rectangle {
        color: Material.background
    }

    signal logout()
    signal suspend()
    signal reboot()
    signal shutdown()
    signal showLauncher()

    property bool appLauncherVisible: false
    readonly property var soundIndicator: soundIndicatorLoader.item ? soundIndicatorLoader.item : null

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        ToolButton {
            text: appLauncherVisible ? "\uf060" : "\uf0c9"
            ToolTip.text: appLauncherVisible ? qsTr("Back") : qsTr("Menu")
            ToolTip.visible: hovered
            onClicked: panel.showLauncher()
        }

        Indicators.DateTime {
            anchors.centerIn: parent
        }

        RowLayout {
            id: rightSection
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            // TODO keyboard switcher
            // TODO network/wifi

            Loader {
                id: soundIndicatorLoader
                active: Sound.available
                sourceComponent: Indicators.Sound {}
            }

            Indicators.Power {}

            Indicators.Session {
                onLogout: panel.logout()
                onSuspend: panel.suspend()
                onReboot: panel.reboot()
                onShutdown: panel.shutdown()
            }
        }
    }
}
