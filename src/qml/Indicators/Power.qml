import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.fluke.Power 1.0

ToolButton {
    id: indicatorPower
    font.pointSize: 12
    hoverEnabled: true
    text: indicatorCaption()

    ToolTip.text: indicatorTooltip()
    ToolTip.visible: Power.isPresent && hovered /*&& (!popupLoader.item || !popupLoader.item.visible)*/

//    Connections {
//        target: Power
//        onPercentageChanged: {
//            indicatorPower.text = indicatorCaption();
//        }
//    }

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

//    Loader {
//        id: popupLoader
//        active: false
//        focus: visible
//        y: parent.height

//        sourceComponent: Menu {
//            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

//            MenuItem {
//                text: "\uf137\t" + qsTr("Logout")
//                onClicked: indicatorSession.logout()
//            }

//            MenuItem {
//                text: "\uf236\t" + qsTr("Sleep")
//                onClicked: indicatorSession.suspend()
//                enabled: Session.canSuspend()
//            }

//            MenuItem {
//                text: "\uf021\t" + qsTr("Reboot")
//                onClicked: indicatorSession.reboot()
//                enabled: Session.canReboot()
//            }

//            MenuItem {
//                text: "\uf011\t" + qsTr("Shutdown")
//                onClicked: indicatorSession.shutdown()
//                enabled: Session.canShutdown()
//            }
//        }
//    }

//    onClicked: {
//        if (!popupLoader.item) {
//            popupLoader.active = true;
//        }

//        if (popupLoader.item.visible) {
//            popupLoader.item.close();
//        } else {
//            popupLoader.item.open();
//        }
//    }
}
