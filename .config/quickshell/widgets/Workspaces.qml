pragma ComponentBehavior: Bound
import QtQuick
import "../style/theme.js" as Theme

Item {
    id: root

    required property var screen
    required property var niriService

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 10

        Repeater {
            model: root.niriService.workspaces

            delegate: Item {
                id: wsItem

                required property int id
                required property int index
                required property string name
                required property string output
                required property bool isActive
                required property bool isFocused
                required property bool isUrgent

                readonly property bool belongsHere: output === root.screen.name

                visible: belongsHere
                width: belongsHere ? Math.max(18, wsText.implicitWidth + 6) : 0
                height: belongsHere ? 20 : 0

                Text {
                    id: wsText
                    anchors.centerIn: parent
                    text: wsItem.name !== "" ? wsItem.name : wsItem.index
                    color: {
                        if (wsItem.isUrgent) return Theme.red
                        if (wsItem.isFocused) return Theme.text
                        if (wsItem.isActive) return Theme.subtext1
                        return Theme.overlay0
                    }
                    font.pixelSize: 12
                    font.weight: wsItem.isFocused ? 700 : 500
                }

                Rectangle {
                    visible: wsItem.isFocused
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: Math.max(10, wsText.implicitWidth - 2)
                    height: 2
                    radius: 999
                    color: Theme.mauve
                }

                Rectangle {
                    visible: wsItem.isUrgent
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: 4
                    height: 4
                    radius: 999
                    color: Theme.red
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: wsItem.belongsHere
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.niriService.focusWorkspaceById(wsItem.id)
                }
            }
        }
    }
}
