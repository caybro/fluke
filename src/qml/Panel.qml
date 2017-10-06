import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "Indicators" as Indicators

import org.fluke.Sound 1.0

Pane {
    id: panel
    implicitHeight: contentHeight
    padding: 0

    signal logout()
    signal suspend()
    signal reboot()
    signal shutdown()

    readonly property var soundIndicator: soundIndicatorLoader.item ? soundIndicatorLoader.item : null

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        Indicators.DateTime {
            anchors.centerIn: parent
        }

        RowLayout {
            id: rightSection
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

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
