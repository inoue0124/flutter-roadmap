import 'package:flutter/material.dart';

class Node {
  List<Node> children;
  String value;
  Rect? rect;
  Size visialSize = const Size(0, 0);
  NodeType type;
  bool isInProgress = false;

  Node({
    required this.value,
    required this.type,
    this.isInProgress = false,
    required this.children,
  });
}

enum NodeType { root, main, detail }

Node? depthFirstSearch(Node? node, bool Function(Node n) predicate) {
  if (node == null) {
    return null;
  }
  if (predicate(node)) {
    return node;
  }
  for (var child in node.children) {
    var result = depthFirstSearch(child, predicate);
    if (result != null) {
      return result;
    }
  }
  return null;
}
