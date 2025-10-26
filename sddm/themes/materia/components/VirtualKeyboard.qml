import QtQuick 6.0
import QtQuick.VirtualKeyboard 6.0

InputPanel {
    id: inputPanel
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    visible: active
    width: parent.width
}
