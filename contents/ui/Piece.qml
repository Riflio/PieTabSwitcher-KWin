import QtQuick
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.kwin as KWin

Item {
  id: piece
  property double rOut: 150 //-- Внешний радиус
  property double rIn: 40 //-- Внутренний радиус
  property double angle: 150 //-- Центральный угол, в градусах
  property double offset: 5 //-- Отступ
  property double rotation: 0 //-- Поповрот
  property alias icon: icon

  readonly property double angle2: angle*Math.PI/360.0 //-- Угол в радианы и сразу делим на 2, т.к. используется часто
  readonly property double chord1: 2.0*rOut*Math.sin(angle2) //-- Длина хорды центрального угла (в градусах)
  readonly property double chord2: 2.0*rIn*Math.sin(angle2)

  width: chord1
  height: rOut

  transform: Rotation {
    origin {
      x: width/2
      y: height
    }
    angle: piece.rotation
  }

  layer.enabled: true
  layer.samples: 8
  layer.effect: OpacityMask {
    maskSource: mask
  }

  Canvas {
    id: mask
    anchors.fill: parent
    onPaint: {
      let ctx = getContext("2d");
      ctx.fillStyle =Qt.rgba(0, 0, 0, 1);
      ctx.clearRect(0, 0, width, height);

      let calcCenterAngle =(r) => {
        let a =Math.PI/2.0-angle2;
        let adj =offset*Math.sin(a);
        let opp =offset*Math.cos(a);
        let leg =Math.sqrt(r*r-opp*opp)-adj;
        let chord = 2.0*leg*Math.sin(angle2);
        return 2.0*Math.asin(chord/(2.0*r));  // (r+offset) без всего остального, но не точно
      }

      let a1 =calcCenterAngle(rOut);
      let a2 =calcCenterAngle(rIn);

      ctx.beginPath();
        ctx.arc(width/2, height, rOut, Math.PI*1.5-a1/2.0, -Math.PI/2.0+a1/2.0, 0);
        ctx.arc(width/2, height, rIn, -Math.PI/2.0+a2/2.0, Math.PI*1.5-a2/2.0, 1);
        ctx.closePath();
      ctx.fill();
    }
  }

  Item {
    id: contentWrapper
    anchors.top: parent.top
    anchors.topMargin: -20
    anchors.horizontalCenter: parent.horizontalCenter
    readonly property double h: rOut-rIn+40
    readonly property double w: parent.width
    readonly property double k: Math.max(h/thumb.implicitHeight, w/thumb.implicitWidth)
    width: thumb.implicitWidth*k
    height: thumb.implicitHeight*k

    KWin.WindowThumbnail {
      id: thumb
      anchors.fill:parent
      wId: windowId
      transform: [
        Rotation {
          angle: -piece.rotation
          origin.x: thumb.width/2
          origin.y: thumb.height/2
        }
      ]
    }

  }

  Kirigami.Icon {
    id: icon
    width: 24
    height: 24
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: rOut-rIn-50
    smooth: true
    antialiasing: true
    transform: Rotation {
      origin {
        x: icon.width/2
        y: icon.height/2
      }
      angle: -piece.rotation
    }
  }

}
