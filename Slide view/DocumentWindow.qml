import QtQuick 2.0
import QtQuick.Controls 2.4
import Qt.labs.platform 1.0 as NativeDialogs

ApplicationWindow {
    id: root
    title: (_fileName.length===0?qsTr("Document"):_fileName) + (_isDirty?"*":"")

    width: 640
    height: 480
    property bool _isDirty: true
    property string _fileName
    property bool _tryingToClose: false

    menuBar: MenuBar {

        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&New")
                icon.name: "document-new"
                onTriggered: root.newDocument()
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("&Open")
                icon.name: "document-open"
                onTriggered: openDocument()
            }

            MenuItem {
                text: qsTr("&Save")
                icon.name: "document-save"
                onTriggered: saveDocument()
            }

            MenuItem {
                text: qsTr("Save &As")
                icon.name: "document-save-as"
                onTriggered: saveAsDocument()
            }
        }
    }

    function _createNewDocument(){
        var component = Qt.createComponent("DocumentWindow.qml");
        var window = component.createObject();
        return window;
    }

    function newDocument(){
        var window = _createNewDocument();
        window.show();
    }

    function openDocument(fileName){
        openDialog.open();
    }

    function saveAsDocument(){
        saveAsDialog.open();
    }

    function saveDocument(){
        if (_fileName.length == 0){
            root.saveAsDocument();
        }
        else {
            console.log("Saving document")
            root._isDirty = false;

            if (root._tryingToClose) root.close();
        }
    }

    NativeDialogs.FileDialog {
        id: openDialog
        title: "Open"
        folder: NativeDialogs.StandardPaths.writableLocation(NativeDialogs.StandardPaths.DocumentsLocation)
        onAccepted: {
            var window = root._createNewDocument();
            window._fileName = openDialog.file;
            window.show();
        }
    }

    NativeDialogs.FileDialog {
        id: saveAsDialog
        title: "Save as"
        folder: NativeDialogs.StandardPaths.writableLocation(NativeDialogs.StandardPaths.DocumentsLocation)
        onAccepted: {
            root._fileName = saveAsDialog.file
            saveDocument();
        }

        onRejected: {
            root._tryingToClose = false;
        }
    }

    NativeDialogs.MessageDialog {
        id: closeWarningDialog
        title: "Closing documnet"
        text: "You didn't save. Wanna save?"
        buttons: NativeDialogs.MessageDialog.Yes | NativeDialogs.MessageDialog.No | NativeDialogs.MessageDialog.Cancel
        onYesClicked: {
            root._tryingToClose = true;
            root.saveDocument();
        }

        onNoClicked: {
            root._isDirty = false;
            root.close();
        }

        onRejected: {

        }
    }
}
