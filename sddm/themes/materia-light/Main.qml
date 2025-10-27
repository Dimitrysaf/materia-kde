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
        color: '#dfdfdf'
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
        anchors.rightMargin: 30
        anchors.topMargin: 5
        spacing: 0

        Item {
            width: 22
            height: 22
            
            Image {
                id: shutdown
                anchors.fill: parent
                source: Qt.resolvedUrl("images/system-shutdown.svg")
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(22, 22)
                cache: false
                asynchronous: false

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        shutdown.source = Qt.resolvedUrl("images/system-shutdown-hover.svg")
                        var component = Qt.createComponent("components/ShutdownToolTip.qml")
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(shutdown)
                            tooltip.x = -100
                            tooltip.y = 40
                            tooltip.destroy(600)
                        }
                    }
                    onExited: {
                        shutdown.source = Qt.resolvedUrl("images/system-shutdown.svg")
                    }
                    onClicked: {
                        shutdown.source = Qt.resolvedUrl("images/system-shutdown-pressed.svg")
                        sddm.powerOff()
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 60
        anchors.topMargin: 5
        spacing: 0

        Item {
            width: 22
            height: 22
            
            Image {
                id: reboot
                anchors.fill: parent
                source: Qt.resolvedUrl("images/system-reboot.svg")
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(22, 22)
                cache: false
                asynchronous: false

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        reboot.source = Qt.resolvedUrl("images/system-reboot-hover.svg")
                        var component = Qt.createComponent("components/RebootToolTip.qml")
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(reboot)
                            tooltip.x = -100
                            tooltip.y = 40
                            tooltip.destroy(600)
                        }
                    }
                    onExited: {
                        reboot.source = Qt.resolvedUrl("images/system-reboot.svg")
                    }
                    onClicked: {
                        reboot.source = Qt.resolvedUrl("images/system-reboot-pressed.svg")
                        sddm.reboot()
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 90
        anchors.topMargin: 5
        Text {
            id: timelb
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: '#000000'
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
        anchors.rightMargin: 140
        anchors.topMargin: 4
        Text {
            id: kb
            color: '#000000'
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
            color: '#000000'
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
            Material.theme: Material.Light
            Material.accent: "#1a73e8"
            background: Rectangle {
                color: Material.dialogColor
                radius: 2
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
                    
                    RectangularShadow { // Shadow for the avatar
                        anchors.fill: avatarContainer
                        width: avatarContainer.width
                        height: avatarContainer.height
                        blur: 70
                        spread: -20
                        radius: avatarContainer.radius
                    }
                    
                    // Rounded avatar with clipping
                    Rectangle {
                        id: avatarContainer
                        anchors.fill: parent
                        radius: 72
                        color: "#2d2d2d"
                        clip: true
                        
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
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    RectangularShadow { // Shadow for the user ComboBox
                        anchors.fill: user
                        width: user.width
                        height: user.height
                        blur: 70
                        spread: -20
                        radius: avatarContainer.radius
                    }

                    ComboBox {
                        id: user
                        height: 50
                        width: height * 7
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: userModel
                        textRole: "name"
                        currentIndex: userModel.lastIndex

                        delegate: MenuItem {
                            Material.theme: Material.Light
                            Material.accent: "#1a73e8"
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
                            Material.theme: Material.Light
                            Material.accent: "#1a73e8"
                            width: parent.width
                            height: parent.height * parent.count
                            implicitHeight: ulistview.contentHeight
                            margins: 0
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
                        background: Rectangle {
                            color: Material.dialogColor
                            border.width: 1
                            border.color: Material.dividerColor
                            radius: 2
                        }
                    }
                }

                TextField {
                    id: password
                    height: 50
                    width: height * 7
                    anchors.horizontalCenter: parent.horizontalCenter
                    echoMode: TextInput.Password
                    focus: true
                    placeholderText: textConstants.password
                    onAccepted: sddm.login(user.currentText, password.text, session.currentIndex)
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(user.currentText, password.text, session.currentIndex)
                            event.accepted = true
                        }
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            width: parent.width
                            height: 1
                            anchors.bottom: parent.bottom
                            color: password.activeFocus ? Material.accentColor : Material.dividerColor
                        }
                    }
                    
                    Image {
                        id: caps
                        width: 24
                        height: 24
                        opacity: 0
                        state: keyboard.capsLock ? "activated" : ""
                        anchors.right: password.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        fillMode: Image.PreserveAspectFit
                        source: Qt.resolvedUrl("images/capslock.svg")
                        sourceSize: Qt.size(24, 24)

                        states: [
                            State {
                                name: "activated"
                                PropertyChanges {
                                    target: caps
                                    opacity: 1
                                }
                            },
                            State {
                                name: ""
                                PropertyChanges {
                                    target: caps
                                    opacity: 0
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                to: "activated"
                                NumberAnimation {
                                    target: caps
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 200
                                }
                            },
                            Transition {
                                to: ""
                                NumberAnimation {
                                    target: caps
                                    property: "opacity"
                                    from: 1
                                    to: 0
                                    duration: 200
                                }
                            }
                        ]
                    }
                }

                Item {
                    width: 350
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    RectangularShadow { // Shadow for the session ComboBox
                        anchors.fill: session
                        width: session.width
                        height: session.height
                        blur: 70
                        spread: -20
                        radius: avatarContainer.radius
                    }

                    ComboBox {
                        id: session
                        height: 50
                        width: height * 7
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: sessionModel
                        textRole: "name"
                        currentIndex: sessionModel.lastIndex

                        delegate: MenuItem {
                            Material.theme: Material.Light
                            Material.accent: "#1a73e8"
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
                            Material.theme: Material.Light
                            Material.accent: "#1a73e8"
                            width: parent.width
                            height: parent.height * parent.count
                            implicitHeight: slistview.contentHeight
                            margins: 0
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
                        background: Rectangle {
                            color: Material.dialogColor
                            border.width: 1
                            border.color: Material.dividerColor
                            radius: 2
                        }
                    }
                }

                Item {
                    width: 350
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    RectangularShadow { // Shadow for the login Button
                        anchors.fill: login
                        width: login.width
                        height: login.height
                        blur: 70
                        spread: -20
                        radius: login.radius
                    }

                    Button {
                        id: login
                        height: 50
                        width: height * 7
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon.source: Qt.resolvedUrl("images/login.svg")
                        icon.width: 24
                        icon.height: 24
                        text: textConstants.login
                        font.bold: true
                        onClicked: sddm.login(user.currentText, password.text, session.currentIndex)
                        highlighted: true
                        background: Rectangle {
                            color: login.down ? Qt.darker(Material.accentColor, 1.2) : Material.accentColor
                            radius: 2
                        }
                    }
                }
            }
        }
    }
}