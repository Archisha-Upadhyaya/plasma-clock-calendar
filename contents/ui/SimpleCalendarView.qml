import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.calendar as PlasmaCalendar
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: calendar
    property var appletInterface: null
    property date today: new Date()
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: Kirigami.Units.gridUnit * 22
    Layout.minimumHeight: Kirigami.Units.gridUnit * 22

    PlasmaCalendar.EventPluginsManager {
        id: eventPluginsManager
        enabledPlugins: Plasmoid.configuration.enabledCalendarPlugins
    }

    PlasmaCalendar.MonthView {
        id: monthView
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        borderOpacity: 0.25
        eventPluginsManager: eventPluginsManager
        today: calendar.today
        showWeekNumbers: Plasmoid.configuration.showWeekNumbers
        onCurrentDateChanged: eventsPopup.updateEvents()
        
        readonly property var appletInterface: calendar.appletInterface
    }

    QQC2.Popup {
        id: eventsPopup
        modal: true
        focus: true
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside
        anchors.centerIn: parent
        width: Kirigami.Units.gridUnit * 22
        height: Kirigami.Units.gridUnit * 20
        
        property var currentEvents: []

        function updateEvents() {
            currentEvents = monthView.daysModel.eventsForDate(monthView.currentDate)
        }
        function show() {
            updateEvents()
            open()
        }
        function hide() {
            close()
        }

        background: Rectangle {
            color: "#cc1B1F29"
            border.color: Kirigami.Theme.highlightColor
            border.width: 1
            radius: 5
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing
            
            RowLayout {
                Layout.fillWidth: true
                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 3
                    text: monthView.currentDate.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                    color: "#ffffff"
                    elide: Text.ElideRight
                }
                QQC2.ToolButton {
                    icon.name: "window-close"
                    onClicked: eventsPopup.hide()
                }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#3a3a3a" }
            
            QQC2.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ListView {
                    id: eventsList
                    model: eventsPopup.currentEvents
                    spacing: Kirigami.Units.smallSpacing
                    clip: true
                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: eventContent.implicitHeight + Kirigami.Units.largeSpacing
                        radius: Kirigami.Units.smallSpacing
                        color: "#1B1F29"
                        border.color: "#3a3a3a"
                        border.width: 1
                        RowLayout {
                            id: eventContent
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            spacing: Kirigami.Units.smallSpacing
                            Rectangle {
                                Layout.preferredWidth: 4
                                Layout.fillHeight: true
                                color: parent.parent.modelData.eventColor || "#4a90d9"
                                radius: 2
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                PlasmaComponents.Label {
                                    Layout.fillWidth: true
                                    text: parent.parent.parent.modelData.title
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
                PlasmaExtras.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.gridUnit * 4
                    visible: eventsList.count === 0
                    iconName: "checkmark"
                    text: "No events for this day"
                }
            }
        }
    }

    QQC2.Button {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.largeSpacing
        z: 500
        text: "Events"
        icon.name: "view-calendar-day"
        visible: monthView.daysModel.eventsForDate(monthView.currentDate).length > 0
        onClicked: eventsPopup.show()
    }
}
