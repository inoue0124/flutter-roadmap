import 'package:flutter/material.dart';
import 'package:graph/node.dart';

class RoadMapPainter extends CustomPainter {
  final Node tree;
  final Offset canvasStart;
  final double canvasScale;

  static const cellW = 150.0;
  static const cellH = 52.0;
  static const padding = 16.0;
  static const branchPadding = 170.0;

  static final linePaint = Paint()
    ..color = const Color(0xFFFF6913)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  static final dotPaint = Paint()
    ..color = const Color(0xFFFF6913)
    ..style = PaintingStyle.fill;

  static final borderPaint = Paint()
    ..color = const Color(0xFFFF6913)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  static final fillPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  static final fillPaintInProgress = Paint()
    ..color = const Color(0xFFFFEBDF)
    ..style = PaintingStyle.fill;

  RoadMapPainter({
    required this.tree,
    required this.canvasStart,
    required this.canvasScale,
  });

  @override
  bool shouldRepaint(covariant RoadMapPainter oldDelegate) {
    return oldDelegate.tree != tree ||
        oldDelegate.canvasStart != canvasStart ||
        oldDelegate.canvasScale != canvasScale;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(canvasScale, canvasScale);
    drawCells(canvas, size);
  }

  void drawCells(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 100) + canvasStart;
    measureCell(tree);
    drawCell(canvas, center, tree, false);
  }

  void drawCell(Canvas canvas, Offset center, Node node, bool hasSibling) {
    final cellCenter =
        Offset(center.dx + padding + cellW / 2, center.dy + padding / 2);

    final rect = Rect.fromCenter(
      center: cellCenter,
      width: cellW.toDouble(),
      height: cellH.toDouble(),
    );
    node.rect = rect;

    // ノードの種類がdetailでない場合、角丸四角形を描画
    if (node.type != NodeType.detail) {
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      if (node.isInProgress) {
        canvas.drawRRect(rrect, borderPaint);
      }
      canvas.drawRRect(
          rrect, node.isInProgress ? fillPaintInProgress : fillPaint);
    }

    // ノードの種類がrootでない場合、線を描画
    if (node.type != NodeType.root && !hasSibling) {
      canvas.drawLine(
        Offset(center.dx, center.dy),
        Offset(center.dx, center.dy - cellH),
        linePaint,
      );
    }

    // ドットを描画
    canvas.drawCircle(
      Offset(center.dx, center.dy + padding / 2),
      4,
      dotPaint,
    );

    // テキストを描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.value,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + padding * 2, center.dy));

    // 子ノードがない場合は、ここで終了
    final children = node.children;
    if (children.isEmpty) {
      return;
    }

    // 子ノードがある場合は、それらを描画
    final totalWidth = node.visialSize.width;
    final count = node.children.length;
    final distance = cellH + padding + (count >= 2 ? 100 : 0);
    var pos = Offset(-totalWidth / 2, distance);
    bool lineFromParentDrawn = false;
    for (var n in node.children) {
      final sz = n.visialSize;
      final vD = Offset(sz.width + branchPadding, 0);
      var c = center + pos + Offset(sz.width / 2, sz.height);
      drawCell(canvas, c, n, count >= 2);

      if (count >= 2) {
        if (!lineFromParentDrawn) {
          // 子ノードが複数あり、親ノードからの下向きの直線を一度だけ描画する
          canvas.drawLine(
            Offset(center.dx, center.dy + padding),
            Offset(center.dx, center.dy + cellH / 2),
            linePaint,
          );
          lineFromParentDrawn = true;
        }

        final path = Path();
        path.moveTo(c.dx, c.dy - sz.height / 2); // 子ノードの上部から始まる
        path.lineTo(c.dx, center.dy + cellH * 2); // 子ノードから直線を引く

        // Bezier曲線を描くための制御点と終点を設定
        final controlPoint1 = Offset(c.dx, center.dy + cellH / 2 + padding);
        final controlPoint2 = Offset(center.dx, center.dy + cellH + padding);
        final endPoint = Offset(center.dx, center.dy + cellH / 2);

        // Bezier曲線を描く
        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
            controlPoint2.dy, endPoint.dx, endPoint.dy);
        canvas.drawPath(path, linePaint);
      }
      pos += vD;
    }
  }

  Size measureCell(Node? node) {
    if (node == null) {
      return const Size(0, 0);
    }

    var subTreeSize = const Size(0, 0);
    for (var n in node.children) {
      final sz = measureCell(n);
      subTreeSize = Size(subTreeSize.width + sz.width, subTreeSize.height);
    }

    final count = node.children.length;
    subTreeSize = Size(
      subTreeSize.width + (count - 1) * branchPadding,
      subTreeSize.height,
    );
    final width = subTreeSize.width > cellW ? subTreeSize.width : cellW;
    node.visialSize = Size(width, subTreeSize.height);

    return node.visialSize;
  }
}
