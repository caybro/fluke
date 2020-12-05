import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

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
    property alias darkMode: sessionIndicator.darkMode
    property alias showDate: dateIndicator.showDate
    property alias showSeconds: dateIndicator.showSeconds
    readonly property var soundIndicator: soundIndicatorLoader.item ? soundIndicatorLoader.item : null

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        ToolButton {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            visible: appLauncherVisible
            hoverEnabled: visible
            icon.source: "qrc:/icons/material/chevron_left-24px.svg"
            ToolTip.text: qsTr("Back")
            ToolTip.visible: hovered
            onClicked: panel.hideLauncher()
        }

        RowLayout {
            anchors.centerIn: parent
            //Layout.alignment: Qt.AlignCenter // FIXME doesn't work :/

            Indicators.DateTime {
                id: dateIndicator
            }

            Indicators.Weather {}
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            // TODO keyboard switcher

            Indicators.Network {}

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
