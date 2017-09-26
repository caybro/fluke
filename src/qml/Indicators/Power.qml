import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.fluke.Power 1.0

ToolButton {
    id: indicatorPower
    text: indicatorCaption()

    ToolTip.text: indicatorTooltip()
    ToolTip.visible: Power.isPresent && hovered && !popup.visible

    function indicatorCaption() {
        if (!Power.isPresent) {
            return "\uf1e6"; // plug icon, no battery present
        }

        var iconName;
        var perc = Power.percentage;

        if (perc <= 10) {
            iconName = "<font color='#F44336'>\uf244</font>";
        } else if (perc <= 25) {
            iconName = "\uf243";
        } else if (perc <= 50) {
            iconName = "\uf242";
        } else if (perc <= 75) {
            iconName = "\uf241";
        } else {
            iconName = "\uf240";
        }
        return "%1 %2%".arg(iconName).arg(Math.floor(perc)); // we're being a bit pessimistic here ;)
    }

    function indicatorTooltip() {
        var state = Power.state;
        if (state == Power.Charging) {
            return qsTr("Time to charge: %1").arg(Power.remainingTime);
        } else if (state == Power.Discharging) {
            return qsTr("Remaining time: %1").arg(Power.remainingTime);
        } else if (state == Power.FullyCharged) {
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
                    text: "\uf185"
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
        if (popup.visible)
            popup.close()
        else
            popup.open()
    }
}
