import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/authorization_page/authorization_bloc.dart';
import 'package:todointernship/data/theme_list_data.dart';
import 'package:todointernship/pages/category_list_page/category_list_page.dart';

class AuthorizationPage extends StatefulWidget {
  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {

  TextEditingController _loginTextController;
  TextEditingController _passwordTextController;
  AuthorizationBloc _authorizationBloc;

  @override
  void initState() {
    super.initState();
    _authorizationBloc = AuthorizationBloc(
      Injector.appInstance.getDependency<FirebaseAuth>()
    );
    _loginTextController = TextEditingController();
    _passwordTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authorizationBloc,
      child: BlocBuilder(
        bloc: _authorizationBloc,
        builder: (context, state) {
          if(state is TryAuthorizationState) {
            return Scaffold(
              backgroundColor: Color(ThemeListData.all.mainTheme.backgroundColor),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if(state is AuthorizationSuccessState) {
            return CategoryListPage();
          }
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: Color(ThemeListData.all.mainTheme.backgroundColor),
            body: Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: _LoginForm(
                        obscureText: false,
                        controller: _loginTextController,
                        text: 'Логин',
                        iconData: Icons.person,
                      ),
                    ),
                    Spacer(flex: 1),
                    Expanded(
                      flex: 3,
                      child: _LoginForm(
                        obscureText: true,
                        controller: _passwordTextController,
                        text: 'Пароль',
                        iconData: Icons.input,
                      ),
                    ),
                    Spacer(flex: 1),
                    Expanded(
                      flex: 3,
                      child: _LoginButton(
                        title: 'Войти',
                        onTap: _signIn,
                      )
                    ),
                    Spacer(flex: 1),
                    Expanded(
                        flex: 3,
                        child: _LoginButton(
                          title: 'Зарегестрироваться',
                          onTap: _signUp,
                        )
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    _authorizationBloc.close();
    _passwordTextController.dispose();
    _loginTextController.dispose();
    super.dispose();
  }

  void _signUp() {
    _authorizationBloc.add(SignUpEvent(
      _loginTextController.text,
      _passwordTextController.text
    ));
  }

  void _signIn() {
    _authorizationBloc.add(SignInEvent(
      _loginTextController.text,
      _passwordTextController.text
    ));
  }
  
}

class _LoginForm extends StatelessWidget {

  final IconData iconData;
  final String text;
  final TextEditingController controller;
  final bool obscureText;

  _LoginForm({this.iconData, this.text, this.controller, this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
          labelText: text,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(ThemeListData.all.mainTheme.primaryColor))
          ),
        icon: Icon(iconData),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {

  final String title;
  final VoidCallback onTap;

  _LoginButton({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(ThemeListData.all.mainTheme.primaryColor),
          borderRadius: BorderRadius.circular(50)
        ),
        child: SizedBox.expand(
            child: Align(
                alignment: Alignment.center,
                child: Text(title,
                  style: TextStyle(
                    color: Colors.white
                  ),
                )
            )
        ),
      ),
    );
  }


}
