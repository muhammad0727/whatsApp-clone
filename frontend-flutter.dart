import 'package:flutter/material.dart';
import 'dart:async';

// --- MAIN FUNCTION ---
void main() {
  runApp(const ChitChatApp());
}

// --- APP ENTRY POINT ---
class ChitChatApp extends StatelessWidget {
  const ChitChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChitChat',
      debugShowCheckedModeBanner: false,
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
        // Define other theme properties to match the design
      ),
      home: const MainScreen(),
    );
  }
}

// --- DATA MODELS ---
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
  Message({required this.userId, required this.text, required this.timestamp});
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

List<Chat> mockChats = [
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
    messages: [
      Message(userId: 2, text: "Hey everyone! Just pushed the latest updates.", timestamp: "8:45 PM"),
      Message(userId: 3, text: "Awesome, pulling now. Will test it out.", timestamp: "8:46 PM"),
      Message(userId: 1, text: "Great work Ayesha! Let me know if you face any issues, Bilal.", timestamp: "8:47 PM"),
    ],
    unreadCount: 1,
  ),
  Chat(
    id: 2,
    type: 'direct',
    name: users[4]!.name,
    participants: [Participant(userId: 1), Participant(userId: 4)],
    messages: [
      Message(userId: 4, text: "Can you send me the project report?", timestamp: "7:30 PM"),
      Message(userId: 1, text: "Sure, just sent it to your email.", timestamp: "7:31 PM"),
    ],
  ),
  Chat(
    id: 3,
    type: 'direct',
    name: users[2]!.name,
    participants: [Participant(userId: 1), Participant(userId: 2)],
    messages: [Message(userId: 2, text: "See you tomorrow!", timestamp: "Yesterday")],
    unreadCount: 2,
  ),
];

final List<CallLog> mockCallLogs = [
    CallLog(id: 1, user: users[3]!, type: 'video', direction: 'outgoing', time: '6:15 PM'),
    CallLog(id: 2, user: users[5]!, type: 'audio', direction: 'incoming', time: '4:50 PM'),
    CallLog(id: 3, user: users[4]!, type: 'audio', direction: 'missed', time: '1:20 PM'),
];


// --- MOCK GEMINI API ---
Future<String> callGeminiApi(String prompt, String task) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 2));
  if (task == 'summarize') {
    return "Summary: Ayesha pushed new updates. Bilal is testing them, and support was offered. The general mood is collaborative and productive.";
  }
  if (task == 'suggest_replies') {
    return "Sounds good!|I'll check it out.|Thanks for the update!";
  }
  return "Sorry, I couldn't process that.";
}


