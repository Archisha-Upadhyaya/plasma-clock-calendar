/*
    SPDX-FileCopyrightText: 2025 Archisha <archisha@example.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page
    
    property alias cfg_showDate: showDateCheckBox.checked
    property alias cfg_dateDisplayFormat: dateDisplayFormatCombo.currentIndex
    property alias cfg_showSeconds: showSecondsCombo.currentIndex
    property alias cfg_showLocalTimezone: showLocalTimezoneCheck.checked
    property alias cfg_displayTimezoneFormat: displayTimezoneFormatCombo.currentIndex
    property alias cfg_use24hFormat: timeDisplayCombo.currentIndex
    property alias cfg_dateFormat: dateFormatCombo.currentValue
    property alias cfg_customDateFormat: customDateFormatField.text
    property alias cfg_autoFontAndSize: automaticRadio.checked
    property alias cfg_wheelChangesTimezone: wheelChangesTimezoneCheck.checked

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18n("About:")
            Label {
                text: i18n("Enhanced Analog Clock - Custom version with dual-mode display and calendar integration")
                wrapMode: Text.WordWrap
            }
        }
            ComboBox {
                id: dateDisplayFormatCombo
                enabled: showDateCheckBox.checked
                model: [
                    i18n("Adaptive location"),
                    i18n("Beside time"),
                    i18n("Below time")
                ]
            }
        }

        ComboBox {
            id: showSecondsCombo
            Kirigami.FormData.label: i18n("Show seconds:")
            model: [
                i18n("Never"),
                i18n("Only in the tooltip"),
                i18n("Always")
            ]
        }

        ComboBox {
            id: displayTimezoneFormatCombo
            Kirigami.FormData.label: i18n("Display time zone as:")
            model: [
                i18n("Code (GMT)"),
                i18n("Full text (London)"),
                i18n("UTC offset (+1)")
            ]
        }
                model: [
                    i18n("Code"),
                    i18n("Full text"),
                    i18n("UTC offset")
                ]
            }
            Button {
                text: i18n("Switch Time Zone...")
                icon.name: "globe"
                onClicked: KCM.KCMLauncher.openSystemSettings("kcm_clock")
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Time display:")
            ComboBox {
                id: timeDisplayCombo
                model: [
                    i18n("Use region defaults"),
                    i18n("12-hour"),
                    i18n("24-hour")
                ]
            }
            Button {
                text: i18n("Change Regional Settings...")
                icon.name: "preferences-desktop-locale"
                onClicked: KCM.KCMLauncher.openSystemSettings("kcm_regionandlang")
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Date format:")
            ComboBox {
                id: dateFormatCombo
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: i18n("Short date"), value: "shortDate" },
                    { text: i18n("Long date"), value: "longDate" },
                    { text: i18n("ISO date"), value: "isoDate" },
                    { text: i18n("Custom"), value: "custom" }
                ]
            }
            TextField {
                id: customDateFormatField
                visible: dateFormatCombo.currentValue === "custom"
                placeholderText: i18n("Custom format string")
            }
            Label {
                visible: dateFormatCombo.currentValue === "custom"
                text: i18n("Use: dd=day, MM=month, yyyy=year, MMM=month name")
                font.italic: true
                opacity: 0.7
            }
            Label {
                text: {
                    var date = new Date();
                    if (dateFormatCombo.currentValue === "custom") {
                        return Qt.formatDate(date, customDateFormatField.text);
                    } else if (dateFormatCombo.currentValue === "isoDate") {
                        return Qt.formatDate(date, Qt.ISODate);
                    } else if (dateFormatCombo.currentValue === "longDate") {
                        return Qt.formatDate(date, Qt.DefaultLocaleLongDate);
                    } else {
                        return Qt.formatDate(date, Qt.DefaultLocaleShortDate);
                    }
                }
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Text display:")
            ButtonGroup {
                id: autoFontAndSizeGroup
            }
            RadioButton {
                id: automaticRadio
                text: i18n("Automatic")
                ButtonGroup.group: autoFontAndSizeGroup
            }
            Label {
                text: i18n("Text will follow the system font and expand to fill the available space.")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                Layout.leftMargin: Kirigami.Units.largeSpacing * 2
                visible: automaticRadio.checked
            }
            RowLayout {
                RadioButton {
                    text: i18n("Manual")
                    ButtonGroup.group: autoFontAndSizeGroup
                    checked: !automaticRadio.checked
                }
                Button {
                    text: i18n("Choose Style...")
                    icon.name: "preferences-desktop-font"
                    enabled: !automaticRadio.checked
                }
            }
        }

        CheckBox {
            id: wheelChangesTimezoneCheck
            Kirigami.FormData.label: i18n("Mouse wheel:")
            text: i18n("Use mouse wheel to switch time zones")
            property alias cfg_wheelChangesTimezone: wheelChangesTimezoneCheck.checked
        }

        ComboBox {
            id: displayTimezoneFormatCombo
            Kirigami.FormData.label: i18n("Timezone display:")
            model: [
                i18n("Code (GMT)"),
                i18n("Full text (London)"),
                i18n("UTC offset (+1)")
            ]
            property alias cfg_displayTimezoneFormat: displayTimezoneFormatCombo.currentIndex
        }

        CheckBox {
            id: showLocalTimezoneCheck
            text: i18n("Show local timezone")
            property alias cfg_showLocalTimezone: showLocalTimezoneCheck.checked
        }
    }
}
