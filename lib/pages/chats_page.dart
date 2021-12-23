//Packages
import 'dart:async';

import 'package:chatify_app/pages/login_page.dart';
import 'package:chatify_app/services/shared_preference_function.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import '../pages/chat_page.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;
  String? userImage ;

  getImage() async {
    await SharedPreferenceFunctions.getUserImageSharedPreference().then((value){
      setState(() {
        userImage  = value;
        print(value);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
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
        _pageProvider = _context.watch<ChatsPageProvider>();
        return userImage == null
            ?  Center(child: ((){
          print('Getting Image');
              getImage();
              return CircularProgressIndicator();
        })())
            : Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Chats',
                primaryAction: GestureDetector(
                  onTap:()=>  showDialog(
                      context: context, builder: (_) {
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
              _chatsList(),
            ],
          ),
        );
      },
    );
  }

  Widget _chatsList() {
    List<Chat>? _chats = _pageProvider.chats;
    return _chats == null ? Expanded(
      child: Center(child: CircularProgressIndicator(
        color: Colors.white,
      ),),
    ) :
    Expanded(
      child: (() {
        print(_chats.length);
        if (_chats.isNotEmpty) {
          if (_chats.length != 0) {
            return ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (_context, _index) {
                return _chatTile(
                  _chats[_index],
                );
              },
            );
          } else {
            return Center(
              child: Text(
                "No Chats Found tt.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        } else {
          return Center(
            child: Text(
              "No Chats Found.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat _chat) {
    List<ChatUser> _recipients = _chat.recipients();
    bool _isActive = _recipients.any((_d) => _d.wasRecentlyActive());
    String _subtitleText = "";
    if (_chat.messages.isNotEmpty) {
      _subtitleText = _chat.messages.first.type != MessageType.TEXT
          ? "Media Attachment"
          : _chat.messages.first.content;
    }
    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: _chat.title(),
      subtitle: _subtitleText,
      imagePath: _chat.imageURL(),
      isActive: _isActive,
      isActivity: _chat.activity,
      onTap: () {
        _navigation.navigateToPage(
          ChatPage(chat: _chat),

        );
      },
    );
  }
}
