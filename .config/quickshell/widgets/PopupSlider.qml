import QtQuick
import Quickshell
import Quickshell.Widgets
import "../style/theme.js" as Theme

PopupWindow {
    id: root

    required property Item anchorItem
    required property var anchorWindow

    property string label: ""
    property string iconSource: ""
    property string iconText: ""
    property string valueText: ""
    property color accent: Theme.blue
    property real value: 0
    property bool sliderEnabled: true
    property int iconPixelSize: 16

    signal valueDragged(real value)

    color: "transparent"
    grabFocus: true

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight

    anchor.window: root.anchorWindow
    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide

    anchor.onAnchoring: {
        if (!root.anchorWindow || !root.anchorItem)
            return;

        const point = root.anchorWindow.mapFromItem(
            root.anchorItem,
            Math.round((root.anchorItem.width - root.implicitWidth) / 2),
            root.anchorItem.height + 8
        );

        anchor.rect.x = Math.round(point.x);
        anchor.rect.y = Math.round(point.y);
        anchor.rect.width = 1;
        anchor.rect.height = 1;
    }

    Rectangle {
        id: frame

        width: implicitWidth
        height: implicitHeight
        implicitWidth: 220
        implicitHeight: 74
        radius: 12
        color: Theme.surface0
        border.width: 1
        border.color: Theme.surface2

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Row {
                spacing: 8

                IconImage {
                    visible: root.iconText === ""
                    implicitSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    source: root.iconSource
                    opacity: root.sliderEnabled ? 1.0 : 0.65
                }

                Text {
                    visible: root.iconText !== ""
                    text: root.iconText
                    color: root.sliderEnabled ? Theme.text : Theme.overlay0
                    opacity: root.sliderEnabled ? 1.0 : 0.65
                    font.pixelSize: root.iconPixelSize
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.label
                    color: Theme.text
                    font.pixelSize: 12
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.valueText
                    color: root.sliderEnabled ? Theme.subtext1 : Theme.overlay0
                    font.pixelSize: 12
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: sliderArea

                width: parent.width
                height: implicitHeight
                implicitWidth: 196
                implicitHeight: 18
                opacity: root.sliderEnabled ? 1.0 : 0.5

                readonly property real clampedValue: Math.max(0, Math.min(1, root.value))
                readonly property real handleX: clampedValue * (width - handle.width)

                Rectangle {
                    id: track

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    radius: 999
                    color: Theme.surface2
                }

                Rectangle {
                    anchors.left: track.left
                    anchors.verticalCenter: track.verticalCenter
                    width: sliderArea.handleX + (handle.width / 2)
                    height: track.height
                    radius: track.radius
                    color: root.accent
                }

                Rectangle {
                    id: handle

                    width: 14
                    height: 14
                    radius: 999
                    x: sliderArea.handleX
                    y: Math.round((sliderArea.height - height) / 2)
                    color: Theme.text
                    border.width: 1
                    border.color: root.accent
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.sliderEnabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    function setValue(mouseX) {
                        const span = Math.max(1, sliderArea.width - handle.width);
                        const next = Math.max(0, Math.min(1, mouseX / span));
                        root.valueDragged(next);
                    }

                    onPressed: setValue(mouse.x - (handle.width / 2))
                    onPositionChanged: {
                        if (pressed)
                            setValue(mouse.x - (handle.width / 2));
                    }
                }
            }
        }
    }
}
