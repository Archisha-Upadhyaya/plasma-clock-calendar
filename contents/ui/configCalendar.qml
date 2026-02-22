/*
    SPDX-FileCopyrightText: 2025 Archisha <archisha@example.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.calendar as PlasmaCalendar

Kirigami.ScrollablePage {
    id: page
    
    property alias cfg_showWeekNumbers: showWeekNumbersCheck.checked
    property int cfg_firstDayOfWeek: -1
    property var cfg_enabledCalendarPlugins: []

    PlasmaCalendar.EventPluginsManager {
        id: pluginsManager
    }

    Kirigami.FormLayout {
        CheckBox {
            id: showWeekNumbersCheck
            Kirigami.FormData.label: i18n("Calendar:")
            text: i18n("Show week numbers")
        }
        
        ComboBox {
            id: firstDayOfWeekCombo
            Kirigami.FormData.label: i18n("First day of week:")
            model: [
                i18n("Default"),
                i18n("Sunday"),
                i18n("Monday"),
                i18n("Tuesday"),
                i18n("Wednesday"),
                i18n("Thursday"),
                i18n("Friday"),
                i18n("Saturday")
            ]
            currentIndex: page.cfg_firstDayOfWeek + 1
            onActivated: page.cfg_firstDayOfWeek = index - 1
        }

        Label {
            Kirigami.FormData.label: i18n("Available Plugins:")
            text: i18n("Select plugins to show events from:")
            visible: pluginsManager.model.count > 0
        }

        Repeater {
            model: pluginsManager.model
            delegate: CheckBox {
                text: model.display
                checked: page.cfg_enabledCalendarPlugins.indexOf(model.pluginId) !== -1
                onToggled: {
                    var list = Array.from(page.cfg_enabledCalendarPlugins)
                    if (checked) {
                        if (list.indexOf(model.pluginId) === -1) list.push(model.pluginId)
                    } else {
                        var idx = list.indexOf(model.pluginId)
                        if (idx !== -1) list.splice(idx, 1)
                    }
                    page.cfg_enabledCalendarPlugins = list
                }
            }
        }
    }
}
