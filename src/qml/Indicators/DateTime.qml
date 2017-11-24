import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.calendar 1.0
import QtQuick.Controls.Material 2.2

ToolButton {
    id: indicatorDateTime
    font.weight: Font.DemiBold

    Timer {
        id: timer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: indicatorDateTime.text = (dateSwitch.checked ? Qt.formatDate(new Date(), Qt.DefaultLocaleLongDate) + ", " : "") +
                     (secondsSwitch.checked ? Qt.formatTime(new Date(), "h:mm:ss") : Qt.formatTime(new Date(), "h:mm"))
    }

    ToolTip.text: Qt.formatDate(new Date(), Qt.DefaultLocaleLongDate)
    ToolTip.visible: hovered && !popup.visible

    Popup {
        id: popup
        focus: visible
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        x: (parent.width - implicitWidth) / 2
        y: parent.height - parent.bottomPadding

        ColumnLayout {
            anchors.fill: parent

            // calendar navigation
            RowLayout {
                Layout.fillWidth: true
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                ToolButton {
                    id: btnPrevMonth
                    text: "\uf060"
                    onClicked: {
                        var nextMonth = new Date(calendar.year, calendar.month - 1);
                        calendar.month = nextMonth.getMonth();
                        calendar.year = nextMonth.getFullYear();
                    }
                }

                ToolButton {
                    Layout.fillWidth: true
                    text: calendar.title
                    onClicked: {
                        var today = new Date();
                        calendar.month = today.getMonth()
                        calendar.year = today.getFullYear()
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Go to today's date")
                }

                ToolButton {
                    id: btnNextMonth
                    text: "\uf061"
                    onClicked: {
                        var nextMonth = new Date(calendar.year, calendar.month + 1);
                        calendar.month = nextMonth.getMonth();
                        calendar.year = nextMonth.getFullYear();
                    }
                }
            }

            // calendar
            GridLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 2

                DayOfWeekRow {
                    Layout.column: 1
                    Layout.fillWidth: true
                    delegate: Label {
                        text: model.shortName
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                WeekNumberColumn {
                    Layout.fillHeight: true
                    month: calendar.month
                    year: calendar.year
                    delegate: Label {
                        text: model.weekNumber
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MonthGrid {
                    id: calendar
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    delegate: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: model.month === calendar.month ? 1 : 0.3
                        text: model.day
                        font.weight: (model.date.getDay() === 6 || model.date.getDay() === 0) ?
                                         Font.DemiBold : model.today ? Font.Bold : Font.Normal
                        color: model.today ? Material.accent : Material.foreground
                    }
                }
            }

            // settings
            Switch {
                id: dateSwitch
                text: qsTr("Display date in clock")
                onCheckedChanged: timer.restart()
            }

            Switch {
                id: secondsSwitch
                text: qsTr("Display seconds in clock")
                onCheckedChanged: timer.restart()
            }
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
