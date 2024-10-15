import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../auth.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SignUpApp());
}

class SignUpApp extends StatelessWidget {
  const SignUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const SignUpScreen(),
      },
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(234, 238, 183, 132),
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _dateOfBirthTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  //final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _passwordConfirmTextController = TextEditingController();
  final _passwordsMatchTextController = TextEditingController();
  var roles = [
    'Role',
    'Animal Lover',
    'NGO Representative',
    'Looking to Adopt',
    'Dog Feeder',
    'Veterinarian',
  ];
  String dropdownvalue = 'Role';
  String? errorMessage = '';

  @override

  // Set the state of the two password fields.
  void initState() {
    super.initState();
    _passwordTextController.addListener(passwordChecker);
    _passwordConfirmTextController.addListener(passwordChecker);
    _passwordConfirmTextController.addListener(() {
      setState(() {});
    });
  }

  // Checks if all fields have been properly filled.
  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [
      _firstNameTextController,
      _lastNameTextController,
      _emailTextController,
      _passwordTextController,
      _passwordConfirmTextController
    ];

    for (final controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
    });
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Returns true if the password fields match, otherise returns false.
  bool passwordChecker() {
    if (_passwordTextController.text == _passwordConfirmTextController.text) {
      print("Passwords Match!");
      _passwordsMatchTextController.text = "";
      return true;
    } else {
      print("Password Do Not Match!");
      _passwordsMatchTextController.text = "Passwords do not match!";
      return false;
    }
  }

  onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(2015),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    _dateOfBirthTextController.text =
        DateFormat('yyyy-MM-dd').format(pickedDate);
  }

  double _formProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Create Your Account',
                style: Theme.of(context).textTheme.headlineMedium),
          ),

          // First name text entry.
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _firstNameTextController,
              decoration: const InputDecoration(hintText: 'First name'),
            ),
          ),

          // Last name text entry.
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _lastNameTextController,
              decoration: const InputDecoration(hintText: 'Last name'),
            ),
          ),

          // Date of birth text entry.
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _dateOfBirthTextController,
              decoration: const InputDecoration(
                  hintText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today)),
              onTap: () => onTapFunction(context: context),
            ),
          ),

          // Email of birth text entry.
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _emailTextController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
          ),

          // Selection of role.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButton(
                  value: dropdownvalue,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: roles.map((String roles) {
                    return DropdownMenuItem(
                      value: roles,
                      child: Text(roles),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),

          // Passord text entry.
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _passwordTextController,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
          ),

          // Passord confirm text entry.
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _passwordConfirmTextController,
              decoration: const InputDecoration(hintText: 'Confirm Password'),
            ),
          ),

          // Passwords match text.
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_passwordsMatchTextController.text,
                style: const TextStyle(
                  fontSize: 20,
                )),
          ),

          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.disabled)
                    ? null
                    : Colors.white;
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.disabled)
                    ? null
                    : Colors.blue;
              }),
            ),
            onPressed: (_formProgress == 1) && passwordChecker()
                ? createUserWithEmailAndPassword
                : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }
}