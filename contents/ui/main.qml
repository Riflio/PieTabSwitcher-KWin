import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kwin as KWin

/**
* @brief
* @ref https://github.com/KDE/kwin/
* @ref https://develop.kde.org/docs/plasma/kwin/api/
*/
KWin.TabBoxSwitcher {
  id: tabBox

  Window {
    id: wnd
    width: pie.implicitWidth
    height: pie.implicitHeight
    visible: tabBox.visible
    flags: Qt.BypassWindowManagerHint | Qt.FramelessWindowHint
    color: "transparent"

    Pie {
      id: pie
      model: tabBox.model
      bg.color: "#4b4b4b"

      onClicked: {
        tabBox.model.activate(pie.current);
      }

      onCurrentChanged: {
        //-- Нет выбранного - курсор увели, ставим то, что сейчас выбрано было из tabBox
        if ( current<0 ) { current =tabBox.currentIndex; }
      }

      Item {
        id: centerItem
        anchors.centerIn: parent
        width: txt.contentWidth
        height: txt.contentHeight
        property date currentDate: new Date()

        Timer {
          interval: 1000
          running: true
          repeat: true
          onTriggered: {
            centerItem.currentDate =new Date();
          }
        }

        Text {
          id: txt
          horizontalAlignment: Text.AlignHCenter
          text: Qt.formatTime(centerItem.currentDate, "hh:mm:ss")+"\n"+Qt.formatDate(centerItem.currentDate, "dd.MM.yyyy")
        }
      }
    }

    onVisibleChanged: {
      //-- При показе выставляем центром по координатам курсора
      if ( visible ) {
        wnd.x =KWin.Workspace.cursorPos.x-wnd.width/2;
        wnd.y =KWin.Workspace.cursorPos.y-wnd.height/2;
        pie.updateData();
      }
    }
  }

  onCurrentIndexChanged: {
    pie.current =tabBox.currentIndex;
  }
}
