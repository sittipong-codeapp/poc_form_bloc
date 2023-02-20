import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<LoginFormBloc>(
        create: (context) => LoginFormBloc(),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<LoginFormBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FormBlocListener<LoginFormBloc, String, String>(
        onSubmitting: (context, state) {
          LoadingDialog.show(context);
        },
        onSubmissionFailed: (context, state) {
          LoadingDialog.hide(context);
        },
        onSuccess: (context, state) {
          LoadingDialog.hide(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged-in!'),
            ),
          );
        },
        onFailure: (context, state) {
          LoadingDialog.hide(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failureResponse!),
            ),
          );
        },
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              children: [
                TextFieldBlocBuilder(
                  textFieldBloc: formBloc.email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                TextFieldBlocBuilder(
                  textFieldBloc: formBloc.password,
                  suffixButton: SuffixButton.obscureText,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: CheckboxFieldBlocBuilder(
                    booleanFieldBloc: formBloc.showSuccessResponse,
                    body: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text('Show success response'),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: formBloc.submit,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFormBloc extends FormBloc<String, String> {
  LoginFormBloc() {
    addFieldBlocs(
      fieldBlocs: [email, password, showSuccessResponse],
    );
  }

  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final showSuccessResponse = BooleanFieldBloc();

  @override
  FutureOr<void> onSubmitting() async {
    final email = this.email.value;
    final password = this.password.value;
    final showSuccessResponse = this.showSuccessResponse.value;

    print(email);
    print(password);
    print(showSuccessResponse);

    await Future<void>.delayed(const Duration(seconds: 1));

    if (showSuccessResponse) {
      emitSuccess();
    } else {
      emitFailure(failureResponse: 'This is an awesome error!');
    }
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(12.0),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
