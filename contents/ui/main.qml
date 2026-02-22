/*
    SPDX-FileCopyrightText: 2012 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.workspace.calendar 2.0 as PlasmaCalendar

PlasmoidItem {
    id: analogclock

    width: Kirigami.Units.gridUnit * 15
    height: Kirigami.Units.gridUnit * 15

    readonly property string currentTime: Qt.locale().toString(dataSource.data["Local"]["DateTime"], showSeconds !== 0 ? Qt.locale().timeFormat(Locale.LongFormat) : Qt.locale().timeFormat(Locale.ShortFormat))
    readonly property string currentDate: Qt.locale().toString(dataSource.data["Local"]["DateTime"], Qt.locale().dateFormat(Locale.LongFormat).replace(/(^dddd.?\s)|(,?\sdddd$)/, ""))
    property int hours
    property int minutes
    property int seconds
    property int showSeconds: Plasmoid.configuration.showSeconds
    property bool showTimezone: Plasmoid.configuration.showLocalTimezone
    property int tzOffset
    property date currentDateTime: new Date()

    Plasmoid.backgroundHints: "NoBackground";
    preferredRepresentation: compactRepresentation

    toolTipMainText: Qt.locale().toString(dataSource.data["Local"]["DateTime"],"dddd")
    toolTipSubText: `${currentTime}\n${currentDate}`


    function dateTimeChanged() {
        var currentTZOffset = dataSource.data["Local"]["Offset"] / 60;
        if (currentTZOffset !== tzOffset) {
            tzOffset = currentTZOffset;
            Date.timeZoneUpdated(); // inform the QML JS engine about TZ change
        }
    }

    P5Support.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: "Local"
        interval: (showSeconds === 2) || (analogclock.compactRepresentationItem && analogclock.compactRepresentationItem.containsMouse) ? 1000 : 30000
        onDataChanged: {
            var date = new Date(data["Local"]["DateTime"]);
            analogclock.currentDateTime = date;
            hours = date.getHours();
            minutes = date.getMinutes();
            seconds = date.getSeconds();
        }
        Component.onCompleted: {
            dataChanged();
        }
    }

    compactRepresentation: Item {
        id: representation
        Layout.minimumWidth: mainLayout.implicitWidth
        Layout.minimumHeight: mainLayout.implicitHeight
        
        implicitWidth: mainLayout.implicitWidth > 0 ? mainLayout.implicitWidth : Kirigami.Units.gridUnit * 10
        implicitHeight: mainLayout.implicitHeight > 0 ? mainLayout.implicitHeight : Kirigami.Units.gridUnit * 3

        property bool wasExpanded
        
        MouseArea {
            anchors.fill: parent
            activeFocusOnTab: true
            hoverEnabled: true
            
            onPressed: representation.wasExpanded = analogclock.expanded
            onClicked: analogclock.expanded = !representation.wasExpanded
        }

        ColumnLayout {
            id: mainLayout
            anchors.centerIn: parent
            spacing: 0

            PlasmaComponents.Label {
                id: timeLabel
                Layout.alignment: Qt.AlignHCenter
                
                property int timeTrigger: 0
                
                text: {
                    var t = timeTrigger; // dependency
                    var format = "hh:mm";
                    if (Plasmoid.configuration.use24hFormat === 1) { // 12-hour
                        format = "h:mm AP";
                    } else if (Plasmoid.configuration.use24hFormat === 2) { // 24-hour
                        format = "hh:mm";
                    } else {
                        format = Qt.locale().timeFormat(Locale.ShortFormat);
                    }

                    if (Plasmoid.configuration.showSeconds === 2) {
                        // This is a bit hacky for locale formats, but works for simple cases
                        if (format.indexOf("ss") === -1) {
                             if (format.indexOf("AP") !== -1 || format.indexOf("ap") !== -1) {
                                 format = format.replace(" ", ":ss ");
                             } else {
                                 format += ":ss";
                             }
                        }
                    }
                    return Qt.formatTime(new Date(), format);
                }
                
                fontSizeMode: Text.Fit
                minimumPixelSize: Kirigami.Theme.defaultFont.pixelSize
                font.pixelSize: 72 // Max size
                
                Layout.preferredWidth: representation.width
                Layout.preferredHeight: representation.height * 0.7
                
                font.bold: Plasmoid.configuration.boldText
                font.italic: Plasmoid.configuration.italicText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            PlasmaComponents.Label {
                id: dateLabel
                visible: Plasmoid.configuration.showDate
                Layout.alignment: Qt.AlignHCenter
                
                property int dateTrigger: timeLabel.timeTrigger
                
                text: {
                    var t = dateTrigger;
                    var date = new Date();
                    if (Plasmoid.configuration.dateFormat === "custom") {
                        return Qt.formatDate(date, Plasmoid.configuration.customDateFormat);
                    } else if (Plasmoid.configuration.dateFormat === "isoDate") {
                        return Qt.formatDate(date, Qt.ISODate);
                    } else if (Plasmoid.configuration.dateFormat === "longDate") {
                        return Qt.formatDate(date, Qt.DefaultLocaleLongDate);
                    } else {
                        return Qt.formatDate(date, Qt.DefaultLocaleShortDate);
                    }
                }
                
                fontSizeMode: Text.Fit
                minimumPixelSize: Kirigami.Theme.smallFont.pixelSize
                font.pixelSize: 36
                
                Layout.preferredWidth: representation.width
                Layout.preferredHeight: representation.height * 0.3
                
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: timeLabel.timeTrigger++
        }
    }

    fullRepresentation: RowLayout {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 44
        Layout.preferredHeight: Kirigami.Units.gridUnit * 26
        Layout.minimumWidth: Kirigami.Units.gridUnit * 42
        Layout.minimumHeight: Kirigami.Units.gridUnit * 22
        Layout.maximumWidth: Kirigami.Units.gridUnit * 60
        Layout.maximumHeight: Kirigami.Units.gridUnit * 30
        spacing: Kirigami.Units.largeSpacing

        AnalogClock {
            currentTime: analogclock.currentDateTime
            Layout.preferredWidth: Kirigami.Units.gridUnit * 18
            Layout.minimumWidth: Kirigami.Units.gridUnit * 15
            Layout.fillHeight: true
        }

        SimpleCalendarView {
            id: calendar
            Layout.preferredWidth: Kirigami.Units.gridUnit * 24
            Layout.minimumWidth: Kirigami.Units.gridUnit * 22
            Layout.fillHeight: true
            appletInterface: analogclock
            today: analogclock.currentDateTime
        }
    }

    Component.onCompleted: {
        tzOffset = new Date().getTimezoneOffset();
        dataSource.onDataChanged.connect(dateTimeChanged);
    }
}
