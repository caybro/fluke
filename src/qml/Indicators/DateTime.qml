import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

ToolButton {
    id: indicatorDateTime
    font.weight: Font.DemiBold
    down: popup.visible
    hoverEnabled: true

    property bool showDate: false
    property bool showSeconds: false

    Timer {
        id: timer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            indicatorDateTime.text = (dateSwitch.checked ? Qt.formatDate(new Date(), Qt.locale(), Locale.NarrowFormat) + ", " : "") +
                    (secondsSwitch.checked ? Qt.formatTime(new Date(), "h:mm:ss") : Qt.formatTime(new Date(), "h:mm"));
            longDateLabel.text = Qt.formatDate(new Date(), Qt.locale(), Locale.LongFormat);
        }
    }

    ToolTip.text: Qt.formatDate(new Date(), Qt.locale(), Locale.LongFormat)
    ToolTip.visible: hovered && !popup.visible

    Popup {
        id: popup
        focus: visible
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        x: (parent.width - implicitWidth) / 2
        y: parent.height

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.alignment: Qt.AlignHCenter
                id: longDateLabel
                font.pixelSize: 16
                visible: !dateSwitch.checked
            }

            // calendar navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                ToolButton {
                    id: btnPrevMonth
                    icon.source: "qrc:/icons/material/chevron_left-24px.svg"
                    hoverEnabled: true
                    onClicked: {
                        var prevMonth = new Date(calendar.year, calendar.month - 1);
                        calendar.month = prevMonth.getMonth();
                        calendar.year = prevMonth.getFullYear();
                    }
                }

                ToolButton {
                    Layout.fillWidth: true
                    text: calendar.title
                    onClicked: {
                        var today = new Date();
                        calendar.month = today.getMonth();
                        calendar.year = today.getFullYear();
                    }
                    hoverEnabled: true
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Go to today's date")
                }

                ToolButton {
                    id: btnNextMonth
                    icon.source: "qrc:/icons/material/chevron_right-24px.svg"
                    hoverEnabled: true
                    onClicked: {
                        var nextMonth = new Date(calendar.year, calendar.month + 1);
                        calendar.month = nextMonth.getMonth();
                        calendar.year = nextMonth.getFullYear();
                    }
                }
            }

            // calendar
            GridLayout {
                Layout.fillWidth: true
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
                checked: indicatorDateTime.showDate
                onToggled: {
                    indicatorDateTime.showDate = checked;
                    timer.restart();
                }
            }

            Switch {
                id: secondsSwitch
                text: qsTr("Display seconds in clock")
                checked: indicatorDateTime.showSeconds
                onToggled: {
                    indicatorDateTime.showSeconds = checked;
                    timer.restart();
                }
            }
        }
    }

    onClicked: {
        popup.visible = !popup.visible;
    }
}
