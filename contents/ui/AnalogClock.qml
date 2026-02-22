import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

ColumnLayout {
    id: root
    required property date currentTime
    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
    Layout.preferredHeight: Kirigami.Units.gridUnit * 14
    Layout.minimumWidth: Kirigami.Units.gridUnit * 15
    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents.Label {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        text: Qt.formatDate(root.currentTime, "dddd, d MMMM yyyy")
        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.3
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignHCenter
        color: Kirigami.Theme.textColor
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Canvas {
            id: clockCanvas
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.95
            height: width
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var centerX = width / 2;
                var centerY = height / 2;
                var radius = width / 2 - 5;

                // Background
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                ctx.fillStyle = Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.3);
                ctx.fill();
                ctx.lineWidth = 2;
                ctx.strokeStyle = Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2);
                ctx.stroke();

                // Ticks
                for (var i = 0; i < 60; i++) {
                    var angle = (i * 6) * (Math.PI / 180);
                    var isHour = i % 5 === 0;
                    var length = isHour ? radius * 0.15 : radius * 0.05;
                    var startRadius = radius - length;
                    var x1 = centerX + Math.cos(angle) * startRadius;
                    var y1 = centerY + Math.sin(angle) * startRadius;
                    var x2 = centerX + Math.cos(angle) * (radius - 2);
                    var y2 = centerY + Math.sin(angle) * (radius - 2);
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.lineWidth = isHour ? 2 : 1;
                    ctx.strokeStyle = isHour ? Kirigami.Theme.textColor : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.5);
                    ctx.stroke();
                }

                // Hands
                var now = new Date();
                var hours = now.getHours() % 12;
                var minutes = now.getMinutes();
                var seconds = now.getSeconds();

                var hourAngle = ((hours + minutes / 60) * 30 - 90) * (Math.PI / 180);
                drawHand(ctx, centerX, centerY, hourAngle, radius * 0.5, 4, Kirigami.Theme.highlightColor);

                var minuteAngle = ((minutes + seconds / 60) * 6 - 90) * (Math.PI / 180);
                drawHand(ctx, centerX, centerY, minuteAngle, radius * 0.7, 3, Kirigami.Theme.highlightColor);

                var secondAngle = (seconds * 6 - 90) * (Math.PI / 180);
                drawHand(ctx, centerX, centerY, secondAngle, radius * 0.8, 1, Kirigami.Theme.highlightColor);

                ctx.beginPath();
                ctx.arc(centerX, centerY, 4, 0, 2 * Math.PI);
                ctx.fillStyle = Kirigami.Theme.highlightColor;
                ctx.fill();
            }
            function drawHand(ctx, x, y, angle, length, width, color) {
                ctx.beginPath();
                ctx.lineWidth = width;
                ctx.lineCap = "round";
                ctx.strokeStyle = color;
                ctx.moveTo(x, y);
                ctx.lineTo(x + Math.cos(angle) * length, y + Math.sin(angle) * length);
                ctx.stroke();
            }
        }
        Timer {
            interval: 1000; running: root.visible; repeat: true
            onTriggered: clockCanvas.requestPaint()
        }
        Component.onCompleted: clockCanvas.requestPaint()
    }
}
