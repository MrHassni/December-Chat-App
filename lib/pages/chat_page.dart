//Packages
import 'package:chatify_app/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/custom_input_fields.dart';

//Models
import '../models/chat.dart';
import '../models/chat_message.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  ChatPage({required this.chat,});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messagesListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    _deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) =>
              ChatPageProvider(
                  this.widget.chat.uid, _auth, _messagesListViewController),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext _context) {
        _pageProvider = _context.watch<ChatPageProvider>();
        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Container(
                  padding: EdgeInsets.only(
                    left: _deviceWidth * 0.03,
                    right: _deviceWidth * 0.03,
                    top: _deviceHeight * 0.02,
                  ),
                  height: _deviceHeight,
                  width: _deviceWidth * 0.97,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: _deviceHeight * 0.10 - MediaQuery.of(context).padding.top ,
                      ),
                      _messagesListView(),
                      _sendMessageForm(),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _deviceWidth * 0.03,
                  vertical: _deviceHeight * 0.02,
                ),
                height: _deviceHeight,
                width: _deviceWidth * 0.97,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _customAppBar(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _customAppBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      color: Theme
          .of(context)
          .backgroundColor,
      height: _deviceHeight * 0.10,
      width: _deviceWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(0, 82, 218, 1.0),
            ),
            onPressed: () {
              _pageProvider.goBack();
            },
          ),
          RoundedImageNetworkWithStatusIndicator(
            key: UniqueKey(),
            size: _deviceHeight * 0.05,
            imagePath: widget.chat.imageURL(),
            isActive: widget.chat.activity,
          ),
          Container(
            width: _deviceWidth * 0.4,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              widget.chat.title(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Color.fromRGBO(0, 82, 218, 1.0),
            ),
            onPressed: () {
              _pageProvider.deleteChat();
            },
          ),
        ],
      ),
    );
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.length != 0) {
        return Expanded(
          child: ListView.builder(
            controller: _messagesListViewController,
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext _context, int _index) {
              ChatMessage _message = _pageProvider.messages![_index];
              bool _isOwnMessage = _message.senderID == _auth.user.uid;
              return Container(
                child: CustomChatListViewTile(
                  deviceHeight: _deviceHeight,
                  width: _deviceWidth * 0.7,
                  message: _message,
                  isOwnMessage: _isOwnMessage,
                  sender: this
                      .widget
                      .chat
                      .members
                      .where((_m) => _m.uid == _message.senderID)
                      .first,
                ),
              );
            },
          ),
        );
      } else {
        return Align(
          alignment: Alignment.center,
          child: Text(
            "Be the first to say Hi!",
            style: TextStyle(color: Colors.white),
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
  }

  Widget _sendMessageForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(right: 5, left: 10),
          height: _deviceHeight * 0.06,
          decoration: BoxDecoration(
            color: Color.fromRGBO(30, 29, 37, 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(
            right: _deviceWidth * 0.04,
            left: _deviceWidth * 0.04,
            bottom: _deviceHeight * 0.03,
          ),
          child: Form(
            key: _messageFormState,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _messageTextField(),
                _newSendMessageButton(),
              ],
            ),
          ),
        ),
        _imageMessageButton(),
      ],
    );
  }

  Widget _messageTextField() {
    return Container(
      width: _deviceWidth * 0.6,
      child: CustomTextFormField(
          onSaved: (_value) {
            _pageProvider.message = _value;
          },
          regEx: r"^(?!\s*$).+",
          hintText: "Type a message",
          obscureText: false),
    );
  }

  Widget _newSendMessageButton() {
    return GestureDetector(
      onTap: () {
        if (_messageFormState.currentState!.validate()) {
          _messageFormState.currentState!.save();
          _pageProvider.sendTextMessage();
          _messageFormState.currentState!.reset();
        }
      },
      child: Transform.scale(
        scale: 1.1,
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }

  // Widget _sendMessageButton() {
  //   double _size = _deviceHeight * 0.04;
  //   return Container(
  //     height: _size,
  //     width: _size,
  //     child: IconButton(
  //       icon: Icon(
  //         Icons.send,
  //         color: Colors.white,
  //       ),
  //       onPressed: () {
  //         if (_messageFormState.currentState!.validate()) {
  //           _messageFormState.currentState!.save();
  //           _pageProvider.sendTextMessage();
  //           _messageFormState.currentState!.reset();
  //         }
  //       },
  //     ),
  //   );
  // }

  Widget _imageMessageButton() {
    double _size = _deviceHeight * 0.05;
    return Container(
      height: _size,
      width: _size,
      child: FloatingActionButton(
        backgroundColor: Color.fromRGBO(
          0,
          82,
          218,
          1.0,
        ),
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        child: Icon(Icons.camera_enhance),
      ),
    );
  }
}
