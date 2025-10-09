import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chitchat/l10n/app_localizations.dart';

// --- MAIN FUNCTION ---
void main() {
  runApp(const ChitChatApp());
}

// --- OFFLINE & CACHING ---
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  List<Chat> cachedChats = [];

  Future<void> cacheChats(List<Chat> chats) async {
    print("CHATS CACHED");
    cachedChats = List.from(chats);
  }

  Future<List<Chat>> getCachedChats() async {
    print("FETCHING CACHED CHATS");
    return List.from(cachedChats);
  }
}

class OfflineService {
  bool isOnline = true;
  final List<Message> _messageQueue = [];

  void queueMessage(Message message) {
    _messageQueue.add(message);
    print("Message queued. Queue size: ${_messageQueue.length}");
  }

  List<Message> get queuedMessages => _messageQueue;

  Future<void> sendQueuedMessages(Function(Message) onSend) async {
    print("Sending queued messages...");
    for (var message in _messageQueue) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network latency
      onSend(message);
    }
    _messageQueue.clear();
    print("Queue cleared.");
  }
}

// --- IMAGE COMPRESSION PLACEHOLDER ---
class ImageCompressor {
  static Future<String> compressImage(String imageName) async {
    print("Compressing $imageName...");
    await Future.delayed(const Duration(seconds: 1)); // Simulate compression work
    print("Compression complete.");
    return "compressed_$imageName";
  }
}


// --- APP ENTRY POINT ---
class ChitChatApp extends StatefulWidget {
  const ChitChatApp({super.key});

  @override
  State<ChitChatApp> createState() => _ChitChatAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _ChitChatAppState? state = context.findAncestorStateOfType<_ChitChatAppState>();
    state?.setLocale(newLocale);
  }
}

class _ChitChatAppState extends State<ChitChatApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ur', ''),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00B8D4), // Cyan
        scaffoldBackgroundColor: const Color(0xFF1F2937), // gray-800
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111827), // gray-900
          elevation: 4,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF111827),
          selectedItemColor: Color(0xFF22D3EE), // cyan-400
          unselectedItemColor: Colors.grey,
        ),
        fontFamily: 'Inter',
      ),
      home: MainScreen(),
    );
  }
}

// --- DATA MODELS ---
enum MessageStatus { sent, pending, failed }

class User {
  final int id;
  final String name;
  final String avatarUrl;
  User({required this.id, required this.name, required this.avatarUrl});
}

class Participant {
  final int userId;
  String role;
  Participant({required this.userId, this.role = 'participant'});
}

class Message {
  final int userId;
  final String text;
  final String timestamp;
  MessageStatus status;

  Message({required this.userId, required this.text, required this.timestamp, this.status = MessageStatus.sent});
}

class Chat {
  final int id;
  final String type; // 'group' or 'direct'
  final String name;
  List<Participant> participants;
  final List<Message> messages;
  final int unreadCount;
  String get lastMessage => messages.isEmpty ? '' : messages.last.text;
  String get lastMessageTime => messages.isEmpty ? '' : messages.last.timestamp;

  Chat({
    required this.id,
    required this.type,
    required this.name,
    required this.participants,
    required this.messages,
    this.unreadCount = 0,
  });
}

class CallLog {
    final int id;
    final User user;
    final String type; // 'audio' or 'video'
    final String direction; // 'incoming', 'outgoing', 'missed'
    final String time;
    CallLog({required this.id, required this.user, required this.type, required this.direction, required this.time});
}


// --- MOCK DATA ---
const int currentUserId = 1;

final Map<int, User> users = {
  1: User(id: 1, name: "You", avatarUrl: "https://placehold.co/100x100/E2E8F0/4A5568?text=Me"),
  2: User(id: 2, name: "Ayesha Khan", avatarUrl: "https://placehold.co/100x100/FBBF24/854D0E?text=AK"),
  3: User(id: 3, name: "Bilal Ahmed", avatarUrl: "https://placehold.co/100x100/34D399/065F46?text=BA"),
  4: User(id: 4, name: "Fatima Ali", avatarUrl: "https://placehold.co/100x100/F472B6/831843?text=FA"),
  5: User(id: 5, name: "Saad Ibrahim", avatarUrl: "https://placehold.co/100x100/60A5FA/1E3A8A?text=SI"),
};

