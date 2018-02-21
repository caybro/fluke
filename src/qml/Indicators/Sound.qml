import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.fluke.Sound 1.0

ToolButton {
    id: indicatorSound
    text: indicatorCaption()
    font.weight: Font.DemiBold

    ToolTip.text: indicatorTooltip()
    ToolTip.visible: hovered && !popup.visible

    function indicatorCaption() {
        var value = Sound.volume;

        if (value == 0 || Sound.muted) {
            return "<font color='#F44336'>\uf026</font>";
        } else if (value < 50) {
            return "\uf027";
        } else {
            return "\uf028";
        }
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
        y: parent.height - parent.bottomPadding
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right

                ToolButton {
                    text: "<font color='#F44336'>\uf026</font>"
                    checkable: true
                    checked: Sound.muted
                    onToggled: toggleMute()
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
                    ToolTip.visible: hovered
                    ToolTip.text: "%1%".arg(Sound.volume)
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
