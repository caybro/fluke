import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

import "Indicators" as Indicators

import org.fluke.Sound 1.0

ToolBar {
    id: panel
    opacity: appLauncherVisible ? 0.8 : 1.0
    Behavior on opacity { DefaultAnimation {} }

    background: Rectangle {
        color: Material.background
        Behavior on color { ColorAnimation {} }
    }

    signal logout()
    signal suspend()
    signal reboot()
    signal shutdown()
    signal hideLauncher()

    property bool appLauncherVisible: false
    property alias autohideDock: sessionIndicator.autohideDock
    property alias showDate: dateIndicator.showDate
    property alias showSeconds: dateIndicator.showSeconds
    readonly property var soundIndicator: soundIndicatorLoader.item ? soundIndicatorLoader.item : null

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        ToolButton {
            visible: appLauncherVisible
            icon.name: "go-previous-symbolic"
            ToolTip.text: qsTr("Back")
            ToolTip.visible: hovered
            onClicked: panel.hideLauncher()
        }

        RowLayout {
            id: centerSection
            anchors.centerIn: parent

            Indicators.DateTime {
                id: dateIndicator
            }

            Indicators.Weather {}
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
                id: sessionIndicator
                onLogout: panel.logout()
                onSuspend: panel.suspend()
                onReboot: panel.reboot()
                onShutdown: panel.shutdown()
            }
        }
    }
}
