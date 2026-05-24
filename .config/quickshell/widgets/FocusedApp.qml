import QtQuick
import ".." as Config
import "../style/theme.js" as Theme

Item {
    id: root

    required property var niriService
    property int maxTitleWidth: 360

    readonly property var win: root.niriService.focusedWindow

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    visible: win !== null && ((win.title ?? "") !== "" || (win.appId ?? "") !== "")

    Row {
        id: content
        spacing: 8
        anchors.centerIn: parent

        Image {
            readonly property string iconSource: root.win && root.win.iconPath !== "" ? "file://" + root.win.iconPath : ""

            source: iconSource
            width: 20
            height: 20

            sourceSize.width: 38
            sourceSize.height: 38

            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: iconSource !== ""
        }

        Text {
            width: root.maxTitleWidth
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter

            text: {
                if (!root.win)
                    return "";
                return root.win.title !== "" ? root.win.title : root.win.appId;
            }

            color: Theme.text
            font.family: Config.Theme.monoFontFamily
            font.pixelSize: Config.Theme.fontSize
            font.weight: 700
        }
    }
}