List<Chat> getMockChats() => [
  Chat(
    id: 1,
    type: 'group',
    name: "Karachi Coders 💻",
    participants: [
      Participant(userId: 1, role: 'admin'),
      Participant(userId: 2, role: 'moderator'),
      Participant(userId: 3, role: 'participant'),
      Participant(userId: 5, role: 'participant'),
    ],
    messages: List.generate(30, (i) => Message(userId: (i % 3) + 2, text: "This is message number ${30 - i} in the chat history.", timestamp: "Yesterday")) + [
      Message(userId: 2, text: "Hey everyone! Just pushed the latest updates.", timestamp: "8:45 PM"),
      Message(userId: 3, text: "Awesome, pulling now. Will test it out.", timestamp: "8:46 PM"),
      Message(userId: 1, text: "Great work Ayesha! Let me know if you face any issues, Bilal.", timestamp: "8:47 PM"),
    ],
    unreadCount: 1,
  ),
  Chat( id: 2, type: 'direct', name: users[4]!.name, participants: [Participant(userId: 1), Participant(userId: 4)], messages: [ Message(userId: 4, text: "Can you send me the project report?", timestamp: "7:30 PM"), Message(userId: 1, text: "Sure, just sent it to your email.", timestamp: "7:31 PM"), ], ),
  Chat( id: 3, type: 'direct', name: users[2]!.name, participants: [Participant(userId: 1), Participant(userId: 2)], messages: [Message(userId: 2, text: "See you tomorrow!", timestamp: "Yesterday")], unreadCount: 2, ),
];

final List<CallLog> mockCallLogs = [
    CallLog(id: 1, user: users[3]!, type: 'video', direction: 'outgoing', time: '6:15 PM'),
    CallLog(id: 2, user: users[5]!, type: 'audio', direction: 'incoming', time: '4:50 PM'),
    CallLog(id: 3, user: users[4]!, type: 'audio', direction: 'missed', time: '1:20 PM'),
];


// --- MOCK GEMINI API ---
Future<String> callGeminiApi(String prompt, String task) async {
  await Future.delayed(const Duration(seconds: 2));
  if (task == 'summarize') return "Summary: Ayesha pushed new updates. Bilal is testing them, and support was offered. The general mood is collaborative and productive.";
  if (task == 'suggest_replies') return "Sounds good!|I'll check it out.|Thanks for the update!";
  return "Sorry, I couldn't process that.";
}


// --- MAIN NAVIGATION MANAGER ---
class MainScreen extends StatefulWidget {
  final CacheManager cacheManager;
  final OfflineService offlineService;

