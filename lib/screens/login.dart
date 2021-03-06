import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:likekanban/blocs/auth_bloc.dart';
import 'package:likekanban/styles/colors.dart';
import 'package:likekanban/widgets/button.dart';
import 'package:likekanban/widgets/textfield.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Locale _currentLang;
  StreamSubscription _userChangedSubscription;
  StreamSubscription _errorMessageSubscription;

  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);
    // got user -> home screen
    _userChangedSubscription = authBloc.user.listen((user) {
      if (user != null) Navigator.pushReplacementNamed(context, '/home');
    });
    // got error message -> show
    _errorMessageSubscription = authBloc.errorMessage.listen((message) {
      if (message.isNotEmpty) print(message); // showDialog??
    });
    super.initState();
    Future.delayed(Duration.zero, () async {
      setState(() {
        _currentLang = FlutterI18n.currentLocale(context);
      });
    });
  }

  changeLanguage() async {
    _currentLang =
        _currentLang.languageCode == 'en' ? Locale('ru') : Locale('en');
    await FlutterI18n.refresh(context, _currentLang);
    setState(() {});
  }

  @override
  void dispose() {
    _userChangedSubscription.cancel();
    _errorMessageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanban'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10.0,
            ),
            child: Ink(
              decoration: ShapeDecoration(
                color: BaseColors.smoke,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: Icon(Icons.language),
                onPressed: changeLanguage,
                color: BaseColors.pureWhite,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<String>(
              stream: authBloc.userName,
              builder: (context, snapshot) {
                return ExtendedTextField(
                  hintText:
                      FlutterI18n.translate(context, "textfield.login.hint"),
                  textInputType: TextInputType.text,
                  errorText:
                      FlutterI18n.translate(context, "textfield.login.error"),
                  onChanged: authBloc.changeUserName,
                );
              }),
          StreamBuilder<String>(
              stream: authBloc.password,
              builder: (context, snapshot) {
                return ExtendedTextField(
                  hintText:
                      FlutterI18n.translate(context, "textfield.password.hint"),
                  obscureText: true,
                  errorText: FlutterI18n.translate(
                      context, "textfield.password.error"),
                  onChanged: authBloc.changePassword,
                );
              }),
          StreamBuilder<bool>(
              stream: authBloc.isValid,
              builder: (context, snapshot) {
                return ExtendedButton(
                  buttonText:
                      FlutterI18n.translate(context, "button.login.enter"),
                  buttonType: (snapshot.data == true)
                      ? ButtonType.Enabled
                      : ButtonType.Disabled,
                  onPressed: authBloc.login,
                );
              }),
        ],
      ),
    );
  }
}
