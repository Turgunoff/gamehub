// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Inter_18pt-Bold.ttf
  String get inter18ptBold => 'assets/fonts/Inter_18pt-Bold.ttf';

  /// File path: assets/fonts/Inter_18pt-ExtraBold.ttf
  String get inter18ptExtraBold => 'assets/fonts/Inter_18pt-ExtraBold.ttf';

  /// File path: assets/fonts/Inter_18pt-Medium.ttf
  String get inter18ptMedium => 'assets/fonts/Inter_18pt-Medium.ttf';

  /// File path: assets/fonts/Inter_18pt-Regular.ttf
  String get inter18ptRegular => 'assets/fonts/Inter_18pt-Regular.ttf';

  /// File path: assets/fonts/Inter_18pt-SemiBold.ttf
  String get inter18ptSemiBold => 'assets/fonts/Inter_18pt-SemiBold.ttf';

  /// File path: assets/fonts/Orbitron-Black.ttf
  String get orbitronBlack => 'assets/fonts/Orbitron-Black.ttf';

  /// File path: assets/fonts/Orbitron-Bold.ttf
  String get orbitronBold => 'assets/fonts/Orbitron-Bold.ttf';

  /// File path: assets/fonts/Orbitron-ExtraBold.ttf
  String get orbitronExtraBold => 'assets/fonts/Orbitron-ExtraBold.ttf';

  /// File path: assets/fonts/Orbitron-Medium.ttf
  String get orbitronMedium => 'assets/fonts/Orbitron-Medium.ttf';

  /// File path: assets/fonts/Orbitron-Regular.ttf
  String get orbitronRegular => 'assets/fonts/Orbitron-Regular.ttf';

  /// File path: assets/fonts/Orbitron-SemiBold.ttf
  String get orbitronSemiBold => 'assets/fonts/Orbitron-SemiBold.ttf';

  /// List of all assets
  List<String> get values => [
    inter18ptBold,
    inter18ptExtraBold,
    inter18ptMedium,
    inter18ptRegular,
    inter18ptSemiBold,
    orbitronBlack,
    orbitronBold,
    orbitronExtraBold,
    orbitronMedium,
    orbitronRegular,
    orbitronSemiBold,
  ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/add-circle.svg
  SvgGenImage get addCircle => const SvgGenImage('assets/icons/add-circle.svg');

  /// File path: assets/icons/cup.svg
  SvgGenImage get cup => const SvgGenImage('assets/icons/cup.svg');

  /// File path: assets/icons/home-2.svg
  SvgGenImage get home2 => const SvgGenImage('assets/icons/home-2.svg');

  /// File path: assets/icons/people.svg
  SvgGenImage get people => const SvgGenImage('assets/icons/people.svg');

  /// File path: assets/icons/profile-circle.svg
  SvgGenImage get profileCircle =>
      const SvgGenImage('assets/icons/profile-circle.svg');

  /// File path: assets/icons/setting-2.svg
  SvgGenImage get setting2 => const SvgGenImage('assets/icons/setting-2.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    addCircle,
    cup,
    home2,
    people,
    profileCircle,
    setting2,
  ];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/en.json
  String get en => 'assets/translations/en.json';

  /// File path: assets/translations/uz.json
  String get uz => 'assets/translations/uz.json';

  /// List of all assets
  List<String> get values => [en, uz];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
