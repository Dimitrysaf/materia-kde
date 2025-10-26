import QtQuick 6.0
import QtQuick.Effects

Rectangle {
    color:"transparent"
    width:130
    height: 32
    border.width: 0
    
    Text {
        id: text
        color: "#ffffff"
        font.pixelSize : 14
        text: textConstants.reboot
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
    MultiEffect {
        source: text
        anchors.fill: parent
        shadowEnabled: true
        shadowHorizontalOffset: 1
        shadowVerticalOffset: 1
        shadowBlur: 0.1
        shadowColor: "#60000000"
    }
}
