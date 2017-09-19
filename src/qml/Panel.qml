import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "Indicators" as Indicators

Pane {
    id: panel
    implicitHeight: contentHeight
    padding: 0

    signal logout()
    signal suspend()
    signal reboot()
    signal shutdown()

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        Item {
            id: spacer
            Layout.fillWidth: true
        }

        // TODO keyboard switcher
        // TODO network/wifi
        // TODO sound
        // TODO power

        Indicators.DateTime {
            id: indicatorDateTime
        }

        Indicators.Session {
            onLogout: panel.logout()
            onSuspend: panel.suspend()
            onReboot: panel.reboot()
            onShutdown: panel.shutdown()
        }
    }
}
