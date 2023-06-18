import 'package:flutter/material.dart';
import 'package:graph/node.dart';
import 'package:graph/roadmap_painter.dart';

class RoadMapWidget extends StatefulWidget {
  final void Function(Node)? onSelectNode;

  const RoadMapWidget({Key? key, this.onSelectNode}) : super(key: key);

  @override
  RoadMapWidgetState createState() => RoadMapWidgetState();
}

class RoadMapWidgetState extends State<RoadMapWidget> {
  final tree =
      Node(value: "Root", type: NodeType.root, isInProgress: true, children: [
    Node(value: "Child 1", type: NodeType.detail, children: [
      Node(value: "Child 1.1", type: NodeType.detail, children: [
        Node(
            value: "Child 1.1.1",
            type: NodeType.main,
            isInProgress: true,
            children: [
              Node(value: "Child 1.1.1.1", type: NodeType.detail, children: []),
            ]),
        Node(value: "Child 1.1.2", type: NodeType.main, children: [])
      ])
    ])
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: handleOnTapUp,
        onScaleStart: handleScaleStart,
        onScaleEnd: handleScaleEnd,
        onScaleUpdate: handleScaleUpdate,
        child: CustomPaint(
          painter: RoadMapPainter(
            tree: tree,
            canvasStart: canvasStart,
            canvasScale: scale,
          ),
          child: Container(),
        ),
      ),
    );
  }

  void handleOnTapUp(TapUpDetails details) {
    var node = depthFirstSearch(tree, (Node n) {
      final inside = n.rect?.contains(details.localPosition);
      return inside ?? false;
    });

    // Call the provided callback when a node is tapped.
    if (node != null && widget.onSelectNode != null) {
      widget.onSelectNode!(node);
    }
  }

  void handleScaleStart(ScaleStartDetails details) {
    prevFocalPoint = details.focalPoint;
    prevScale = scale;
  }

  void handleScaleEnd(ScaleEndDetails details) {
    prevFocalPoint = null;
    prevScale = null;
  }

  Offset canvasStart = const Offset(0, 0);
  double scale = 1.0;
  double? prevScale;
  Offset? prevFocalPoint;
  void handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      const double zoomSpeed = 0.05;
      const double minScale = 1;
      const double maxScale = 2.0;

      // スケールの変化量を計算します。
      double scaleChange = 1.0 + (details.scale - 1.0) * zoomSpeed;

      // 新しいスケール値を計算します。これは前回のスケールにスケールの変化量を掛けたものです。
      double newScale = prevScale! * scaleChange;

      // 新しいスケールが設定した最小値・最大値を超えないように調整します。
      newScale = newScale.clamp(minScale, maxScale);

      // ズームの中心点に合わせてcanvasの開始位置を調整します。
      Offset newCanvasStart =
          canvasStart + (details.focalPoint - prevFocalPoint!) * scaleChange;

      prevFocalPoint = details.focalPoint;
      prevScale = newScale;
      scale = newScale;
      canvasStart = newCanvasStart;
    });
  }
}
