// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

String? webReadToken(String key) => html.window.localStorage[key];

void webWriteToken(String key, String value) =>
    html.window.localStorage[key] = value;

void webClearToken(String key) => html.window.localStorage.remove(key);
