import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.calendar 1.0
import QtQuick.Controls.Material 2.3
import QtQuick.XmlListModel 2.0

import org.fluke.Session 1.0

ToolButton {
    id: root
    //font.weight: Font.DemiBold
    down: popup.visible
    text: "?"

    icon.width: 16
    icon.height: 16

    contentItem: Label { // get rid of the stupid UPPERCASE text :/
        text: root.text
        font: root.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Connections {
        target: GeoLocation
        onLocationUpdated: {
            if (GeoLocation.isValid) {
                console.info("!!! Current GeoLocation:", GeoLocation.latitude, GeoLocation.longitude)
                priv.lat = GeoLocation.latitude;
                priv.lon = GeoLocation.longitude;
                currentWeather.source = "http://api.openweathermap.org/data/2.5/weather?lat=%1&lon=%2&appid=%3&units=metric&mode=xml"
                .arg(priv.lat).arg(priv.lon).arg(priv.owmKey);
            }
        }
    }

    QtObject {
        id: priv
        readonly property string owmKey: "6cb9a165bb3bf6147795a3dfab474b59"
        property real lat
        property real lon
    }

    XmlListModel {
        id: currentWeather

        //source: "http://api.openweathermap.org/data/2.5/weather?q=Olomouc,cz&appid=%1&units=metric&mode=xml".arg(priv.owmKey)
        query: "/current"

        XmlRole { name: "city"; query: "city/@name/string()" }
        XmlRole { name: "country"; query: "city/country/string()" }
        XmlRole { name: "temperature"; query: "temperature/@value/string()" }
        XmlRole { name: "weatherInfo"; query: "weather/@value/string()" }
        XmlRole { name: "humidity"; query: "humidity/@value/string()" }
        XmlRole { name: "precipitation"; query: "precipitation/@mode/string()" }
        XmlRole { name: "wind"; query: "wind/speed/@name/string()" }
        XmlRole { name: "iconID"; query: "weather/@icon/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready && count > 0) {
                var result = get(0);
                var temperature = Math.round(result.temperature);

                root.icon.source = "http://openweathermap.org/img/w/%1.png".arg(result.iconID);
                console.info("!!! ICON:", root.icon.source)

                root.text = qsTr("%1°C (%2)").arg(temperature).arg(result.weatherInfo);

                weather.text = qsTr("Weather: %1 °C").arg(temperature);
                weather.append(qsTr("Humidity: %1%").arg(result.humidity));
                weather.append(qsTr("Precipitation: %1").arg(result.precipitation));
                weather.append(qsTr("Wind: %1").arg(result.wind));
                weather.append("%1, %2".arg(result.city).arg(result.country));
            } else if (status === XmlListModel.Error) {
                console.error("Weather model error:", errorString())
                root.text = "?";
                weather.text = qsTr("Error getting weather info\n%1").arg(errorString())
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
            TextEdit {
                id: weather
                readOnly: true
                color: Material.foreground
            }
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
