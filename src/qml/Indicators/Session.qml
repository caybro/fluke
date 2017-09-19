import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.fluke.Session 1.0

ToolButton {
    id: indicatorSession
    hoverEnabled: true
    text: "\uf013"

    ToolTip.text: qsTr("Session")
    ToolTip.visible: hovered && (!popupLoader.item || !popupLoader.item.visible)

    signal logout()
    signal suspend()
    signal reboot()
    signal shutdown()

    Loader {
        id: popupLoader
        active: false
        focus: visible
        y: parent.height

        sourceComponent: Menu {
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            MenuItem {
                text: "\uf137\t" + qsTr("Logout")
                onClicked: indicatorSession.logout()
            }

            MenuItem {
                text: "\uf236\t" + qsTr("Sleep")
                onClicked: indicatorSession.suspend()
                enabled: Session.canSuspend()
            }

            MenuItem {
                text: "\uf021\t" + qsTr("Reboot")
                onClicked: indicatorSession.reboot()
                enabled: Session.canReboot()
            }

            MenuItem {
                text: "\uf011\t" + qsTr("Shutdown")
                onClicked: indicatorSession.shutdown()
                enabled: Session.canShutdown()
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
