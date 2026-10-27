//@ pragma IconTheme Papirus
// Run from an isolated copy with quickshell --path volume-check.qml --no-color.
import QtQuick
import QtTest
import Quickshell
import Quickshell.Services.Pipewire
import "widgets" as Widgets

PanelWindow {
    id: panel
    anchors { top: true; left: true }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 400
    implicitHeight: 100

    QtObject { id: speakers; property string nickname: "Speakers" }
    QtObject { id: headphones; property string nickname: "Headphones" }

    Widgets.Volume { id: volume }

    Widgets.PopupSlider {
        id: popup
        anchorItem: volume
        anchorWindow: panel
        outputModel: [speakers, headphones]
        selectedOutput: speakers
        onOutputSelected: node => selectedOutput = node
    }

    Widgets.PopupSlider {
        id: brightness
        anchorItem: volume
        anchorWindow: panel
        label: "Brightness"
    }

    TestCase {
        id: check
        when: false

        function test_icons() {
            const fallback = Quickshell.iconPath("application-x-executable-symbolic", true);
            compare(popup.streamIcon(null), fallback);
            compare(popup.streamIcon({ properties: { "application.icon-name": "nonexistent-test-icon", "application.name": "Nonexistent test app" } }), fallback);
            const gamesIcon = Quickshell.iconPath("applications-games", true);
            verify(gamesIcon !== "");
            compare(popup.streamIcon({ properties: { "application.icon-name": "applications-games" } }), gamesIcon);
            compare(popup.streamIcon({ properties: { "application.icon-name": "nonexistent-test-icon", "media.icon-name": "applications-games" } }), gamesIcon);
            tryVerify(() => DesktopEntries.byId("zen-beta") !== null, 5000);
            const zenIcon = Quickshell.iconPath(DesktopEntries.byId("zen-beta").icon, true);
            verify(zenIcon !== "");
            compare(popup.streamIcon({ properties: { "application.icon-name": "zen", "application.process.binary": "zen" } }), zenIcon);
        }

        function test_outputs() {
            // shortcut: QtTest clicks lack Wayland input serials, verify outside clicks manually.
            popup.grabFocus = false;
            popup.open = true;
            wait(200);
            const outputs = findChild(popup, "audioOutputList");
            compare(outputs.count, 2);
            verify(outputs.itemAtIndex(0).selected);
            verify(!outputs.itemAtIndex(1).selected);
            mouseClick(outputs.itemAtIndex(1));
            compare(popup.selectedOutput, headphones);
            verify(outputs.itemAtIndex(1).selected);
            verify(!outputs.itemAtIndex(0).selected);

            popup.outputModel = [speakers];
            popup.selectedOutput = null;
            wait(100);
            compare(outputs.count, 1);
            verify(!outputs.itemAtIndex(0).selected);
            mouseClick(outputs.itemAtIndex(0));
            compare(popup.selectedOutput, speakers);

            popup.outputModel = Array(8).fill(speakers);
            wait(100);
            compare(outputs.height, 170);
            verify(outputs.contentHeight > outputs.height);
            verify(!findChild(brightness, "audioOutputList").visible);
            popup.open = false;

            tryVerify(() => Pipewire.ready && volume.outputs.length > 0, 5000);
            volume.popupVisible = true;
            const liveOutputs = findChild(volume, "audioOutputList");
            wait(200);
            compare(liveOutputs.count, volume.outputs.length);
            const sink = Pipewire.defaultAudioSink;
            const source = Pipewire.defaultAudioSource;
            const selected = volume.outputs.indexOf(sink);
            verify(selected >= 0);
            liveOutputs.positionViewAtIndex(selected, ListView.Contain);
            wait(100);
            verify(liveOutputs.itemAtIndex(selected).selected);
            liveOutputs.itemAtIndex(selected).clicked();
            tryCompare(Pipewire, "preferredDefaultAudioSink", sink);
            compare(Pipewire.defaultAudioSource, source);
            volume.closePopup();
        }
    }

    Timer {
        interval: 200
        running: true
        onTriggered: {
            try {
                check.test_icons();
                check.test_outputs();
                console.log("Volume output checks passed");
                Qt.quit();
            } catch (error) {
                console.error(error);
                Qt.exit(1);
            }
        }
    }
}