  MainScreen({super.key})
      : cacheManager = CacheManager(),
        offlineService = OfflineService();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;
  Chat? _selectedChat;
  bool _isChatOpen = false;
  bool _isGroupInfoOpen = false;
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    if (widget.offlineService.isOnline) {
      final chats = getMockChats();
      await widget.cacheManager.cacheChats(chats);
      setState(() => _chats = chats);
    } else {
      final chats = await widget.cacheManager.getCachedChats();
      setState(() => _chats = chats);
    }
  }

  void _onChatSelected(Chat chat) {
    setState(() {
      _selectedChat = chat;
      _isChatOpen = true;
    });
  }
  
  void _onSendMessage(String text) {
    if (_selectedChat != null) {
      final message = Message(
          userId: currentUserId,
          text: text,
          timestamp: AppLocalizations.of(context)!.now,
          status: widget.offlineService.isOnline ? MessageStatus.sent : MessageStatus.pending);

      if (widget.offlineService.isOnline) {
        _addMessageToChat(message);
      } else {
        widget.offlineService.queueMessage(message);
        _addMessageToChat(message); // Show in UI immediately
      }
    }
  }

  void _addMessageToChat(Message message) {
    setState(() {
      final chatIndex = _chats.indexWhere((c) => c.id == _selectedChat!.id);
      if (chatIndex != -1) {
        _chats[chatIndex].messages.add(message);
      }
    });
  }

  void _updateUserRole(int userId, String newRole) {
    setState(() {
      _selectedChat!.participants.firstWhere((p) => p.userId == userId).role = newRole;
    });
    Navigator.of(context).pop();
  }

  void _toggleOnlineStatus(bool isOnline) {
    setState(() {
      widget.offlineService.isOnline = isOnline;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isOnline ? "You are back online." : "You are now offline."),
    ));
    if (isOnline) {
      widget.offlineService.sendQueuedMessages((sentMessage) {
        setState(() {
          final chatIndex = _chats.indexWhere((c) => c.messages.any((m) => m.text == sentMessage.text && m.status == MessageStatus.pending));
          if (chatIndex != -1) {
            final msgIndex = _chats[chatIndex].messages.indexWhere((m) => m.text == sentMessage.text && m.status == MessageStatus.pending);
            if (msgIndex != -1) {
              _chats[chatIndex].messages[msgIndex].status = MessageStatus.sent;
            }
          }
        });
      });
    }
  }

  Widget _buildCurrentScreen() {
    final l10n = AppLocalizations.of(context)!;
    if (_isGroupInfoOpen && _selectedChat != null) {
        return GroupInfoScreen( chat: _selectedChat!, onBack: () => setState(() => _isGroupInfoOpen = false), onRoleChange: _updateUserRole, );
    }
    if (_isChatOpen && _selectedChat != null) {
      return ChatScreen( key: ValueKey(_selectedChat!.id), chat: _selectedChat!, onBack: () => setState(() => _isChatOpen = false), onHeaderTap: () => setState(() => _isGroupInfoOpen = true), onSendMessage: _onSendMessage, );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold)),
        actions: [
          Switch(value: widget.offlineService.isOnline, onChanged: _toggleOnlineStatus, activeColor: Colors.green, inactiveThumbColor: Colors.red),
          IconButton(icon: const Icon(Icons.search), tooltip: l10n.search, onPressed: () {}),
          PopupMenuButton<Locale>(
            tooltip: l10n.more,
            onSelected: (Locale locale) => ChitChatApp.setLocale(context, locale),
            itemBuilder: (BuildContext context) => [ const PopupMenuItem(value: Locale('en'), child: Text('English')), const PopupMenuItem(value: Locale('ur'), child: Text('اردو')), ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Center(child: Text(l10n.status)),
          ChatListScreen(chats: _chats, onChatSelected: _onChatSelected),
          CallLogScreen(logs: mockCallLogs),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.camera_alt_outlined), label: l10n.status),
          BottomNavigationBarItem(icon: Badge(label: Text('${_chats.where((c) => c.unreadCount > 0).length}'), child: const Icon(Icons.chat_bubble_outline)), label: l10n.chats),
          BottomNavigationBarItem(icon: const Icon(Icons.phone_outlined), label: l10n.calls),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentScreen();
  }
}


// --- SCREEN WIDGETS ---

class ChatListScreen extends StatelessWidget {
  final List<Chat> chats;
  final ValueChanged<Chat> onChatSelected;

  const ChatListScreen({super.key, required this.chats, required this.onChatSelected});

