import QtQuick

Rectangle {
  id: pie
  color: "transparent"

  property alias model: pices.model
  property double ringHeight: 220
  property double inRadius: 40
  property int current: -1 //-- Индекс активного куска
  property double zoom: 50 //-- На сколько увеличивать центральный угол при наведении
  property var ringPieces: {[]} //-- Сколько итемов показывать в каждом кольце. В последнем кольце будут все, кто не влез.
  property double ringSpacing: 10 //-- Расстояние между кольцами
  readonly property int ringsCount: _private.ringPieces.length //-- Сколько фактически колец
  property alias bg: bg

  signal mousePositionChanged(var mouse);
  signal clicked(var mouse);

  implicitHeight: inRadius*2+(ringHeight+ringSpacing)*ringsCount*2
  implicitWidth: implicitHeight

  QtObject {
    id: _private
    property var pieceToRing: ([]) //-- Какой кусок какому кольцу принадлежит
    property var ringPieces: {[]} //-- Сколько фактически итемов в каждом кольце
    property var idxsInRing: {[]} //-- Индекс относительно кольца

    /**
    * @brief Обновляем @see pieceToRing, @see ringPieces, @see idxsInRing
    */
    function updateData() {
      let pr =[0], rp =[0], ir =[0];
      for (let i=0, summ =0, j =0, ring =0; i<pices.count; ++i, ++j) {
        if ( ring<pie.ringPieces.length && i>=summ+pie.ringPieces[ring] ) { summ +=pie.ringPieces[ring]; ring++; rp[ring] =0; j =0; }
        pr[i] =ring;
        ir[i] =j;
        rp[ring]++;
      }
      _private.pieceToRing =pr;
      _private.ringPieces =rp;
      _private.idxsInRing =ir;
      return [pr, rp];
    }
  }

  onRingPiecesChanged: {
    _private.updateData();
  }

  /**
  * @brief Определяем кусок по координатам
  * @note Без учёта промежутков, что бы не дёргалось
  */
  function getPieIdx(x, y) {
    const tx =x-width/2;
    const ty =y-height/2;
    const d =tx*tx+ty*ty;    
    let mouseAngle =(Math.atan2(tx, -ty)*180.0/Math.PI+360)%360; //-- Угол курсора в градусах относительно центра
    let newCurrentIdx =-1;
    for (let i=0; i<pices.count; ++i) {
      const itm =pices.itemAt(i);
      if ( d<itm.rIn*itm.rIn || d>itm.rOut*itm.rOut ) { continue; }
      const startAngle =itm.rotation-itm.angle/2.0;
      const endAngle =itm.rotation+itm.angle/2.0;
      if ( startAngle<0 || endAngle>360 ) {
        if ( (mouseAngle>=(startAngle+360)%360 || mouseAngle<(endAngle%360)) )  { return i; }
      } else {
        if ( mouseAngle>=startAngle && mouseAngle<endAngle ) { return i; }
      }
    }
    return -1;
  }

  /**
  * @brief
  */
  function updateData() {
    _private.updateData();
  }

  MouseArea {
    id: mouseHandler
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true

    Rectangle {
      id: bg
      anchors.fill: parent
      radius: width/2
      color: "transparent"
    }

    onClicked: (mouse)=>{
      pie.clicked(mouse);
    }

    onPositionChanged: (mouse) => {
      mouse.accepted =false;
      mousePositionChanged(mouse);
      if ( !containsMouse ) { return; }
      pie.current =getPieIdx(mouse.x, mouse.y);
    }

    onContainsMouseChanged: {
      if ( !containsMouse ) { pie.current =-1; }
    }

    Repeater {
      id: pices

      onModelChanged: {
        _private.updateData();
      }

      Component.onCompleted: {
        _private.updateData();
      }

      delegate: Piece {
        id: pieceDelegate

        readonly property int ringIdx: _private.pieceToRing[index]
        readonly property int piecesInRing: _private.ringPieces[ringIdx]
        readonly property int idxInRing: _private.idxsInRing[index]
        readonly property int idxCurrentInRing: (pie.current<0)? -1 : _private.idxsInRing[pie.current]

        readonly property double centralAngle: 360.0/piecesInRing //-- Центральный угол всех кусков в кольце
        readonly property double b: pie.zoom/(piecesInRing-1) //-- Поворот всех остальных в кольце из-за зума выбранного
        readonly property double b2: b/2.0
        readonly property bool currentInThisRing: (pie.current>=0 && _private.pieceToRing[pie.current]===ringIdx)

        rIn: pie.inRadius+((pie.ringHeight+pie.ringSpacing)*ringIdx)
        rOut: rIn+pie.ringHeight
        offset: 0.8*piecesInRing
        angle: (!currentInThisRing)? centralAngle : centralAngle+pie.zoom/(pie.current===index? 1 : -piecesInRing+1)
        x: pie.width/2-width/2
        y: pie.height/2-height
        rotation: (pie.current==index || !currentInThisRing)?
          (idxInRing*centralAngle):
          (idxInRing*centralAngle-idxInRing*pie.zoom/(piecesInRing-1) + (index>pie.current? (pie.zoom/2.0+b*idxCurrentInRing+b2) : -(pie.zoom/2.0-b*idxCurrentInRing+b2)));

        icon.source: model.icon

        Behavior on angle {
          NumberAnimation { duration: 100; }
        }

        Behavior on rotation {
          NumberAnimation { duration: 100; }
        }
      }
    }
  }
}
