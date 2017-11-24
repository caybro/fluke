import QtQuick 2.9

Item {
    id: workspace

    property bool appLauncherVisible
    property string fullscreenAppId
    
    signal activated(string appId)
    signal minimized(string appId)
    signal fullscreen(string appId)
    signal exitFullscreen(string appId)
    
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
}
