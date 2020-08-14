import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12

import org.fluke.Network 1.0

ToolButton {
    id: root
    icon {
        source: indicatorIcon()
        width: 20
        height: 18
    }
    down: popupLoader.item && popupLoader.item.visible
    hoverEnabled: true

    ToolTip.text: qsTr("Network: %1").arg(Network.online ? Network.ssid : qsTr("Offline"))
    ToolTip.visible: hovered && (!popupLoader.item || !popupLoader.item.visible)

    function getBars(aStrength) {
        const strength = aStrength || Network.strength;
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

    function indicatorIcon(strength) {
        if (!Network.wifiEnabled)
            return "qrc:/icons/network/ic_signal_wifi_off_24px.svg"
        else if (Network.wifiEnabled && !Network.ssid)
            return "qrc:/icons/network/ic_signal_wifi_statusbar_not_connected_26x24px.svg"
        else if (Network.ssid && !Network.online) {
            return "qrc:/icons/network/ic_signal_wifi_statusbar_connected_no_internet_%1_26x24px.svg".arg(getBars(strength));
        } else if (Network.ssid && Network.online) {
            return "qrc:/icons/network/ic_signal_wifi_statusbar_%1_bar_26x24px.svg".arg(getBars(strength));
        }
    }

    Loader {
        id: popupLoader
        active: false
        focus: visible
        y: parent.height

        sourceComponent: Popup {
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
            onClosed: parent.active = false;

            ColumnLayout {
                id: layout
                anchors.fill: parent

                Switch {
                    text: qsTr("WiFi Enabled")
                    enabled: Network.wifiHWEnabled
                    checked: Network.wifiEnabled
                    onToggled: Network.wifiEnabled = checked
                }

                ToolSeparator {
                    Layout.fillWidth: true
                    orientation: Qt.Horizontal
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 300
                    model: Network.accessPoints
                    clip: true
                    delegate: ItemDelegate {
                        readonly property var apData: Network.apData(modelData)
                        width: parent.width
                        text: apData.ssid
                        icon.source: indicatorIcon(apData.strength)
                        font.bold: modelData === Network.activeAp
                    }
                }
            }
        }
    }

    onClicked: {
        if (!popupLoader.item) {
            popupLoader.active = true;
        }

        if (popupLoader.item.visible) {
            popupLoader.item.close();
        } else {
            popupLoader.item.open();
        }
    }
}
