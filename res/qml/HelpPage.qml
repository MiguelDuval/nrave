import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import "Theme"

Item {
    id: root

    property int sideMargin: 18
    property int sectionSpacing: 14

    Rectangle {
        anchors.fill: parent
        color: Theme.nearBlack
        radius: 5
    }

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.margins: root.sideMargin
        clip: true
        contentHeight: contentColumn.height
        contentWidth: width
        interactive: true
        flickableDirection: Flickable.VerticalFlick

        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn

            spacing: root.sectionSpacing
            width: flickable.width

            Column {
                spacing: 5
                width: parent.width

                Text {
                    color: Theme.brightCyan
                    font.bold: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 26
                    text: "NRAVE HELP"
                }

                Text {
                    color: Theme.primaryText
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    lineHeight: 1.2
                    lineHeightMode: Text.ProportionalHeight
                    text: "A quick setup guide for Android, USB MIDI controllers, and audio."
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            Rectangle {
                color: Theme.softBorder
                height: 1
                width: parent.width
            }

            HelpSection {
                title: "1  ANDROID: FIRST LAUNCH"
                accent: Theme.primaryCyan
                body: "Connect your USB MIDI controller to the Android device before starting NRAVE. NRAVE may not detect a controller that is connected after the application has already started.\n\nStart NRAVE after the controller is connected. When Android asks for access to music, files, microphone, or USB hardware, allow the permissions needed by your setup.\n\nFor reliable DJ use, keep NRAVE allowed to run in the background and disable aggressive battery optimization for the app when your Android device offers that option. This helps prevent audio or USB communication from being interrupted while performing."
            }

            HelpSection {
                title: "2  MUSIC & STORAGE"
                accent: Theme.primaryCyan
                body: "Make sure your music files are accessible to NRAVE. If your Android version asks you to choose a folder or grant media/file access, complete that step before building your library.\n\nIf tracks do not appear, check the Android permission and the location of your music files first. After changing storage access, restart NRAVE and rescan the library if necessary."
            }

            HelpSection {
                title: "3  CONNECT A USB MIDI CONTROLLER"
                accent: Theme.primaryViolet
                body: "1. Connect the controller to the phone/tablet with a suitable USB-OTG adapter or hub.\n2. Unlock Android and approve the USB access request if one appears.\n3. In NRAVE open  Settings  →  Controllers.\n4. Select the connected MIDI interface/controller.\n5. Choose  Create Device.\n6. Select the correct mapping for your controller.\n7. Turn the controller  On  (blue).\n8. Press  Save.\n9. Confirm the Android warning if it appears.\n10. If the controller still does not respond, open Controllers again and finish the setup there.\n\nImportant: a controller can be visible to Android but still do nothing in NRAVE until the correct mapping is enabled and saved."
            }

            HelpSection {
                title: "4  SET UP SOUND HARDWARE"
                accent: Theme.primaryViolet
                body: "Open  Settings  →  Sound Hardware.\n\n• Select the Android audio driver.\n• Choose the audio device/output you actually want to use (for example, your controller's built-in audio interface or another USB audio device).\n• Set the sample rate to a value supported by the device, commonly 44.1 kHz or 48 kHz. When possible, use the same rate expected by the connected hardware.\n• Scroll to the routing graph at the bottom. Find the required output nodes and connect the circular connectors to create the route you need.\n\nFor a normal DJ setup, the most important result is simple: NRAVE must have a valid Master output, and a Headphones output if you need headphone cueing."
            }

            HelpSection {
                title: "5  FINAL CHECK"
                accent: Theme.green
                body: "Before you start mixing:\n\n1. Load a track onto a deck.\n2. Confirm the track plays and the waveform moves.\n3. Move a control on the MIDI controller and check that NRAVE reacts.\n4. Confirm you can hear the Master output.\n5. If your setup uses headphones, press Cue/PFL and verify the headphone output.\n\nABLETON LINK\nAbleton Link works when the Android device running NRAVE and the other Ableton Link-enabled device are connected to the same Wi-Fi network. Once they are on the same network, Link can synchronize tempo and phase between the participating devices."
            }

            Rectangle {
                color: Theme.panelGraphite
                radius: 6
                border.color: Theme.softBorder
                border.width: 1
                height: troubleshootingColumn.height + 20
                width: parent.width

                Column {
                    id: troubleshootingColumn

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 6

                    Text {
                        color: Theme.amber
                        font.bold: true
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        text: "QUICK TROUBLESHOOTING"
                    }

                    Text {
                        color: Theme.primaryText
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        lineHeight: 1.15
                        lineHeightMode: Text.ProportionalHeight
                        text: "Controller not responding? Recheck USB access, the selected device, mapping, and the blue On state.\nAudio glitches or silence? Recheck the selected output, sample rate, and routing graph. Avoid extremely low latency on slower Android hardware."
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            Item {
                height: 4
                width: 1
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        policy: flickable.contentHeight > flickable.height
                ? ScrollBar.AsNeeded
                : ScrollBar.AlwaysOff
    }
}
