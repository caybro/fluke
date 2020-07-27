import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.fluke.Power 1.0

ToolButton {
    id: indicatorPower
    font.weight: Font.DemiBold
    down: popup.visible
    hoverEnabled: true

    icon {
        source: indicatorIcon()
        width: 16
        height: 16
    }
    text: indicatorCaption()

    ToolTip.text: indicatorTooltip()
    ToolTip.visible: Power.isPresent && hovered && !popup.visible

    function indicatorIcon() {
        const charge = Power.percentage;
        var src = "";
        if (charge < 5)
            src = "battery-empty";
        else if (charge < 30)
            src = "battery-quarter";
        else if (charge < 60)
            src = "battery-half";
        else if (charge < 90)
            src = "battery-three-quarters";
        else
            src = "battery-full";
        return "qrc:/icons/%1-solid.svg".arg(src);
    }

    function indicatorCaption() {
        const state = Power.state;
        const perc = state === Power.FullyCharged ? 100.0 : Power.percentage;

        var result = "%1%".arg(Math.floor(perc)); // we're being a bit pessimistic here ;)
        if (state === Power.Charging || state === Power.Discharging) {
            result += ", %1".arg(Power.remainingTime);
        }

        return result;
    }

    function indicatorTooltip() {
        const state = Power.state;
        var batteryPart = "";
        if (state === Power.Charging) {
            batteryPart = qsTr("Time to charge: %1").arg(Power.remainingTime);
        } else if (state === Power.Discharging) {
            batteryPart = qsTr("Remaining time: %1").arg(Power.remainingTime);
        } else if (state === Power.FullyCharged) {
            batteryPart = qsTr("Fully charged");
        } else {
            batteryPart = qsTr("Battery not charging or discharging");
        }
        return batteryPart + "\n" + qsTr("Screen brightness: %1%").arg(Power.screenBacklight);
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
                    hoverEnabled: true
                    icon {
                        source: "qrc:/icons/sun-solid.svg"
                        height: 16
                        width: 16
                    }

                    onClicked: Power.screenBacklight = 0;
                }

                Slider {
                    Layout.fillWidth: true
                    id: brightnessSlider
                    from: 0
                    to: 100
                    value: Power.screenBacklight
                    stepSize: 1
                    hoverEnabled: true
                    snapMode: Slider.SnapAlways
                    ToolTip.visible: hovered
                    ToolTip.text: "%1%".arg(value)
                    onMoved: Power.screenBacklight = value;
                }
            }
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
