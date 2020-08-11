import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.fluke.Sound 1.0

ToolButton {
    id: indicatorSound
    font.weight: Font.DemiBold
    down: popup.visible
    hoverEnabled: true

    icon {
        source: indicatorIcon()
        height: 16
        width: 16
    }

    ToolTip.text: indicatorTooltip()
    ToolTip.visible: hovered && !popup.visible

    function indicatorIcon() {
        var vol = Sound.volume;
        var src = "";

        if (vol === 0 || Sound.muted) {
            src = "volume-mute";
        } else if (vol < 20.0) {
            src = "volume-off";
        } else if (vol < 50.0) {
            src = "volume-down";
        } else {
            src = "volume-up";
        }
        return "qrc:/icons/%1-solid.svg".arg(src);
    }

    function indicatorTooltip() {
        if (Sound.volume == 0 || Sound.muted) {
            return qsTr("Sound muted")
        } else {
            return qsTr("Volume: %1%").arg(Sound.volume)
        }
    }

    function toggleMute() {
        Sound.muted = !Sound.muted;
    }

    function increaseVolume() {
        Sound.volume = Math.min(Sound.volume + 1, 100);
    }

    function decreaseVolume() {
        Sound.volume = Math.max(Sound.volume - 1, 0);
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: {
            toggleMute();
        }
        onWheel: {
            wheel.angleDelta.y > 0 ? increaseVolume() : decreaseVolume();
            wheel.accepted = true;
        }
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
                    icon {
                        source: "qrc:/icons/volume-mute-solid.svg"
                        color: "red"
                        height: 16
                        width: 16
                    }

                    checkable: true
                    checked: Sound.muted
                    onToggled: toggleMute()
                    hoverEnabled: true
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Toggle mute")
                }

                Slider {
                    Layout.fillWidth: true
                    id: volumeSlider
                    from: 0
                    to: 100
                    live: false
                    enabled: !Sound.muted
                    opacity: enabled ? 1.0 : 0.5
                    value: Sound.volume
                    stepSize: 10
                    hoverEnabled: true
                    ToolTip.visible: hovered
                    ToolTip.text: "%1%".arg(Sound.volume)
                    wheelEnabled: true
                    onMoved: {
                        Sound.volume = valueAt(position);
                    }
                    Behavior on opacity { OpacityAnimator {} }
                }

                Binding { // special case for when the volume is muted -> 0
                    target: volumeSlider
                    property: "value"
                    value: 0
                    when: Sound.muted
                }
            }
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
