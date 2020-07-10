import QtQuick 2.12
import QtQuick.Controls 2.12

import org.fluke.TaskManager 1.0

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
        visible: contextMenu.visible && contextMenu.currentItem && contextMenu.currentItem.running
        onClicked: {
            Applications.stopApplication(contextMenu.currentItem.appId);
        }
    }

    onAboutToShow: {
        if (currentItem.running) {
            addItem(quitItem);
        } else {
            removeItem(contextMenu.contentChildren.length - 1);
        }
    }
}