  String _getTimestamp(BuildContext context, String timestamp) {
    if (timestamp == "Yesterday") return AppLocalizations.of(context)!.yesterday;
    return timestamp;
  }

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
        return const Center(child: Text("No chats available offline."));
    }
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final otherParticipant = chat.participants.firstWhere((p) => p.userId != currentUserId, orElse: () => chat.participants.first);
        final user = users[otherParticipant.userId]!;

        return ListTile(
          leading: CircleAvatar( radius: 28, backgroundImage: NetworkImage(user.avatarUrl), ),
          title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text( chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey), ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text( _getTimestamp(context, chat.lastMessageTime), style: TextStyle( fontSize: 12, color: chat.unreadCount > 0 ? Theme.of(context).primaryColor : Colors.grey, ), ),
              const SizedBox(height: 4),
              if (chat.unreadCount > 0)
                CircleAvatar( radius: 10, backgroundColor: Theme.of(context).primaryColor, child: Text( chat.unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), ), ),
            ],
          ),
          onTap: () => onChatSelected(chat),
        );
      },
    );
  }
}

class CallLogScreen extends StatelessWidget {
    final List<CallLog> logs;
    const CallLogScreen({super.key, required this.logs});
    
    Icon _getDirectionIcon(String direction, BuildContext context) {
        switch(direction) {
            case 'incoming': return const Icon(Icons.call_received, color: Colors.green, size: 16);
            case 'outgoing': return const Icon(Icons.call_made, color: Colors.blue, size: 16);
            case 'missed': return const Icon(Icons.call_missed, color: Colors.red, size: 16);
            default: return const Icon(Icons.phone, size: 16);
        }
    }

    String _getDirectionText(String direction, BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        switch(direction) {
            case 'incoming': return l10n.incoming;
            case 'outgoing': return l10n.outgoing;
            case 'missed': return l10n.missed;
            default: return '';
        }
    }

    @override
    Widget build(BuildContext context) {
        return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
                final log = logs[index];
                return ListTile(
                    leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(log.user.avatarUrl)),
                    title: Text(log.user.name, style: TextStyle(fontWeight: FontWeight.bold, color: log.direction == 'missed' ? Colors.red.shade300 : Colors.white)),
                    subtitle: Row(
                        children: [
                            _getDirectionIcon(log.direction, context),
                            const SizedBox(width: 4),
                            Text("${_getDirectionText(log.direction, context)} - ${log.time}"),
                        ],
                    ),
                    trailing: IconButton(
                        icon: Icon(log.type == 'video' ? Icons.videocam : Icons.phone, color: Theme.of(context).primaryColor),
                        onPressed: () { /* Start call logic */ },
                    ),
                );
            },
        );
    }
}


class ChatScreen extends StatefulWidget {
  final Chat chat;
  final VoidCallback onBack;
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onSendMessage;

  const ChatScreen({super.key, required this.chat, required this.onBack, required this.onHeaderTap, required this.onSendMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _suggestedReplies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  late List<Message> _messages;

  @override
  void initState() {
      super.initState();
      _messages = List.from(widget.chat.messages.skip(widget.chat.messages.length - 15)); // Start with last 15
      _scrollController.addListener(_onScroll);
      _scrollToBottom();
  }

  void _onScroll() {
      if (_scrollController.position.atEdge && _scrollController.position.pixels == 0 && !_isLoadingMore) {
          _loadMoreMessages();
      }
  }

  Future<void> _loadMoreMessages() async {
      setState(() => _isLoadingMore = true);
      await Future.delayed(const Duration(seconds: 1)); // Simulate network fetch

      final allMessages = widget.chat.messages;
      final currentCount = _messages.length;
      final nextMessages = allMessages.reversed.skip(currentCount).take(15).toList().reversed.toList();

      setState(() {
          _messages.insertAll(0, nextMessages);
          _isLoadingMore = false;
      });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo( _scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, );
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.chat.messages.length > oldWidget.chat.messages.length) {
          final newMessage = widget.chat.messages.last;
          if (!_messages.contains(newMessage)) {
              setState(() => _messages.add(newMessage));
          }
          _scrollToBottom();
      }
  }
  
  @override
  void dispose() {
      _scrollController.dispose();
      super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
      setState(() => _suggestedReplies = []);
    }
  }
  
