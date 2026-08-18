import 'dart:async';

import 'package:flutter/material.dart';

/// Reveals [text] progressively, character by character, to simulate
/// the "reasoning streams in" UX from spec §5.5.
///
/// IMPORTANT ARCHITECTURAL NOTE: this is NOT real network streaming.
/// API Gateway (both REST v1 and HTTP v2) buffers the entire Lambda
/// response before delivering anything to the client -- there is no
/// partial-delivery path through that integration. True token-by-token
/// streaming from Lambda requires Function URLs with response-streaming
/// mode, a different invocation path entirely, bypassing API Gateway.
/// That's a real architecture change, not something we retrofit onto
/// the current REST-API-Gateway-backed deployment.
///
/// This widget delivers the same *perceived* benefit (the optimistic,
/// "content is arriving" feel) using data we already have in full by
/// the time we render it -- a client-side animation, not a network
/// optimization.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.charDelay = const Duration(milliseconds: 12),
    this.startDelay = const Duration(milliseconds: 300),
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final Duration charDelay;
  final Duration startDelay;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _visibleChars = 0;
  Timer? _startTimer;
  Timer? _charTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _visibleChars = 0;
      _startTimer?.cancel();
      _charTimer?.cancel();
      _start();
    }
  }

  void _start() {
    if (_startTimer?.isActive == true || _charTimer?.isActive == true) return;

    _startTimer?.cancel();
    _charTimer?.cancel();

    if (MediaQuery.of(context).disableAnimations) {
      if (_visibleChars != widget.text.length) {
        setState(() => _visibleChars = widget.text.length);
      }
      return;
    }

    // Short pause before the "reasoning" starts appearing -- mirrors
    // the spec's "renders immediately, reasoning streams in a moment
    // later" pattern, since poster/title are already visible by then.
    _startTimer = Timer(widget.startDelay, () {
      if (!mounted) return;
      _charTimer = Timer.periodic(widget.charDelay, (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _visibleChars++);
        if (_visibleChars >= widget.text.length) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _charTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect the system-level "reduce motion" accessibility setting --
    // show the full text immediately instead of animating it in.
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final visibleText = reduceMotion
        ? widget.text
        : widget.text.substring(0, _visibleChars.clamp(0, widget.text.length));

    return Text(
      visibleText,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
