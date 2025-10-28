import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Effects
import QtQuick.Controls.Material 6.0
import "components"

Rectangle {
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants {
        id: textConstants
    }

    // hack for disable autostart QtQuick.VirtualKeyboard
    Loader {
        id: inputPanel
        property bool keyboardActive: false
        source: "components/VirtualKeyboard.qml"
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {

        }
        function onLoginFailed() {
            password.placeholderText = textConstants.loginFailed
            password.placeholderTextColor = "#f44336"
            password.text = ""
            password.focus = true
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        Binding on source {
            when: config.background !== undefined
            value: config.background
        }
    }

    Rectangle {
        id: panel
        color: "#121212"
        height: 32
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }

    RectangularShadow {
        anchors.fill: panel
        width: panel.width
        height: panel.height
        blur: 70
        spread: -20
        radius: panel.radius
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.topMargin: 5
        Text {
            id: timelb
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: "#dfdfdf"
            font.pointSize: 11
        }
    }

    Timer {
        id: timetr
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            timelb.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 60
        anchors.topMargin: 4
        Text {
            id: kb
            color: "#dfdfdf"
            text: keyboard.layouts[keyboard.currentLayout].shortName
            font.pointSize: 11
        }
    }

    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.topMargin: 5
        Text {
            id: welcome
            text: textConstants.welcomeText.arg(sddm.hostName)
            color: "#dfdfdf"
            font.pointSize: 11
        }
    }

    Item {
        anchors.centerIn: parent
        width: dialog.width
        height: dialog.height

        Dialog {
            id: dialog
            closePolicy: Popup.NoAutoClose
            focus: true
            visible: true
            Material.theme: Material.Dark
            Material.accent: "#8ab4f8"
            background: Rectangle {
                color: Material.dialogColor
                radius: 2
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 1.0
                    shadowVerticalOffset: 8
                    shadowHorizontalOffset: 0
                    shadowColor: "#80000000"
                }
            }
            Overlay.modal: Rectangle {
                color: "transparent"
            }

            Column {
                spacing: 10
                anchors.centerIn: parent

                Item {
                    width: 144
                    height: 144
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Rectangle {
                        id: avatarContainer
                        anchors.fill: parent
                        radius: 72
                        color: "#2d2d2d"
                        clip: true
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: 0.6
                            shadowVerticalOffset: 4
                            shadowHorizontalOffset: 0
                            shadowColor: "#60000000"
                        }
                        
                        Image {
                            id: ava
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            cache: false
                            smooth: true
                            
                            Component.onCompleted: {
                                source = "/var/lib/AccountsService/icons/" + user.currentText
                            }
                            
                            onStatusChanged: {
                                if (status === Image.Error) {
                                    source = Qt.resolvedUrl("images/.face.icon")
                                }
                            }
                        }
                    }
                }

                Item {
                    width: 350
                    height: 44
                    anchors.horizontalCenter: parent.horizontalCenter

                    ComboBox {
                        id: user
                        height: 44
                        width: 350
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: userModel
                        textRole: "name"
                        currentIndex: userModel.lastIndex
                        Material.theme: Material.Dark
                        Material.accent: "#8ab4f8"

                        delegate: MenuItem {
                            Material.theme: Material.Dark
                            Material.accent: "#8ab4f8"
                            width: ulistview.width
                            text: user.textRole ? (Array.isArray(user.model) ? modelData[user.textRole] : model[user.textRole]) : modelData
                            Material.foreground: user.currentIndex === index ? ulistview.contentItem.Material.accent : ulistview.contentItem.Material.foreground
                            highlighted: user.highlightedIndex === index
                            hoverEnabled: user.hoverEnabled
                            onClicked: {
                                user.currentIndex = index
                                ulistview.currentIndex = index
                                user.popup.close()
                                ava.source = ""
                                ava.source = "/var/lib/AccountsService/icons/" + user.currentText
                            }
                        }
                        popup: Popup {
                            Material.theme: Material.Dark
                            Material.accent: "#8ab4f8"
                            width: parent.width
                            height: parent.height * parent.count
                            implicitHeight: ulistview.contentHeight
                            margins: 0
                            background: Rectangle {
                                color: Material.dialogColor
                                border.width: 1
                                border.color: Material.dividerColor
                                radius: 2
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowBlur: 0.6
                                    shadowVerticalOffset: 4
                                    shadowHorizontalOffset: 0
                                    shadowColor: "#60000000"
                                }
                            }
                            contentItem: ListView {
                                id: ulistview
                                clip: true
                                anchors.fill: parent
                                model: user.model
                                spacing: 0
                                highlightFollowsCurrentItem: true
                                currentIndex: user.highlightedIndex
                                delegate: user.delegate
                            }
                        }
                    }
                }

                TextField {
                    id: password
                    height: 44
                    width: 350
                    anchors.horizontalCenter: parent.horizontalCenter
                    echoMode: TextInput.Password
                    focus: true
                    placeholderText: textConstants.password
                    Material.theme: Material.Dark
                    Material.accent: "#8ab4f8"
                    onAccepted: sddm.login(user.currentText, password.text, session.currentIndex)
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(user.currentText, password.text, session.currentIndex)
                            event.accepted = true
                        }
                    }
                    Image {
                        id: caps
                        width: 24
                        height: 24
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: Qt.resolvedUrl("images/capslock.svg")
                        visible: keyboard.capsLock
                        z: 10
                    }
                }

                Item {
                    width: 350
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    ComboBox {
                        id: session
                        height: 44
                        width: 350
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: sessionModel
                        textRole: "name"
                        currentIndex: sessionModel.lastIndex
                        Material.theme: Material.Dark
                        Material.accent: "#8ab4f8"

                        delegate: MenuItem {
                            Material.theme: Material.Dark
                            Material.accent: "#8ab4f8"
                            width: slistview.width
                            text: session.textRole ? (Array.isArray(session.model) ? modelData[session.textRole] : model[session.textRole]) : modelData
                            Material.foreground: session.currentIndex === index ? slistview.contentItem.Material.accent : slistview.contentItem.Material.foreground
                            highlighted: session.highlightedIndex === index
                            hoverEnabled: session.hoverEnabled
                            onClicked: {
                                session.currentIndex = index
                                slistview.currentIndex = index
                                session.popup.close()
                            }
                        }
                        popup: Popup {
                            Material.theme: Material.Dark
                            Material.accent: "#8ab4f8"
                            width: parent.width
                            height: parent.height * parent.count
                            implicitHeight: slistview.contentHeight
                            margins: 0
                            background: Rectangle {
                                color: Material.dialogColor
                                border.width: 1
                                border.color: Material.dividerColor
                                radius: 2
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowBlur: 0.6
                                    shadowVerticalOffset: 4
                                    shadowHorizontalOffset: 0
                                    shadowColor: "#60000000"
                                }
                            }
                            contentItem: ListView {
                                id: slistview
                                clip: true
                                anchors.fill: parent
                                model: session.model
                                spacing: 0
                                highlightFollowsCurrentItem: true
                                currentIndex: session.highlightedIndex
                                delegate: session.delegate
                            }
                        }
                    }
                }

                Item {
                    width: 350
                    height: 44
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        id: login
                        height: 50
                        width: 350
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon.source: Qt.resolvedUrl("images/login.svg")
                        icon.width: 24
                        icon.height: 24
                        text: textConstants.login
                        font.bold: true
                        onClicked: sddm.login(user.currentText, password.text, session.currentIndex)
                        highlighted: true
                        Material.theme: Material.Dark
                        Material.accent: "#8ab4f8"
                        background: Rectangle {
                            color: login.down ? Qt.darker(Material.accentColor, 1.2) : Material.accentColor
                            radius: 2
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowBlur: 0.4
                                shadowVerticalOffset: 2
                                shadowHorizontalOffset: 0
                                shadowColor: "#60000000"
                            }
                        }
                    }
                }  
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    Item {
                        width: ((shutdownButton.height - 3) * 7) / 2
                        height: 50
                        Button {
                            id: shutdownButton
                            anchors.fill: parent
                            icon.source: Qt.resolvedUrl("images/system-shutdown.svg")
                            icon.width: 24
                            icon.height: 24
                            text: qsTr("Shutdown")
                            font.bold: true
                            onClicked: sddm.powerOff()
                            highlighted: true
                            Material.theme: Material.Dark
                            Material.accent: "#8ab4f8"
                            background: Rectangle {
                                color: shutdownButton.down ? Qt.darker(Material.accentColor, 1.2) : Material.accentColor
                                radius: 2
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowBlur: 0.4
                                    shadowVerticalOffset: 2
                                    shadowHorizontalOffset: 0
                                    shadowColor: "#60000000"
                                }
                            }
                        }
                    }
                    Item {
                        width: ((rebootButton.height - 3) * 7) / 2
                        height: 50
                        Button {
                            id: rebootButton
                            anchors.fill: parent
                            icon.source: Qt.resolvedUrl("images/system-reboot.svg")
                            icon.width: 24
                            icon.height: 24
                            text: qsTr("Reboot")
                            font.bold: true
                            onClicked: sddm.reboot()
                            highlighted: true
                            Material.theme: Material.Dark
                            Material.accent: "#8ab4f8"
                            background: Rectangle {
                                color: rebootButton.down ? Qt.darker(Material.accentColor, 1.2) : Material.accentColor
                                radius: 2
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowBlur: 0.4
                                    shadowVerticalOffset: 2
                                    shadowHorizontalOffset: 0
                                    shadowColor: "#60000000"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}