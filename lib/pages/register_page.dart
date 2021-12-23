//Packages
import 'dart:io';

import 'package:chatify_app/services/shared_preference_function.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//Providers
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService _navigation;


  String? _email;
  String? _password;
  String? _name;
  PlatformFile? _profileImage;
  late File urlFile;
  final _registerFormKey = GlobalKey<FormState>();
  bool? photoAdded;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profileImageField(),
            Visibility(
                visible: photoAdded == false,
                child:Text('Add Profile Photo',style: TextStyle(color: Colors.red,fontSize: 10),)
            ),
            SizedBox(
              height: _deviceHeight * 0.05,
            ),
            _registerForm(),
            SizedBox(
              height: _deviceHeight * 0.04,
            ),
            _registerButton(),
            SizedBox(
              height: _deviceHeight * 0.01,
            ),
            _loginLink(),
          ],
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
          (_file) {
            setState(
              () {
                _profileImage = _file;
                if(_profileImage != null && _profileImage!.path != ''){
                  photoAdded = true;
                }
                print('assigned' + _profileImage.toString());
              },
            );
          },
        );
      },
      child: () {
        if (_profileImage != null) {
          return
            CircleAvatar(
                radius: 50,
                backgroundImage: FileImage( File(_profileImage!.path.toString())),
            );
        } else {
          return CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://cdn.icon-icons.com/icons2/1674/PNG/512/person_110935.png'),
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _name = _value;

                  });
                },
                regEx: r'.{5,}',
                hintText: "Name",
                obscureText: false),
            CustomTextFormField(
              textInputType: TextInputType.emailAddress,
                onSaved: (_value) {
                  setState(() {
                    _email = _value;
                  });
                },
                regEx:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: "Email",
                obscureText: false),
            CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _password = _value;
                  });
                },
                regEx: r".{8,}",
                hintText: "Password",
                obscureText: false),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return
      ElevatedButton(
        onPressed: () async {
          if (_registerFormKey.currentState!.validate() &&
              _profileImage != null) {

            _registerFormKey.currentState!.save();

            String? _uid = await _auth.registerUserUsingEmailAndPassword(
                _email!, _password!);
            String? _imageURL =
            await _cloudStorage.saveUserImageToStorage(_uid!, _profileImage!);
            await _db.createUser(_uid, _email!, _name!, _imageURL!);
            SharedPreferenceFunctions.saveUserLoggedInSharedPreference(true);
            SharedPreferenceFunctions.saveUserEmailSharedPreference(
                _email!);
            SharedPreferenceFunctions.saveUserNameSharedPreference(
                _name!);
            SharedPreferenceFunctions.saveUserImageSharedPreference(
                _imageURL);
            print(_imageURL);
            _navigation.navigateToRoute('/home');
            setState(() {
              photoAdded=true;
            });
          }
          else{
            setState(() {
              photoAdded = false;
            });
          }
        },
        child:  Text(
          'Register',
          style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor,
              fontWeight:
              FontWeight.w900),
        ),
        style:
        ElevatedButton.styleFrom(
          side:  BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
          primary: Colors.transparent,
          elevation: 0,
          fixedSize: Size(
              MediaQuery.of(context)
                  .size
                  .width *
                  0.6,
              MediaQuery.of(context)
                  .size
                  .height *
                  0.05),
          shape:
          RoundedRectangleBorder(
              borderRadius:
              BorderRadius
                  .circular(
                  10)),
        ),
      );
  }

  Widget _loginLink() {
    return GestureDetector(
      onTap: () => _navigation.navigateToRoute('/login'),
      child: Container(
        child: Text(
          'Have an account?',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
