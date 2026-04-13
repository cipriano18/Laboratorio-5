import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final VoidCallback onChanged;
  final bool enabled;

  const OtpInputField({
    super.key,
    required this.length,
    required this.onCompleted,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (widget.enabled && mounted) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  /// Rellena automáticamente las cajas con el código recibido (SMS autofill).
  void fillCode(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    final len = min(digits.length, widget.length);
    for (int i = 0; i < len; i++) {
      _controllers[i].text = digits[i];
    }
    widget.onChanged();
    if (digits.length >= widget.length) {
      _focusNodes.last.unfocus();
      widget.onCompleted(digits.substring(0, widget.length));
    }
  }

  String get currentValue => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double margin = 5;
        final double boxWidth =
            ((constraints.maxWidth - widget.length * margin * 2) / widget.length)
                .clamp(36.0, 52.0);
        final double boxHeight = boxWidth * 1.2;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (i) {
            return Container(
              width: boxWidth,
              height: boxHeight,
              margin: const EdgeInsets.symmetric(horizontal: margin),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _controllers[i].text.isEmpty &&
                  i > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
                _controllers[i - 1].clear();
                widget.onChanged();
              }
            },
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: widget.enabled
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 2.5),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (i < widget.length - 1) {
                    FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                  } else {
                    _focusNodes[i].unfocus();
                  }
                }
                widget.onChanged();
                final full = currentValue;
                if (full.length == widget.length) {
                  widget.onCompleted(full);
                }
              },
            ),
          ),
        );
      }),
        );
      },
    );
  }
}
