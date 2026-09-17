import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Internal rendering boundary that maps a virtual design viewport to the
/// physical Flutter viewport with one uniform scale.
///
/// This type is intentionally not exported from the package's public library.
final class DesignScaleViewport extends SingleChildRenderObjectWidget {
  const DesignScaleViewport({
    super.key,
    required this.scale,
    required this.virtualSize,
    super.child,
  }) : assert(scale > 0);

  /// Uniform scale from virtual design coordinates to physical coordinates.
  final double scale;

  /// Tight layout size exposed to the child in virtual design coordinates.
  final Size virtualSize;

  @override
  RenderDesignScaleViewport createRenderObject(BuildContext context) {
    return RenderDesignScaleViewport(
      scale: scale,
      virtualSize: virtualSize,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDesignScaleViewport renderObject,
  ) {
    renderObject
      ..scale = scale
      ..virtualSize = virtualSize;
  }
}

/// Render object used by [DesignScaleViewport].
///
/// Layout happens in virtual coordinates. Painting, hit testing, coordinate
/// conversion, and semantics use the same transform so the child behaves as a
/// normal Flutter subtree from the application's perspective.
final class RenderDesignScaleViewport extends RenderProxyBox {
  RenderDesignScaleViewport({
    required double scale,
    required Size virtualSize,
    RenderBox? child,
  })  : _scale = _validateScale(scale),
        _virtualSize = _validateVirtualSize(virtualSize),
        super(child);

  double _scale;

  double get scale => _scale;

  set scale(double value) {
    final validated = _validateScale(value);
    if (validated == _scale) {
      return;
    }

    _scale = validated;
    markNeedsLayout();
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  Size _virtualSize;

  Size get virtualSize => _virtualSize;

  set virtualSize(Size value) {
    final validated = _validateVirtualSize(value);
    if (validated == _virtualSize) {
      return;
    }

    _virtualSize = validated;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  Size get _physicalSize {
    return Size(
      _virtualSize.width * _scale,
      _virtualSize.height * _scale,
    );
  }

  Matrix4 get _paintTransform {
    return Matrix4.diagonal3Values(_scale, _scale, 1);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(_physicalSize);
  }

  @override
  void performLayout() {
    size = constraints.constrain(_physicalSize);

    final child = this.child;
    if (child == null) {
      return;
    }

    child.layout(BoxConstraints.tight(_virtualSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }

    context.pushTransform(
      needsCompositing,
      offset,
      _paintTransform,
      super.paint,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _paintTransform,
      position: position,
      hitTest: (result, transformedPosition) {
        return super.hitTestChildren(
          result,
          position: transformedPosition,
        );
      },
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_paintTransform);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final childDistance = child?.getDistanceToActualBaseline(baseline);
    if (childDistance == null) {
      return null;
    }

    return childDistance * _scale;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final child = this.child;
    if (child == null) {
      return 0;
    }

    final virtualHeight = height.isFinite ? height / _scale : height;
    return child.getMinIntrinsicWidth(virtualHeight) * _scale;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final child = this.child;
    if (child == null) {
      return 0;
    }

    final virtualHeight = height.isFinite ? height / _scale : height;
    return child.getMaxIntrinsicWidth(virtualHeight) * _scale;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final child = this.child;
    if (child == null) {
      return 0;
    }

    final virtualWidth = width.isFinite ? width / _scale : width;
    return child.getMinIntrinsicHeight(virtualWidth) * _scale;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final child = this.child;
    if (child == null) {
      return 0;
    }

    final virtualWidth = width.isFinite ? width / _scale : width;
    return child.getMaxIntrinsicHeight(virtualWidth) * _scale;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('scale', _scale))
      ..add(DiagnosticsProperty<Size>('virtualSize', _virtualSize))
      ..add(DiagnosticsProperty<Size>('physicalSize', _physicalSize));
  }

  static double _validateScale(double value) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
        value,
        'scale',
        'must be finite and greater than zero',
      );
    }

    return value;
  }

  static Size _validateVirtualSize(Size value) {
    final isValid = value.width.isFinite &&
        value.height.isFinite &&
        value.width > 0 &&
        value.height > 0;

    if (!isValid) {
      throw ArgumentError.value(
        value,
        'virtualSize',
        'must contain finite dimensions greater than zero',
      );
    }

    return value;
  }
}