  Future<void> _handleSuggestReplies() async {
    setState(() => _isLoading = true);
    final prompt = _messages.take(3).map((m) => "${users[m.userId]!.name}: ${m.text}").join('\n');
    final result = await callGeminiApi(prompt, 'suggest_replies');
    setState(() { _suggestedReplies = result.split('|'); _isLoading = false; });
  }

  Future<void> _handleAttachment() async {
      final compressedFile = await ImageCompressor.compressImage("my_photo.jpg");
      widget.onSendMessage("Sent an image: $compressedFile");
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: GestureDetector(
          onTap: widget.onHeaderTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ Text(widget.chat.name), Text( widget.chat.type == 'group' ? l10n.members(widget.chat.participants.length) : l10n.online, style: const TextStyle(fontSize: 12, color: Colors.grey), ), ],
          ),
        ),
        actions: [ IconButton(icon: const Icon(Icons.videocam), onPressed: () {}), IconButton(icon: const Icon(Icons.phone), onPressed: () {}), IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}), ],
      ),
      body: Stack(
        children: [
            Container(
                decoration: const BoxDecoration( image: DecorationImage( image: NetworkImage("https://i.pinimg.com/736x/8c/98/99/8c98994518b575bfd8c949e91d20548b.jpg"), fit: BoxFit.cover, opacity: 0.3 ) ),
                child: Column(
                children: [
                    if (_isLoadingMore) const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator())),
                    Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                        final message = _messages[index];
                        return MessageBubble(message: message);
                        },
                    ),
                    ),
                    if (_suggestedReplies.isNotEmpty)
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: _suggestedReplies.map((reply) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ActionChip(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                label: Text(reply, style: TextStyle(color: Theme.of(context).primaryColor)),
                                onPressed: () { _controller.text = reply; setState(() => _suggestedReplies = []); },
                            ),
                            )).toList(),
                        ),
                        ),
                    ),
                    _buildMessageComposer(),
                ],
                ),
            ),
          if (_isLoading) Container( color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator()), ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.sentiment_very_satisfied_outlined), tooltip: l10n.suggestReplies, onPressed: _handleSuggestReplies),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.typeAMessage,
                filled: true,
                fillColor: const Color(0xFF374151), // gray-700
                border: OutlineInputBorder( borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none, ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _handleAttachment),
          IconButton(icon: const Icon(Icons.payment), tooltip: l10n.payment, onPressed: () { /* Payment Logic */ }),
          const SizedBox(width: 4),
          FloatingActionButton(
            mini: true,
            onPressed: _handleSend,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class GroupInfoScreen extends StatefulWidget {
    final Chat chat;
    final VoidCallback onBack;
    final Function(int, String) onRoleChange;

    const GroupInfoScreen({super.key, required this.chat, required this.onBack, required this.onRoleChange});

    @override
    State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
    bool _isLoading = false;

    Future<void> _handleSummarize() async {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _isLoading = true);
        final prompt = widget.chat.messages.map((m) => "${users[m.userId]!.name}: ${m.text}").join('\n');
        final summary = await callGeminiApi(prompt, 'summarize');
        setState(() => _isLoading = false);

        if (mounted) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1F2937),
                    title: Row( children: [ Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor), const SizedBox(width: 8), Text(l10n.chatSummary), ], ),
                    content: Text(summary, style: const TextStyle(color: Colors.white70)),
                    actions: [ TextButton( child: Text(l10n.close), onPressed: () => Navigator.of(context).pop(), ), ],
                ),
            );
        }
    }


    void _showRolePicker(Participant participant) {
        final l10n = AppLocalizations.of(context)!;
        final roles = { 'admin': l10n.admin, 'moderator': l10n.moderator, 'participant': l10n.participant, };

        showModalBottomSheet(
            context: context,
            builder: (context) {
                return Container(
                    color: const Color(0xFF111827),
                    child: SafeArea(
                        child: Wrap(
                            children: <Widget>[
                                ListTile( title: Text(l10n.changeRoleFor(users[participant.userId]!.name), style: const TextStyle(fontWeight: FontWeight.bold)), ),
                                ...roles.entries.map((entry) {
                                    return ListTile( title: Text(entry.value), onTap: () => widget.onRoleChange(participant.userId, entry.key), );
                                })
                            ],
                        ),
                    ),
                );
            }
        );
    }
    
    Color _getRoleColor(String role) {
        switch (role) {
            case 'admin': return Colors.amber.shade600;
            case 'moderator': return Colors.blue.shade400;
            default: return Colors.grey;
        }
    }

    String _getRoleText(String role, BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        switch (role) {
            case 'admin': return l10n.admin;
            case 'moderator': return l10n.moderator;
            default: return l10n.participant;
        }
    }

    @override
    Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        final currentUserRole = widget.chat.participants.firstWhere((p) => p.userId == currentUserId).role;
        return Scaffold(
            appBar: AppBar(
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
                title: Text(l10n.groupInfo),
            ),
            body: Stack(
                children: [
                    ListView(
                        children: [
                            const SizedBox(height: 20),
                            Center( child: CircleAvatar( radius: 50, backgroundImage: NetworkImage(users[widget.chat.participants[1].userId]!.avatarUrl), ), ),
                            const SizedBox(height: 12),
                            Center(child: Text(widget.chat.name, style: Theme.of(context).textTheme.headlineSmall)),
                            Center(child: Text(l10n.members(widget.chat.participants.length), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey))),
                            const SizedBox(height: 20),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom( backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2), padding: const EdgeInsets.symmetric(vertical: 12), ),
                                    onPressed: _handleSummarize,
                                    icon: Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                                    label: Text(l10n.summarizeRecentActivity, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                ),
                            ),
                            const SizedBox(height: 20),
                            Padding( padding: const EdgeInsets.all(16.0), child: Text(l10n.participants, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor)), ),
                            ...widget.chat.participants.map((p) {
                                final user = users[p.userId]!;
                                return ListTile(
                                    leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                                    title: Text(user.name),
                                    subtitle: Text(_getRoleText(p.role, context), style: TextStyle(color: _getRoleColor(p.role), fontWeight: FontWeight.bold)),
                                    trailing: currentUserRole == 'admin' && p.userId != currentUserId ? TextButton(child: Text(l10n.changeRole), onPressed: () => _showRolePicker(p)) : null,
                                );
                            }),
                        ],
                    ),
                    if (_isLoading) Container( color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator()), ),
                ],
            ),
        );
    }
}


