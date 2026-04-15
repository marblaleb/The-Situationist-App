// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void redirectBrowser(String url) => html.window.location.assign(url);

String getWebOrigin() => html.window.location.origin;
