import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    id: root

    property bool appLauncherVisible
    property string fullscreenAppId

    signal activated(string appId)
    signal minimized(string appId)
    signal fullscreen(string appId)
    signal exitFullscreen(string appId)
    signal activateView(var view)

    signal changeWallpaper(url fileUrl)
    signal showLauncher()
    signal logout()

    onFullscreen: {
        if (appId) {
            fullscreenAppId = appId;
        }
    }
    onExitFullscreen: {
        if (fullscreenAppId == appId) {
            fullscreenAppId = "";
        }
    }

    ContextMenu.menu: Menu {
        MenuItem {
            icon.source: "qrc:/icons/material/wallpaper-24px.svg"
            text: qsTr("Select Wallpaper...")
            onTriggered: wallpaperDialog.open()
        }

        MenuItem {
            icon.source: "qrc:/icons/material/apps-24px.svg"
            text: qsTr("Open Launcher")
            onTriggered: root.showLauncher()
        }
        MenuItem {
            icon.source: "qrc:/icons/material/logout-24px.svg"
            text: qsTr("Logout...")
            onTriggered: root.logout()
        }
    }

    FileDialog {
        id: wallpaperDialog
        currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        title: qsTr("Change Wallpaper")
        nameFilters: [qsTr("Image files (*.jpg *.png *.jpeg)")]
        onAccepted: root.changeWallpaper(selectedFile)
    }
}
