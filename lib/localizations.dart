import 'dart:async';

import 'package:chat_sotatek/l10n/messages_all.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
    locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get titleHome {
    return Intl.message('Home',
        name: 'titleHome', desc: 'The home title');
  }

  String get textLoginButtonGoogle {
    return Intl.message('Sign in with Google', name: 'textLoginButtonGoogle');
  }

  String get searchPlaceHolder {
    return Intl.message('Search', name: 'searchPlaceHolder');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi', 'in'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}