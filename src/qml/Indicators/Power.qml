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
        width: 18
        height: 18
    }
    text: indicatorCaption()

    ToolTip.text: indicatorTooltip()
    ToolTip.visible: Power.isPresent && hovered && !popup.visible

    function indicatorIcon() {
        const charge = Power.percentage;
        const charging = Power.state === Power.Charging;
        var src = "";

        if (Power.state === Power.Unknown)
            src = "unknown"
        else if (Power.state === Power.Empty || charge < 10)
            src = "alert"
        else if (charge < 20)
            src = "20";
        else if (charge < 30)
            src = "30";
        else if (charge < 50)
            src = "50";
        else if (charge < 60)
            src = "60";
        else if (charge < 80)
            src = "80";
        else if (charge < 90)
            src = "90";
        else
            src = "full";

        var result = "qrc:/icons/battery/ic_battery%1_%2_18px.svg".arg(charging ? "_charging" : "").arg(src);
        return result;
    }

    function indicatorCaption() {
        const state = Power.state;
        const perc = state === Power.FullyCharged ? 100.0 : Power.percentage;

        var result = "%1%".arg(Math.floor(perc)); // we're being a bit pessimistic here ;)
        if ((state === Power.Charging || state === Power.Discharging) && perc !== 100) {
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
                Layout.fillWidth: true

                ToolButton {
                    hoverEnabled: true
                    icon {
                        height: 16
                        width: 16
                        source: "qrc:/icons/material/brightness_low-24px.svg"
                    }

                    onClicked: {
                        brightnessSlider.value = 0;
                        Power.screenBacklight = 0;
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    id: brightnessSlider
                    from: 0
                    to: 100
                    stepSize: 5
                    hoverEnabled: true
                    wheelEnabled: true
                    snapMode: Slider.SnapAlways
                    ToolTip.visible: hovered
                    ToolTip.text: "%1%".arg(value)
                    onMoved: Power.screenBacklight = value;
                }
            }
        }
    }

    onClicked: {
        brightnessSlider.value = Power.screenBacklight; // not a binding due to async value coming from DBUS and never signalling its change
        popup.visible = !popup.visible;
    }
}