// --- CUSTOM WIDGETS ---

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  String _getTimestamp(BuildContext context, String timestamp) {
    if (timestamp == "Yesterday") return AppLocalizations.of(context)!.yesterday;
    if (timestamp == "Now") return AppLocalizations.of(context)!.now;
    return timestamp;
  }

  Icon _getStatusIcon(MessageStatus status) {
      switch (status) {
          case MessageStatus.pending: return const Icon(Icons.timer_outlined, size: 14, color: Colors.grey);
          case MessageStatus.failed: return const Icon(Icons.error_outline, size: 14, color: Colors.red);
          case MessageStatus.sent: return const Icon(Icons.done, size: 14, color: Colors.grey);
          default: return const Icon(Icons.done, size: 14, color: Colors.grey);
      }
  }

  @override
  Widget build(BuildContext context) {
    final isSentByMe = message.userId == currentUserId;
    final sender = users[message.userId]!;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSentByMe ? const Color(0xFF0891B2) : const Color(0xFF374151),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: isSentByMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isSentByMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isSentByMe) Text( sender.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 13), ),
            Text(message.text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text( _getTimestamp(context, message.timestamp), style: TextStyle(fontSize: 10, color: Colors.grey.shade300), ),
                if(isSentByMe) ...[const SizedBox(width: 4), _getStatusIcon(message.status)]
              ],
            ),
          ],
        ),
      ),
    );
  }
}