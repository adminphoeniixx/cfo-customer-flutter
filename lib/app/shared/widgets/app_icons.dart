import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Raw SVG path data copied verbatim from the prototype ("customer-app 1.html")
/// so that in-app icons are pixel-identical to the design source of truth,
/// rather than approximated with Material Icons.
class AppSvgIcons {
  AppSvgIcons._();

  static const search =
      '<svg viewBox="0 0 20 20"><path d="M8.5 3a5.5 5.5 0 014.38 8.84l3.64 3.64-1.04 1.04-3.64-3.64A5.5 5.5 0 118.5 3zm0 1.5a4 4 0 100 8 4 4 0 000-8z"/></svg>';

  static const heart =
      '<svg viewBox="0 0 20 20"><path d="M10 17s-6.5-4.2-6.5-8.3A3.7 3.7 0 0110 6.4a3.7 3.7 0 016.5 2.3C16.5 12.8 10 17 10 17z"/></svg>';

  static const bag =
      '<svg viewBox="0 0 20 20"><path d="M2 3h2.2l.7 2.6h11.4a1 1 0 01.97 1.25l-1.4 5.2A1.4 1.4 0 0114.5 13H7.2l.3 1.2h8.2v1.5H6.9a1.2 1.2 0 01-1.16-.9L3.2 4.5H2V3zm5 13.2a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4zm7.6 0a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4z"/></svg>';

  static const bell =
      '<svg viewBox="0 0 20 20"><path d="M10 2a5 5 0 00-5 5v3.2l-1.3 2.3A1 1 0 004.6 14h10.8a1 1 0 00.9-1.5L15 10.2V7a5 5 0 00-5-5zm0 15a2.5 2.5 0 002.4-2h-4.8A2.5 2.5 0 0010 17z"/></svg>';

  static const navHome =
      '<svg viewBox="0 0 20 20"><path d="M10 2.5l7 6V17a1 1 0 01-1 1h-4v-5H8v5H4a1 1 0 01-1-1V8.5l7-6z"/></svg>';

  static const navCategories =
      '<svg viewBox="0 0 20 20"><path d="M3 3h6v6H3V3zm8 0h6v6h-6V3zM3 11h6v6H3v-6zm8 0h6v6h-6v-6z"/></svg>';

  static const navOrders =
      '<svg viewBox="0 0 20 20"><path d="M4 3h12a1 1 0 011 1v3H3V4a1 1 0 011-1zm-1 6h14v7a1 1 0 01-1 1H4a1 1 0 01-1-1V9zm4 2v2h6v-2H7z"/></svg>';

  static const navCart = bag;

  static const navAccount =
      '<svg viewBox="0 0 20 20"><path d="M10 10a3.5 3.5 0 100-7 3.5 3.5 0 000 7zm0 1.6c-3 0-6 1.5-6 3.4V18h12v-3c0-1.9-3-3.4-6-3.4z"/></svg>';
}

/// Renders one of the prototype's inline SVGs, tinted via [color].
class AppIcon extends StatelessWidget {
  const AppIcon(this.svg, {super.key, this.size = 20, this.color});

  final String svg;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