// --- MAIN NAVIGATION MANAGER ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // 0: Status, 1: Chats, 2: Calls
  Chat? _selectedChat;
  bool _isChatOpen = false;
  bool _isGroupInfoOpen = false;

  void _onChatSelected(Chat chat) {
    setState(() {
      _selectedChat = chat;
      _isChatOpen = true;
    });
  }
  
  void _onSendMessage(String text) {
      if (_selectedChat != null) {
          setState(() {
              _selectedChat!.messages.add(
                  Message(userId: currentUserId, text: text, timestamp: "Now")
              );
          });
      }
  }

  void _updateUserRole(int userId, String newRole) {
    setState(() {
      _selectedChat!.participants.firstWhere((p) => p.userId == userId).role = newRole;
    });
    Navigator.of(context).pop();
  }

  Widget _buildCurrentScreen() {
    if (_isGroupInfoOpen && _selectedChat != null) {
        return GroupInfoScreen(
            chat: _selectedChat!,
            onBack: () => setState(() => _isGroupInfoOpen = false),
            onRoleChange: _updateUserRole,
        );
    }
    if (_isChatOpen && _selectedChat != null) {
      return ChatScreen(
        chat: _selectedChat!,
        onBack: () => setState(() => _isChatOpen = false),
        onHeaderTap: () => setState(() => _isGroupInfoOpen = true),
        onSendMessage: _onSendMessage,
      );
    }
    // Main layout with bottom tabs
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChitChat', style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const Center(child: Text('Status Screen')),
          ChatListScreen(chats: mockChats, onChatSelected: _onChatSelected),
          CallLogScreen(logs: mockCallLogs),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Status'),
          BottomNavigationBarItem(
              icon: Badge(
                  label: Text('${mockChats.where((c) => c.unreadCount > 0).length}'),
                  child: const Icon(Icons.chat_bubble_outline)),
              label: 'Chats'),
          const BottomNavigationBarItem(icon: Icon(Icons.phone_outlined), label: 'Calls'),
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final otherParticipant = chat.participants.firstWhere((p) => p.userId != currentUserId, orElse: () => chat.participants.first);
        final user = users[otherParticipant.userId]!;

        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat.lastMessageTime,
                style: TextStyle(
                  fontSize: 12,
                  color: chat.unreadCount > 0 ? Theme.of(context).primaryColor : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              if (chat.unreadCount > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
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
                            Text(log.time),
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
      super.initState();
      _scrollToBottom();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.chat.messages.length > oldWidget.chat.messages.length) {
          _scrollToBottom();
      }
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
    final prompt = widget.chat.messages.take(3).map((m) => "${users[m.userId]!.name}: ${m.text}").join('\n');
    final result = await callGeminiApi(prompt, 'suggest_replies');
    setState(() {
      _suggestedReplies = result.split('|');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: GestureDetector(
          onTap: widget.onHeaderTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.chat.name),
              Text(
                widget.chat.type == 'group'
                    ? '${widget.chat.participants.length} members'
                    : 'online',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
            Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage("https://i.pinimg.com/736x/8c/98/99/8c98994518b575bfd8c949e91d20548b.jpg"),
                        fit: BoxFit.cover,
                        opacity: 0.3
                    )
                ),
                child: Column(
                children: [
                    Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.chat.messages.length,
                        itemBuilder: (context, index) {
                        final message = widget.chat.messages[index];
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
                                onPressed: () {
                                _controller.text = reply;
                                setState(() => _suggestedReplies = []);
                                },
                            ),
                            )).toList(),
                        ),
                        ),
                    ),
                    _buildMessageComposer(),
                ],
                ),
            ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.sentiment_very_satisfied_outlined), onPressed: _handleSuggestReplies),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: const Color(0xFF374151), // gray-700
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          IconButton(icon: const Icon(Icons.payment), onPressed: () { /* Payment Logic */ }),
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
        setState(() => _isLoading = true);
        final prompt = widget.chat.messages.map((m) => "${users[m.userId]!.name}: ${m.text}").join('\n');
        final summary = await callGeminiApi(prompt, 'summarize');
        setState(() => _isLoading = false);

        if (mounted) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1F2937),
                    title: Row(
                        children: [
                            Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            const Text('Chat Summary'),
                        ],
                    ),
                    content: Text(summary, style: const TextStyle(color: Colors.white70)),
                    actions: [
                        TextButton(
                            child: const Text('Close'),
                            onPressed: () => Navigator.of(context).pop(),
                        ),
                    ],
                ),
            );
        }
    }


    void _showRolePicker(Participant participant) {
        showModalBottomSheet(
            context: context,
            builder: (context) {
                return Container(
                    color: const Color(0xFF111827),
                    child: SafeArea(
                        child: Wrap(
                            children: <Widget>[
                                ListTile(
                                    title: Text("Change role for ${users[participant.userId]!.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                ...['admin', 'moderator', 'participant'].map((role) {
                                    return ListTile(
                                        title: Text(role[0].toUpperCase() + role.substring(1)),
                                        onTap: () => widget.onRoleChange(participant.userId, role),
                                    );
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

    @override
    Widget build(BuildContext context) {
        final currentUserRole = widget.chat.participants.firstWhere((p) => p.userId == currentUserId).role;
        return Scaffold(
            appBar: AppBar(
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
                title: const Text('Group Info'),
            ),
            body: Stack(
                children: [
                    ListView(
                        children: [
                            const SizedBox(height: 20),
                            Center(
                                child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(users[widget.chat.participants[1].userId]!.avatarUrl),
                                ),
                            ),
                            const SizedBox(height: 12),
                            Center(child: Text(widget.chat.name, style: Theme.of(context).textTheme.headlineSmall)),
                            Center(child: Text('${widget.chat.participants.length} members', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey))),
                            const SizedBox(height: 20),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: _handleSummarize,
                                    icon: Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                                    label: Text("✨ Summarize Recent Activity", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text("Participants", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor)),
                            ),
                            ...widget.chat.participants.map((p) {
                                final user = users[p.userId]!;
                                return ListTile(
                                    leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                                    title: Text(user.name),
                                    subtitle: Text(p.role, style: TextStyle(color: _getRoleColor(p.role), fontWeight: FontWeight.bold)),
                                    trailing: currentUserRole == 'admin' && p.userId != currentUserId 
                                        ? TextButton(child: const Text("Change Role"), onPressed: () => _showRolePicker(p))
                                        : null,
                                );
                            }),
                        ],
                    ),
                    if (_isLoading)
                        Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(child: CircularProgressIndicator()),
                        ),
                ],
            ),
        );
    }
}


// --- CUSTOM WIDGETS ---

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

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
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSentByMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isSentByMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isSentByMe)
              Text(
                sender.name,
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 13),
              ),
            Text(message.text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              message.timestamp,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
            ),
          ],
        ),
      ),
    );
  }
}
