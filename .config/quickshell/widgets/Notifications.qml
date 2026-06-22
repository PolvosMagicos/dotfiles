import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import ".." as Config
import "../style/theme.js" as Theme

Scope {
    id: root

    property var screen: null
    property int topMargin: 12
    property int rightMargin: 12
    property bool centerOpen: false

    ListModel {
        id: notificationsHistory
    }

    NotificationServer {
        id: notificationServer

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            notificationsHistory.insert(0, {
                summary: n.summary || "",
                body: n.body || "",
                appName: n.appName || "",
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            });
            n.tracked = true;
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void {
            root.centerOpen = !root.centerOpen;
        }
        function show(): void {
            root.centerOpen = true;
        }
        function hide(): void {
            root.centerOpen = false;
        }
    }

    PanelWindow {
        screen: root.screen

        anchors {
            top: true
            right: true
        }
        margins {
            top: root.topMargin
            right: root.rightMargin
        }

        implicitWidth: 380
        implicitHeight: Math.max(1, notificationsColumn.implicitHeight)
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: notificationsColumn
            width: parent.width
            spacing: 10

            Repeater {
                model: notificationServer.trackedNotifications
                delegate: Rectangle {
                    id: notificationCard
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentCardLayout.implicitHeight + 20
                    radius: 8
                    color: Theme.surface0
                    border.width: 1
                    border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.red : Theme.blue

                    Timer {
                        interval: Config.AppConfig.notificationTimeoutMs
                        running: Config.AppConfig.notificationTimeoutMs > 0
                        repeat: false
                        onTriggered: notificationCard.modelData.dismiss()
                    }

                    RowLayout {
                        id: contentCardLayout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Item {
                            id: notificationImageFrame
                            readonly property string imageSource: notificationCard.modelData.image || notificationCard.modelData.appIcon || ""

                            Layout.preferredHeight: notificationText.implicitHeight
                            Layout.preferredWidth: notificationText.implicitHeight
                            Layout.alignment: Qt.AlignTop
                            visible: imageSource !== ""
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: notificationImageFrame.imageSource
                                fillMode: Image.PreserveAspectCrop
                                horizontalAlignment: Image.AlignHCenter
                                verticalAlignment: Image.AlignVCenter
                            }
                        }

                        ColumnLayout {
                            id: notificationText

                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: notificationCard.modelData.summary
                                color: notificationCard.modelData.urgency === NotificationUrgency.Critical ? Theme.red : Theme.text
                                font.family: Config.Theme.monoFontFamily
                                font.pixelSize: Config.Theme.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: notificationCard.modelData.body
                                color: Theme.subtext1
                                font.family: Config.Theme.monoFontFamily
                                font.pixelSize: Config.Theme.fontSize - 1
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: notificationCard.modelData.dismiss()
                    }
                }
            }
        }
    }

    PanelWindow {
        id: notificationsCenter
        readonly property int maxCenterHeight: Math.floor((screen ? screen.height : 1080) / 3)
        readonly property int maxHistoryHeight: Math.max(80, maxCenterHeight - 82)

        screen: root.screen
        visible: root.centerOpen
        anchors {
            top: true
            right: true
        }
        margins {
            top: root.topMargin
            right: root.rightMargin
        }

        implicitWidth: 380
        implicitHeight: Math.min(notificationsCenterColumn.implicitHeight + 24, maxCenterHeight)
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Theme.base
            border.width: 2
            border.color: Theme.lavender

            ColumnLayout {
                id: notificationsCenterColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Theme.blue
                        font.family: Config.Theme.monoFontFamily
                        font.pixelSize: Config.Theme.fontSize + 2
                        font.bold: true
                    }
                    Text {
                        text: "Clear all"
                        visible: notificationsHistory.count > 0
                        color: Theme.red
                        font.family: Config.Theme.monoFontFamily
                        font.pixelSize: Config.Theme.fontSize
                        font.bold: true

                        MouseArea {
                            anchors.fill: parent
                            onClicked: notificationsHistory.clear()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: notificationsHistory.count === 0
                    text: "No notifications"
                    color: Theme.overlay0
                    font.family: Config.Theme.monoFontFamily
                    font.pixelSize: Config.Theme.fontSize
                    horizontalAlignment: Text.AlignHCenter
                }

                Flickable {
                    id: historyScroll

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: Math.min(historyList.implicitHeight, notificationsCenter.maxHistoryHeight)
                    visible: notificationsHistory.count > 0
                    clip: true
                    contentWidth: width
                    contentHeight: historyList.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: historyList

                        width: historyScroll.width
                        spacing: 10

                        Repeater {
                            model: notificationsHistory

                            delegate: Rectangle {
                                required property string summary
                                required property string body
                                required property string appName
                                required property int urgency
                                required property string time

                                Layout.fillWidth: true
                                Layout.preferredHeight: historyContent.implicitHeight + 20
                                radius: 8
                                color: Theme.surface0
                                border.width: 1
                                border.color: urgency === NotificationUrgency.Critical ? Theme.red : Theme.surface2

                                ColumnLayout {
                                    id: historyContent
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            Layout.fillWidth: true
                                            text: summary
                                            color: urgency === NotificationUrgency.Critical ? Theme.red : Theme.text
                                            font.family: Config.Theme.monoFontFamily
                                            font.pixelSize: Config.Theme.fontSize
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: time
                                            color: Theme.overlay0
                                            font.family: Config.Theme.monoFontFamily
                                            font.pixelSize: Config.Theme.fontSize - 1
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: appName !== ""
                                        text: appName
                                        color: Theme.blue
                                        font.family: Config.Theme.monoFontFamily
                                        font.pixelSize: Config.Theme.fontSize - 1
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: body !== ""
                                        text: body
                                        color: Theme.subtext1
                                        font.family: Config.Theme.monoFontFamily
                                        font.pixelSize: Config.Theme.fontSize - 1
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
