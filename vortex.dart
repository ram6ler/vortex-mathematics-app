import "dart:html";
import "dart:math" as math;

final width = 800,
    canvas = CanvasElement(width: width, height: width),
    buffer = CanvasElement(width: width, height: width),
    canvasContext = canvas.context2D,
    bufferContext = buffer.context2D;

void drawVortex(int multiplier, int modulus) {
  final midX = width / 2,
      midY = width / 2,
      padding = 40,
      pointRadius = width / 2 - padding,
      x = (num r, int index) =>
          (r * math.cos(index * math.pi * 2 / modulus - math.pi / 2)).toInt(),
      y = (num r, int index) =>
          (r * math.sin(index * math.pi * 2 / modulus - math.pi / 2)).toInt();

  bufferContext
    ..save()
    ..fillStyle = "white"
    ..fillRect(0, 0, width, width)
    ..translate(midX, midY);

  final allIndices = {for (var i = 0; i < modulus - 1; i++) i + 1};

  while (allIndices.length > 0) {
    bufferContext.beginPath();
    final indices = <int>[];
    var n = allIndices.first;

    while (!indices.contains(n)) {
      indices.add(n);
      allIndices.remove(n);
      n = (n * multiplier) % modulus;
    }

    bufferContext
      ..strokeStyle = "slateblue"
      ..lineWidth = 1
      ..moveTo(x(pointRadius, indices[0]), y(pointRadius, indices[0]));

    for (var i = 1; i < indices.length; i++) {
      final index = indices[i % indices.length];
      bufferContext.lineTo(x(pointRadius, index), y(pointRadius, index));
    }
    bufferContext
      ..closePath()
      ..stroke();
  }
  bufferContext
    ..strokeStyle = "lightgray"
    ..beginPath()
    ..arc(0, 0, pointRadius, 0, math.pi * 2)
    ..stroke();

  final every = modulus ~/ 50;
  for (var i = 0; i < modulus; i++) {
    if (every == 0 || i % every == 0) {
      bufferContext
        ..font = "12pt Arial"
        ..textAlign = "center"
        ..textBaseline = "middle"
        ..fillStyle = "darkgray"
        ..fillText("$i", x(pointRadius + padding / 2, i),
            y(pointRadius + padding * 0.8, i));
    }

    bufferContext
      ..fillStyle = "slateblue"
      ..beginPath()
      ..arc(x(pointRadius, i), y(pointRadius, i), 3, 0, math.pi * 2)
      ..fill();
  }

  bufferContext.restore();
  canvasContext.drawImage(buffer, 0, 0);
}

main() {
  final multiplierInput = querySelector("#multiplier") as InputElement,
      multiplierValue = querySelector("#multiplier-value") as InputElement,
      modulusInput = querySelector("#modulus") as InputElement,
      modulusValue = querySelector('#modulus-value') as InputElement,
      output = querySelector("#output") as DivElement;

  output.children.add(canvas);

  void updateDrawing() {
    multiplierValue.value = "${multiplierInput.value}";
    modulusValue.value = "${modulusInput.value}";
    final sMultiplier = multiplierInput.value, sModulus = modulusInput.value;
    if (sMultiplier != null && sModulus != null) {
      final multiplier = int.tryParse(sMultiplier),
          modulus = int.tryParse(sModulus);
      if (multiplier != null && modulus != null) {
        drawVortex(multiplier, modulus);
      }
    }
  }

  multiplierInput.onInput.listen((event) {
    updateDrawing();
  });
  multiplierValue.onChange.listen((event) {
    multiplierInput.value = multiplierValue.value;
    updateDrawing();
  });

  modulusInput.onInput.listen((event) {
    updateDrawing();
  });
  modulusValue.onChange.listen((event) {
    modulusInput.value = modulusValue.value;
    updateDrawing();
  });

  updateDrawing();
}
