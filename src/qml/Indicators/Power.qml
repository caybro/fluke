import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.fluke.Power 1.0

ToolButton {
    id: indicatorPower
    font.weight: Font.DemiBold
    down: popup.visible

    icon.name: Power.iconName
    text: indicatorCaption()

    ToolTip.text: indicatorTooltip()
    ToolTip.visible: Power.isPresent && hovered && !popup.visible

    function indicatorCaption() {
        var state = Power.state;
        var perc = state === Power.FullyCharged ? 100.0 : Power.percentage;

        var result = "%1%".arg(Math.floor(perc)); // we're being a bit pessimistic here ;)
        if (state === Power.Charging || state === Power.Discharging) {
            result += ", %1".arg(Power.remainingTime);
        }

        return result;
    }

    function indicatorTooltip() {
        var state = Power.state;
        if (state === Power.Charging) {
            return qsTr("Time to charge: %1").arg(Power.remainingTime);
        } else if (state === Power.Discharging) {
            return qsTr("Remaining time: %1").arg(Power.remainingTime);
        } else if (state === Power.FullyCharged) {
            return qsTr("Fully charged");
        }
        return qsTr("Battery not charging or discharging");
    }

    Popup {
        id: popup
        focus: visible
        x: parent.width - implicitWidth
        y: parent.height
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right

                ToolButton {
                    icon.name: "display-brightness-symbolic"
                    onClicked: brightnessSlider.value = 0
                }

                Slider {
                    Layout.fillWidth: true
                    id: brightnessSlider
                    value: 0.8
                    stepSize: 0.1
                    ToolTip.visible: hovered
                    ToolTip.text: "%1%".arg(Math.round(value * 100))
                }
            }
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
