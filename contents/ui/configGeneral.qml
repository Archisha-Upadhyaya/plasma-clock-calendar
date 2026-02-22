/*
    SPDX-FileCopyrightText: 2025 Archisha <archishaupadhyaya10d@gmail.com>>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

Kirigami.ScrollablePage {
    id: page
    
    property alias cfg_showDate: showDateCheckBox.checked
    property alias cfg_dateDisplayFormat: dateDisplayFormatCombo.currentIndex
    property alias cfg_showSeconds: showSecondsCombo.currentIndex
    property alias cfg_use24hFormat: timeDisplayCombo.currentIndex
    property alias cfg_dateFormat: dateFormatCombo.currentValue
    property alias cfg_customDateFormat: customDateFormatField.text
    property alias cfg_autoFontAndSize: automaticRadio.checked

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18n("Information:")
            CheckBox {
                id: showDateCheckBox
                text: i18n("Show date")
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
                text: {
                    var date = new Date();
                    if (dateFormatCombo.currentValue === "custom") {
                        return Qt.formatDate(date, customDateFormatField.text);
                    } else if (dateFormatCombo.currentValue === "isoDate") {
                        return Qt.formatDate(date, Qt.ISODate);
                    } else if (dateFormatCombo.currentValue === "longDate") {
                        return Qt.formatDate(date, "dddd, MMMM d, yyyy");
                    } else {
                        return Qt.formatDate(date, Qt.DefaultLocaleShortDate);
                    }
                }
            }
        }

        Label {
            visible: dateFormatCombo.currentValue === "custom"
            text: i18n("Use: dd=day, MM=month, yyyy=year, MMM=month name")
            font.italic: true
            opacity: 0.7
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Text display:")
            spacing: 0
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
    }
}
