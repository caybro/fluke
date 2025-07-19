import QtQuick
import QtQuick.Controls

import org.fluke.TaskManager

Menu {
    id: contextMenu
    property var currentItem: null

    parent: currentItem ? currentItem : null
    y: currentItem ? currentItem.height : 0

    MenuItem {
        visible: contextMenu.currentItem
        text: qsTr("Favorite", "favorite application")
        checkable: true
        checked: contextMenu.currentItem && contextMenu.currentItem.favorite
        onClicked: {
            Applications.setApplicationFavorite(contextMenu.currentItem.appId, !contextMenu.currentItem.favorite)
        }
    }

    MenuItem {
        id: quitItem
        text: qsTr("Quit")
        enabled: contextMenu.visible && contextMenu.currentItem && contextMenu.currentItem.running
        //height: visible ? implicitHeight : 0
        onClicked: {
            Applications.stopApplication(contextMenu.currentItem.appId);
        }
    }

    // FIXME hide disabled items?
    // onAboutToShow: {
    //     if (currentItem.running) {
    //         addItem(quitItem);
    //     } else {
    //         removeItem(contextMenu.contentChildren.length - 1);
    //     }
    // }
}
