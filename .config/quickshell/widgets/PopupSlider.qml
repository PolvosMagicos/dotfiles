pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import ".." as Config
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
    property bool open: false
    property bool mounted: false

    // Pass sinkLinks.linkGroups here.
    property var streamModel: null
    property var outputModel: null
    property var selectedOutput: null

    signal valueDragged(real value)
    signal dismissed()
    signal sliderInteracted()
    signal outputSelected(var node)

    color: "transparent"
    grabFocus: true
    visible: root.mounted

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight

    anchor.window: root.anchorWindow
    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide

    anchor.onAnchoring: {
        if (!root.anchorWindow || !root.anchorItem)
            return;

        const anchorWidth = root.anchorItem.width > 0 ? root.anchorItem.width : root.anchorItem.implicitWidth;
        const anchorHeight = root.anchorItem.height > 0 ? root.anchorItem.height : root.anchorItem.implicitHeight;
        const popupWidth = root.implicitWidth > 0 ? root.implicitWidth : frame.implicitWidth;
        const point = root.anchorWindow.mapFromItem(root.anchorItem, Math.round((anchorWidth - popupWidth) / 2), anchorHeight + 8);

        anchor.rect.x = Math.round(point.x);
        anchor.rect.y = Math.round(point.y);
        anchor.rect.width = 1;
        anchor.rect.height = 1;
    }

    function clamp01(value) {
        return Math.max(0, Math.min(1, value));
    }

    function percentText(value) {
        return `${Math.round(value * 100)}%`;
    }

    function streamName(node) {
        if (!node)
            return "Unknown app";

        const props = node.properties || {};

        const app = props["application.name"] || node.description || node.nickname || node.name || "Unknown app";

        const media = props["media.name"] || props["media.title"] || "";

        if (media !== "" && media !== app)
            return `${app} · ${media}`;

        return app;
    }

    function streamIcon(node) {
        if (!node)
            return Quickshell.iconPath("application-x-executable-symbolic", true);

        const props = node.properties || {};

        for (const name of [props["application.icon-name"], props["media.icon-name"], props["application.process.binary"]]) {
            if (name) {
                const icon = Quickshell.iconPath(name, true);
                if (icon !== "")
                    return icon;
            }
        }

        const appId = props["application.id"] || props["application.process.binary"] || props["application.name"] || "";
        const entry = DesktopEntries.heuristicLookup(appId) || DesktopEntries.applications.values.find(app => app.id.toLowerCase().startsWith(appId.toLowerCase() + "-"));
        return (entry && Quickshell.iconPath(entry.icon, true)) || Quickshell.iconPath("application-x-executable-symbolic", true);
    }

    onOpenChanged: {
        if (root.open) {
            closeAnimation.stop();
            root.mounted = true;
        } else if (root.mounted) {
            closeAnimation.restart();
        }
    }

    onVisibleChanged: {
        if (!visible && root.open) {
            root.mounted = false;
            root.dismissed();
        }
    }

    SequentialAnimation {
        id: closeAnimation
        PauseAnimation {
            duration: 135
        }
        onFinished: root.mounted = false
    }

    component VolumeSlider: Item {
        id: slider

        property real value: 0
        property color accent: Theme.blue
        property bool sliderEnabled: true

        signal valueDragged(real nextValue)

        width: parent ? parent.width : 196
        height: 18
        opacity: slider.sliderEnabled ? 1.0 : 0.5

        readonly property real clampedValue: Math.max(0, Math.min(1, slider.value))
        readonly property real handleX: slider.clampedValue * (width - handle.width)

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
            width: track.width * slider.clampedValue
            height: track.height
            radius: track.radius
            color: slider.accent
        }

        Rectangle {
            id: handle

            width: 14
            height: 14
            radius: 999
            x: slider.handleX
            y: Math.round((slider.height - height) / 2)
            color: Theme.text
            border.width: 1
            border.color: slider.accent
        }

        MouseArea {
            anchors.fill: parent
            enabled: slider.sliderEnabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            function setValue(mouseX) {
                const span = Math.max(1, slider.width - handle.width);
                const next = Math.max(0, Math.min(1, mouseX / span));
                slider.valueDragged(next);
            }

            onPressed: function (mouse) {
                setValue(mouse.x - (handle.width / 2));
            }

            onPositionChanged: function (mouse) {
                if (pressed)
                    setValue(mouse.x - (handle.width / 2));
            }
        }
    }

    Rectangle {
        id: frame

        width: implicitWidth
        height: implicitHeight
        y: root.open ? 0 : -8
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.98
        transformOrigin: Item.TopRight
        implicitWidth: 260
        implicitHeight: body.implicitHeight + 24
        radius: 12
        color: Theme.surface0
        border.width: 1
        border.color: Theme.surface2

        Behavior on y {
            NumberAnimation {
                duration: 135
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 110
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 135
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: body

            x: 12
            y: 12
            width: parent.width - 24
            spacing: 10

            Row {
                width: parent.width
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
                    font.family: Config.Theme.monoFontFamily
                    font.pixelSize: root.iconPixelSize
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.label
                    color: Theme.text
                    font.family: Config.Theme.monoFontFamily
                    font.pixelSize: Config.Theme.fontSize
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.valueText
                    color: root.sliderEnabled ? Theme.subtext1 : Theme.overlay0
                    font.family: Config.Theme.monoFontFamily
                    font.pixelSize: Config.Theme.fontSize
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            VolumeSlider {
                value: root.value
                accent: root.accent
                sliderEnabled: root.sliderEnabled

                onValueDragged: function (nextValue) {
                    root.sliderInteracted();
                    root.valueDragged(nextValue);
                }
            }

            Rectangle {
                visible: root.streamModel && root.streamModel.count > 0
                width: parent.width
                height: 1
                color: Theme.surface2
            }

            Text {
                visible: root.streamModel && root.streamModel.count > 0
                text: "Applications"
                color: Theme.subtext1
                font.family: Config.Theme.monoFontFamily
                font.pixelSize: Config.Theme.fontSize
                font.weight: 700
            }

            Repeater {
                model: root.streamModel

                delegate: Column {
                    id: appEntry

                    required property var modelData
                    readonly property var node: modelData ? modelData.source : null
                    readonly property var audio: node ? node.audio : null

                    width: parent.width
                    spacing: 6
                    visible: !!appEntry.node && !!appEntry.audio
                    height: visible ? implicitHeight : 0

                    PwObjectTracker {
                        objects: appEntry.node ? [appEntry.node] : []
                    }

                    Row {
                        id: appHeader

                        width: parent.width
                        spacing: 8

                        IconImage {
                            id: appIcon

                            implicitSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                            source: root.streamIcon(appEntry.node)
                            opacity: appEntry.audio && appEntry.audio.muted ? 0.55 : 1.0

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (appEntry.audio)
                                        appEntry.audio.muted = !appEntry.audio.muted;
                                }
                            }
                        }

                        Text {
                            id: appName

                            width: Math.max(0, appHeader.width - 16 - 8 - appPercent.width - 8)
                            text: root.streamName(appEntry.node)
                            color: appEntry.audio && appEntry.audio.muted ? Theme.overlay0 : Theme.text
                            font.family: Config.Theme.monoFontFamily
                            font.pixelSize: Config.Theme.fontSize
                            font.weight: 700
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: appPercent

                            text: appEntry.audio ? (appEntry.audio.muted ? "muted" : root.percentText(appEntry.audio.volume)) : ""
                            color: appEntry.audio && appEntry.audio.muted ? Theme.overlay0 : Theme.subtext1
                            font.family: Config.Theme.monoFontFamily
                            font.pixelSize: Config.Theme.fontSize
                            font.weight: 700
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    VolumeSlider {
                        value: appEntry.audio ? appEntry.audio.volume : 0
                        accent: root.accent
                        sliderEnabled: !!appEntry.audio

                        onValueDragged: function (nextValue) {
                            root.sliderInteracted();

                            if (appEntry.audio) {
                                appEntry.audio.muted = false;
                                appEntry.audio.volume = nextValue;
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: root.outputModel !== null
                width: parent.width
                height: 1
                color: Theme.surface2
            }

            Text {
                visible: root.outputModel !== null
                text: "Output device"
                color: Theme.subtext1
                font.family: Config.Theme.monoFontFamily
                font.pixelSize: Config.Theme.fontSize
                font.weight: 700
            }

            ListView {
                id: outputs
                objectName: "audioOutputList"
                visible: root.outputModel !== null
                width: parent.width
                height: visible ? Math.min(count * 34, 170) : 0
                model: root.outputModel
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                Controls.ScrollBar.vertical: Controls.ScrollBar {}

                delegate: Controls.Button {
                    id: outputButton
                    required property var modelData
                    readonly property bool selected: modelData === root.selectedOutput
                    readonly property string deviceName: modelData.nickname || modelData.description || modelData.name
                    width: outputs.width
                    height: 34
                    padding: 8
                    Accessible.name: deviceName + (selected ? ", current output" : "")
                    onClicked: {
                        root.sliderInteracted();
                        root.outputSelected(modelData);
                    }
                    background: Rectangle {
                        radius: 8
                        color: outputButton.selected || outputButton.hovered || outputButton.activeFocus ? Theme.surface1 : "transparent"
                        border.width: outputButton.activeFocus ? 1 : 0
                        border.color: root.accent
                    }
                    contentItem: Text {
                        text: (outputButton.selected ? "✓ " : "  ") + outputButton.deviceName
                        color: outputButton.selected ? root.accent : Theme.text
                        font.family: Config.Theme.monoFontFamily
                        font.pixelSize: Config.Theme.fontSize
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
