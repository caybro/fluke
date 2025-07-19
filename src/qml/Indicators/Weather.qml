import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtQml.XmlListModel

import QtPositioning

import org.fluke.TaskManager

ToolButton {
    id: root
    down: popup.visible
    hoverEnabled: true
    font.weight: Font.DemiBold

    icon.width: 32
    icon.height: 32

    Timer {
        id: timer
        interval: 60 * 1000 * 30 // 30 minutes
        running: true
        repeat: true
        onTriggered: updateWeather()
    }

    Component.onCompleted: Qt.callLater(posSource.update) // triggers updateWeather()

    BusyIndicator {
        anchors.fill: parent
        running: currentWeather.status === XmlListModel.Loading || currentWeather.status === XmlListModel.Null
        visible: running
    }

    function updateWeather() {
        if (posSource.valid) {
            currentWeather.source = "http://api.openweathermap.org/data/2.5/weather?lat=%1&lon=%2&appid=%3&units=%4&mode=xml&lang=%5"
            .arg(priv.lat).arg(priv.lon).arg(priv.owmKey)
            .arg(priv.imperialUnits ? "imperial" : "metric")
            .arg(Qt.locale().name)
            console.warn("!!! W API:", currentWeather.source)
            if (currentWeather.status !== XmlListModel.Loading) {
                currentWeather.reload();
            }
        }
    }

    PositionSource {
        id: posSource
        active: false

        onPositionChanged: {
            const coord = position.coordinate;
            if (coord.isValid && coord.latitude !== priv.lat && coord.longitude !== priv.lon) {
                priv.lat = coord.latitude;
                priv.lon = coord.longitude;
                console.warn("!!! POS CHANGED:", priv.lat, priv.lon)
                updateWeather();
            } else
                console.warn("!!! Acquired invalid position")
        }
    }

    QtObject {
        id: priv
        readonly property string owmKey: "6cb9a165bb3bf6147795a3dfab474b59"
        readonly property bool imperialUnits: Qt.locale().measurementSystem === Locale.ImperialUSSystem
        property double lat
        property double lon
    }

    XmlListModel {
        id: currentWeather
        query: "/current"

        XmlListModelRole { name: "city"; elementName: "city"; attributeName: "name" }
        XmlListModelRole { name: "country"; elementName: "city/country" }
        XmlListModelRole { name: "temperature"; elementName: "temperature"; attributeName: "value" }
        XmlListModelRole { name: "weatherInfo"; elementName: "weather"; attributeName: "value" }
        XmlListModelRole { name: "humidity"; elementName: "humidity"; attributeName: "value" }
        XmlListModelRole { name: "precipitation"; elementName: "precipitation"; attributeName: "mode" }
        XmlListModelRole { name: "wind"; elementName: "wind/speed"; attributeName: "name" }
        XmlListModelRole { name: "iconID"; elementName: "weather"; attributeName: "icon" }

        onStatusChanged: {
            if (status === XmlListModel.Ready && count > 0) {
                var result = ModelUtils.get(currentWeather, 0);
                var temperature = Math.round(result.temperature);

                root.icon.source = "http://openweathermap.org/img/wn/%1@2x.png".arg(result.iconID);

                root.text = qsTr("%1° %2").arg(temperature).arg(priv.imperialUnits ? "F" : "C")

                weather.append(qsTr("Info: %1").arg(result.weatherInfo));
                weather.append(qsTr("Temperature: %1 °%2").arg(temperature).arg(priv.imperialUnits ? "F" : "C"));
                weather.append(qsTr("Humidity: %1 %").arg(result.humidity));
                weather.append(qsTr("Precipitation: %1").arg(result.precipitation));
                weather.append(qsTr("Wind: %1").arg(result.wind));
                weather.append(qsTr("Location: %1, %2").arg(result.city).arg(result.country));
            } else if (status === XmlListModel.Error) {
                console.error("Weather model error:", errorString());
                root.text = "?";
                weather.text = qsTr("Error getting weather info\n%1").arg(errorString());
            }
        }
    }

    Popup {
        id: popup
        focus: visible
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        x: (parent.width - implicitWidth) / 2
        y: parent.height

        ColumnLayout {
            anchors.fill: parent

            // weather
            TextArea {
                Layout.fillWidth: true
                Layout.topMargin: 8
                id: weather
                readOnly: true
                background: null
            }
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
