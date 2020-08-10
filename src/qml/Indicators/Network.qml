import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.12

import org.fluke.Network 1.0

ToolButton {
    id: root
    icon {
        source: indicatorIcon()
        width: 20
        height: 18
    }
    down: popup.visible
    hoverEnabled: true

    ToolTip.text: qsTr("Network: %1").arg(Network.online ? Network.ssid : qsTr("Offline"))
    ToolTip.visible: hovered && !popup.visible

    function getBars() {
        const strength = Network.strength;
        if (strength < 10)
            return "0";
        else if (strength < 25)
            return "1";
        else if (strength < 50)
            return "2";
        else if (strength < 75)
            return "3";
        else
            return "4";
    }

    function indicatorIcon() {
        if (!Network.wifiEnabled)
            return "qrc:/icons/network/ic_signal_wifi_off_24px.svg"
        else if (Network.wifiEnabled && !Network.ssid)
            return "qrc:/icons/network/ic_signal_wifi_statusbar_not_connected_26x24px.svg"
        else if (Network.ssid && !Network.online) {
            return "qrc:/icons/network/ic_signal_wifi_statusbar_connected_no_internet_%1_26x24px.svg".arg(getBars());
        } else if (Network.ssid && Network.online) {
            return "qrc:/icons/network/ic_signal_wifi_statusbar_%1_bar_26x24px.svg".arg(getBars());
        }
    }

    Connections {
        target: Network
        onStrengthChanged: console.debug("!!! Strength changed:", Network.strength)
        onAccessPointsChanged: console.debug("!!! APs changed:", Network.accessPoints)
    }

    Component.onCompleted: {
        console.debug("!!! Online:", Network.online);
        console.debug("!!! WIFI enabled:", Network.wifiEnabled)
        console.debug("!!! SSID:", Network.ssid)
        console.debug("!!! Strength:", Network.strength)
    }

    Popup {
        id: popup
        focus: visible
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        x: (parent.width - implicitWidth) / 2
        y: parent.height

        ColumnLayout {
            anchors.fill: parent

            Switch {
                text: qsTr("WiFi Enabled")
                enabled: Network.wifiHWEnabled
                checked: Network.wifiEnabled
                onToggled: Network.wifiEnabled = checked
            }

            // TODO list of APs/networks
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
