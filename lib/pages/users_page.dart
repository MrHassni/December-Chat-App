//Packages
import 'package:chatify_app/pages/chat_page.dart';
import 'package:chatify_app/pages/chats_page.dart';
import 'package:chatify_app/pages/home_page.dart';
import 'package:chatify_app/providers/chat_page_provider.dart';
import 'package:chatify_app/providers/chats_page_provider.dart';
import 'package:chatify_app/services/shared_preference_function.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/users_page_provider.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat_user.dart';
import 'login_page.dart';

class UsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UsersPageState();
  }
}

class _UsersPageState extends State<UsersPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late String secondUserUID;
  bool alreadyAvailable = false;
   int? indexOfSecondUser ;

  late AuthenticationProvider _auth;
  late UsersPageProvider _usersPageProvider;
  late ChatsPageProvider _chatsPageProvider;
  final TextEditingController _searchFieldTextEditingController =
      TextEditingController();
  String? userImage;

  getImage() async {
    await SharedPreferenceFunctions.getUserImageSharedPreference()
        .then((value) {
      setState(() {
        userImage = value;
        print(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersPageProvider>(
          create: (_) => UsersPageProvider(_auth),
        ),
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext _context) {
        _usersPageProvider = _context.watch<UsersPageProvider>();
        _chatsPageProvider = _context.watch<ChatsPageProvider>();
        return userImage == null
            ? Center(child: (() {
                print('Getting Image');
                getImage();
                return CircularProgressIndicator();
              })())
            : Container(
                padding: EdgeInsets.only(
                    left: _deviceWidth * 0.03,
                    right: _deviceWidth * 0.03,
                    top: _deviceHeight * 0.02),
                height: _deviceHeight * 0.98,
                width: _deviceWidth * 0.97,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TopBar(
                          'Users',
                          primaryAction: GestureDetector(
                            onTap: () => showDialog(
                                context: context,
                                builder: (_) {
                                  return Dialog(
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    child: Card(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        elevation: 5,
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                                alignment: Alignment.topLeft,
                                                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                child: Text(
                                                  'Do You Want To LogOut?',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                      color: Colors.white),
                                                )),
                                            Container(
                                              margin: EdgeInsets.only(bottom: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'No',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                          FontWeight.w900),
                                                    ),
                                                    style:
                                                    ElevatedButton.styleFrom(
                                                      side: const BorderSide(
                                                        color: Colors.red,
                                                        width: 2.0,
                                                      ),
                                                      primary: Colors.transparent,
                                                      elevation: 0,
                                                      fixedSize: Size(
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                              0.3,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                              0.05),
                                                      shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              25)),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      _auth.signOut();
                                                      final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                      await prefs.clear();
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginPage(),
                                                        ),
                                                      );
                                                    },
                                                    child:  Text(
                                                      'Yes',
                                                      style: TextStyle(
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
                                                              0.3,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                              0.05),
                                                      shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              25)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                                  );
                                }),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(userImage!),
                            ),
                          ),
                        ),
                        CustomTextField(
                          onChanged: (_value) {
                            _usersPageProvider.getUsers(name: _value);
                          },
                          onEditingComplete: (_value) {
                            _usersPageProvider.getUsers(name: _value);
                            FocusScope.of(context).unfocus();
                          },
                          hintText: "Search...",
                          obscureText: false,
                          controller: _searchFieldTextEditingController,
                          icon: Icons.search,
                        ),
                        _usersList(),
                      ],
                    ),
                    Container(
                        height: _deviceHeight,
                        width: _deviceWidth,
                        alignment: Alignment.bottomCenter,
                        child: _createChatButton()),
                  ],
                ),
              );
      },
    );
  }

  Widget _usersList() {
    List<ChatUser>? _users = _usersPageProvider.users;
    return Expanded(child: () {
      if (_users != null) {
        if (_users.length != 0) {
          return ListView.builder(
            itemCount: _users.length,
            itemBuilder: (BuildContext _context, int _index) {
              return CustomListViewTile(
                height: _deviceHeight * 0.10,
                title: _users[_index].name,
                subtitle: "Last Active: ${_users[_index].lastDayActive()}",
                imagePath: _users[_index].imageURL,
                isActive: _users[_index].wasRecentlyActive(),
                isSelected: _usersPageProvider.selectedUsers.contains(
                  _users[_index],
                ),
                onTap: () {
                  _usersPageProvider.updateSelectedUsers(
                    _users[_index],
                  );
                },
              );
            },
          );
        } else {
          return Center(
            child: Text(
              "No Users Found.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }
    }());
  }

  Widget _createChatButton() {
    return Visibility(
        visible: _usersPageProvider.selectedUsers.isNotEmpty,
        child: ElevatedButton(
          onPressed: () {

            if(_usersPageProvider.selectedUsers.length != 1){
              _usersPageProvider.createChat();
            }else{

            for(int index = 0; index < _chatsPageProvider.chats!.length; index++) {
              secondUserUID = _chatsPageProvider.chats![index].members.first.uid;
              if(_usersPageProvider.selectedUsers[0].uid == secondUserUID){
                alreadyAvailable = true;
                indexOfSecondUser = index;
                break;
              }else{
                alreadyAvailable = false;
              }
            }
            if(alreadyAvailable == true && indexOfSecondUser != null){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage(),),);
            }else{
              indexOfSecondUser = null;
              print('false' + indexOfSecondUser.toString());
              _usersPageProvider.createChat();
            }}
          },
          child: Text(
            _usersPageProvider.selectedUsers.length == 1
                ? "Chat With ${_usersPageProvider.selectedUsers.first.name}"
                : "Create Group Chat",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            fixedSize: Size(MediaQuery.of(context).size.width * 0.5,
                MediaQuery.of(context).size.height * 0.060),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ));
  }
}
