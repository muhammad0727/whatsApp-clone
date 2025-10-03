import React, { useState, useCallback, useRef, useEffect } from 'react';

// --- SVG Icons (Inlined to keep everything in one file) ---
const icons = {
  camera: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z" />
      <circle cx="12" cy="13" r="3" />
    </svg>
  ),
  search: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" />
    </svg>
  ),
  ellipsisVertical: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="1" /><circle cx="12" cy="5" r="1" /><circle cx="12" cy="19" r="1" />
    </svg>
  ),
  phone: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
    </svg>
  ),
  video: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m22 8-6 4 6 4V8Z" /><rect x="2" y="6" width="14" height="12" rx="2" ry="2" />
    </svg>
  ),
  arrowLeft: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <line x1="19" y1="12" x2="5" y2="12" /><polyline points="12 19 5 12 12 5" />
    </svg>
  ),
  send: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <line x1="22" y1="2" x2="11" y2="13" /><polygon points="22 2 15 22 11 13 2 9 22 2" />
    </svg>
  ),
  paperclip: (props) => (
     <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
       <path d="m21.44 11.05-9.19 9.19a6 6 0 0 1-8.49-8.49l8.57-8.57A4 4 0 1 1 18 8.84l-8.59 8.59a2 2 0 0 1-2.83-2.83l8.49-8.48"/>
     </svg>
  ),
  mic: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z" /><path d="M19 10v2a7 7 0 0 1-14 0v-2" /><line x1="12" y1="19" x2="12" y2="22" />
    </svg>
  ),
  dollarSign: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <line x1="12" y1="1" x2="12" y2="23" /><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
    </svg>
  ),
   phoneOff: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M10.68 13.31a16 16 0 0 0 3.41 2.6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7 2 2 0 0 1 1.72 2v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.42 19.42 0 0 1-3.33-2.67m-2.67-3.34a19.79 19.79 0 0 1-3.07-8.63A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91" /><line x1="22" y1="2" x2="2" y2="22" />
    </svg>
  ),
  micOff: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <line x1="2" y1="2" x2="22" y2="22" /><path d="M18.89 13.23A7.12 7.12 0 0 1 19 12v-2" /><path d="M5 10v2a7 7 0 0 0 12 5" /><path d="M15 9.34V4a3 3 0 0 0-5.68-1.33" /><path d="M12 19v3" /><path d="M8.51 9.49a3 3 0 0 0 3.49 5.02" />
    </svg>
  ),
  volume2: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" /><path d="M15.54 8.46a5 5 0 0 1 0 7.07" /><path d="M19.07 4.93a10 10 0 0 1 0 14.14" />
    </svg>
  ),
  users: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
    </svg>
  ),
  check: (props) => (
      <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
  ),
  bank: (props) => (
      <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m3 21 18-0"/><path d="M5 18v-6"/><path d="M19 18v-6"/><path d="M12 18V12"/><path d="M3 12h18"/><path d="m3 9 9-7 9 7"/></svg>
  ),
  sparkles: (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="m12 3-1.9 5.8L4 10l5.8 1.9L12 18l1.9-5.8L20 10l-5.8-1.9Z"/>
    </svg>
  )
};

// --- Mock Data ---
const CURRENT_USER_ID = 1;

const users = {
  1: { id: 1, name: "You", avatar: "https://placehold.co/100x100/E2E8F0/4A5568?text=Me" },
  2: { id: 2, name: "Ayesha Khan", avatar: "https://placehold.co/100x100/FBBF24/854D0E?text=AK" },
  3: { id: 3, name: "Bilal Ahmed", avatar: "https://placehold.co/100x100/34D399/065F46?text=BA" },
  4: { id: 4, name: "Fatima Ali", avatar: "https://placehold.co/100x100/F472B6/831843?text=FA" },
  5: { id: 5, name: "Saad Ibrahim", avatar: "https://placehold.co/100x100/60A5FA/1E3A8A?text=SI" },
};

const initialChats = [
  {
    id: 1,
    type: 'group',
    name: "Karachi Coders 💻",
    participants: [
      { userId: 1, role: 'admin' },
      { userId: 2, role: 'moderator' },
      { userId: 3, role: 'participant' },
      { userId: 5, role: 'participant' }
    ],
    messages: [
      { userId: 2, text: "Hey everyone! Just pushed the latest updates.", timestamp: "8:45 PM" },
      { userId: 3, text: "Awesome, pulling now. Will test it out.", timestamp: "8:46 PM" },
      { userId: 1, text: "Great work Ayesha! Let me know if you face any issues, Bilal.", timestamp: "8:47 PM" },
    ],
    unread: 1,
    lastMessage: "Great work Ayesha! Let me know...",
    lastMessageTime: "8:47 PM"
  },
  {
    id: 2,
    type: 'direct',
    name: users[4].name,
    participants: [{ userId: 1 }, { userId: 4 }],
    messages: [
      { userId: 4, text: "Can you send me the project report?", timestamp: "7:30 PM" },
      { userId: 1, text: "Sure, just sent it to your email.", timestamp: "7:31 PM" },
    ],
    unread: 0,
    lastMessage: "Sure, just sent it to your email.",
    lastMessageTime: "7:31 PM"
  },
  {
    id: 3,
    type: 'direct',
    name: users[2].name,
    participants: [{ userId: 1 }, { userId: 2 }],
    messages: [
       { userId: 2, text: "See you tomorrow!", timestamp: "Yesterday" }
    ],
    unread: 2,
    lastMessage: "See you tomorrow!",
    lastMessageTime: "Yesterday"
  }
];

const callLogs = [
    { id: 1, user: users[3], type: 'video', direction: 'outgoing', time: '6:15 PM' },
    { id: 2, user: users[5], type: 'audio', direction: 'incoming', time: '4:50 PM' },
    { id: 3, user: users[4], type: 'audio', direction: 'missed', time: '1:20 PM' },
];

// --- Mock Gemini API Call ---
const callGeminiApi = async (prompt, task) => {
    console.log(`Calling Gemini API for task: ${task}`);
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1500));

    if (task === 'summarize') {
        return "Summary: Ayesha pushed new updates. Bilal is testing them, and you offered support. The general mood is collaborative and productive.";
    }
    if (task === 'suggest_replies') {
        return ["Sounds good!", "I'll check it out.", "Thanks for the update!"];
    }
    return "Sorry, I couldn't process that.";
};

// --- Main App Component ---
export default function App() {
  const [activeScreen, setActiveScreen] = useState('chatList'); // chatList, chat, groupInfo, payments, call, callLog
  const [selectedChatId, setSelectedChatId] = useState(null);
  const [chats, setChats] = useState(initialChats);
  const [modal, setModal] = useState({ type: null, data: null }); // role_picker, payment_confirm, summary
  const [callInfo, setCallInfo] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const navigate = (screen, chatId = null) => {
    setActiveScreen(screen);
    if (chatId) setSelectedChatId(chatId);
  };

  const selectedChat = chats.find(c => c.id === selectedChatId);

  const sendMessage = (chatId, text) => {
    const newChats = chats.map(chat => {
      if (chat.id === chatId) {
        const newMessages = [...chat.messages, { userId: CURRENT_USER_ID, text, timestamp: "Now" }];
        return { ...chat, messages: newMessages, lastMessage: text, lastMessageTime: "Now" };
      }
      return chat;
    });
    setChats(newChats);
  };
  
  const updateUserRole = (chatId, userId, newRole) => {
      setChats(prevChats => prevChats.map(chat => {
          if (chat.id === chatId && chat.type === 'group') {
              const newParticipants = chat.participants.map(p => 
                  p.userId === userId ? { ...p, role: newRole } : p
              );
              return { ...chat, participants: newParticipants };
          }
          return chat;
      }));
      setModal({type: null, data: null}); // Close modal
  };

  const startCall = (user, type) => {
      setCallInfo({ user, type, status: 'calling' });
      navigate('call');
  };

  const handleSummarizeChat = async (chat) => {
      setIsLoading(true);
      const messageHistory = chat.messages.map(m => `${users[m.userId].name}: ${m.text}`).join('\n');
      const summary = await callGeminiApi(messageHistory, 'summarize');
      setIsLoading(false);
      setModal({ type: 'summary', data: { title: `Summary for ${chat.name}`, content: summary }});
  };

  const renderScreen = () => {
    switch (activeScreen) {
      case 'chat':
        return <ChatScreen 
                    chat={selectedChat} 
                    onBack={() => navigate('chatList')} 
                    onHeaderClick={() => navigate('groupInfo', selectedChatId)} 
                    onSendMessage={sendMessage} 
                    onStartPayment={() => setModal({ type: 'payments', data: selectedChat })} 
                    setIsLoading={setIsLoading}
                />;
      case 'groupInfo':
        return <GroupInfoScreen 
                    chat={selectedChat} 
                    onBack={() => navigate('chat', selectedChatId)} 
                    onRoleChangeClick={(userId) => setModal({type: 'role_picker', data: {chatId: selectedChatId, userId}})} 
                    onStartCall={startCall}
                    onSummarize={handleSummarizeChat}
                />;
      case 'call':
        return <CallingScreen callInfo={callInfo} onEndCall={() => { setCallInfo(null); navigate('callLog'); }} />;
      case 'callLog':
          return <MainLayout activeTab="calls" navigate={navigate} onStartCall={startCall}/>
      default:
        return <MainLayout activeTab="chats" navigate={navigate} chats={chats} />;
    }
  };

  return (
    <div className="bg-gray-900 text-white h-screen w-screen flex items-center justify-center font-sans">
      <div className="relative w-full h-full sm:w-[375px] sm:h-[812px] bg-gray-800 rounded-lg shadow-2xl overflow-hidden">
        {renderScreen()}
        {isLoading && <LoadingSpinner />}
        {modal.type === 'role_picker' && <RolePickerModal data={modal.data} onAssignRole={updateUserRole} onClose={() => setModal({type: null, data: null})} />}
        {modal.type === 'payments' && <PaymentsScreen chat={modal.data} onClose={() => setModal({type: null, data: null})} onConfirm={(details) => { console.log('Payment Confirmed:', details); setModal({ type: 'payment_confirm', data: details }); }} />}
        {modal.type === 'payment_confirm' && <PaymentConfirmationModal details={modal.data} onClose={() => setModal({type: null, data: null})} />}
        {modal.type === 'summary' && <SummaryModal data={modal.data} onClose={() => setModal({type: null, data: null})} />}
      </div>
    </div>
  );
}

// --- Layout & Screen Components ---

const LoadingSpinner = () => (
    <div className="absolute inset-0 bg-black/60 flex items-center justify-center z-[100] backdrop-blur-sm">
        <div className="w-16 h-16 border-4 border-t-cyan-400 border-gray-600 rounded-full animate-spin"></div>
    </div>
);


const MainLayout = ({ activeTab, navigate, chats, onStartCall }) => {
  const [currentTab, setCurrentTab] = useState(activeTab);

  return (
    <div className="h-full flex flex-col">
      <AppHeader />
      <div className="flex-grow overflow-y-auto">
        {currentTab === 'chats' && <ChatListScreen chats={chats} onChatSelect={(id) => navigate('chat', id)} />}
        {currentTab === 'calls' && <CallLogScreen onStartCall={onStartCall} />}
      </div>
      <AppTabs activeTab={currentTab} onTabChange={(tab) => {
          setCurrentTab(tab)
          if(tab === 'calls') navigate('callLog');
          if(tab === 'chats') navigate('chatList');
        }} 
      />
    </div>
  );
};

const AppHeader = () => (
  <header className="bg-gray-900/80 backdrop-blur-sm p-4 flex justify-between items-center shadow-md z-10">
    <h1 className="text-2xl font-bold text-cyan-400">ChitChat</h1>
    <div className="flex items-center space-x-4">
      <icons.search className="text-gray-400" />
      <icons.ellipsisVertical className="text-gray-400" />
    </div>
  </header>
);

const AppTabs = ({ activeTab, onTabChange }) => (
  <div className="bg-gray-900 grid grid-cols-3 gap-2 p-2">
    <TabButton icon={<icons.camera />} label="Status" isActive={activeTab === 'status'} onClick={() => onTabChange('status')} />
    <TabButton icon={<icons.users />} label="Chats" isActive={activeTab === 'chats'} onClick={() => onTabChange('chats')} count={3} />
    <TabButton icon={<icons.phone />} label="Calls" isActive={activeTab === 'calls'} onClick={() => onTabChange('calls')} />
  </div>
);

const TabButton = ({ icon, label, isActive, onClick, count }) => (
  <button onClick={onClick} className={`flex flex-col items-center justify-center p-2 rounded-lg transition-colors ${isActive ? 'bg-cyan-500/20 text-cyan-400' : 'text-gray-400 hover:bg-gray-700'}`}>
    <div className="relative">
      {icon}
      {count > 0 && <span className="absolute -top-1 -right-2 bg-cyan-500 text-white text-xs rounded-full h-4 w-4 flex items-center justify-center">{count}</span>}
    </div>
    <span className="text-xs mt-1">{label}</span>
  </button>
);


const ChatListScreen = ({ chats, onChatSelect }) => (
  <div className="p-2 space-y-1">
    {chats.map(chat => (
      <div key={chat.id} onClick={() => onChatSelect(chat.id)} className="flex items-center p-3 rounded-lg cursor-pointer hover:bg-gray-700/50 transition-colors">
        <img src={users[chat.participants.find(p => p.userId !== CURRENT_USER_ID)?.userId || chat.participants[0].userId]?.avatar} alt="avatar" className="w-12 h-12 rounded-full mr-4" />
        <div className="flex-grow">
          <p className="font-semibold">{chat.name}</p>
          <p className="text-sm text-gray-400 truncate">{chat.lastMessage}</p>
        </div>
        <div className="text-right flex flex-col items-end">
          <span className={`text-xs ${chat.unread > 0 ? 'text-cyan-400' : 'text-gray-500'}`}>{chat.lastMessageTime}</span>
          {chat.unread > 0 && <span className="mt-1 bg-cyan-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">{chat.unread}</span>}
        </div>
      </div>
    ))}
  </div>
);

const CallLogScreen = ({ onStartCall }) => (
    <div className="p-2 space-y-1">
      {callLogs.map(log => (
        <div key={log.id} className="flex items-center p-3 rounded-lg hover:bg-gray-700/50 transition-colors">
          <img src={log.user.avatar} alt="avatar" className="w-12 h-12 rounded-full mr-4" />
          <div className="flex-grow">
            <p className={`font-semibold ${log.direction === 'missed' ? 'text-red-400' : 'text-white'}`}>{log.user.name}</p>
            <p className="text-sm text-gray-400 flex items-center">
              {log.direction === 'incoming' && <span className="transform rotate-180 -mr-1">↘</span>}
              {log.direction === 'outgoing' && <span>↗</span>}
              {log.direction === 'missed' && <span className="transform rotate-180 -mr-1 text-red-400">↘</span>}
              <span className="ml-2">{log.time}</span>
            </p>
          </div>
          <div className="flex space-x-4">
              <button onClick={() => onStartCall(log.user, 'audio')} className="text-cyan-400 hover:text-cyan-300">
                  <icons.phone className="w-6 h-6"/>
              </button>
              <button onClick={() => onStartCall(log.user, 'video')} className="text-cyan-400 hover:text-cyan-300">
                  <icons.video className="w-6 h-6"/>
              </button>
          </div>
        </div>
      ))}
    </div>
);

const ChatScreen = ({ chat, onBack, onHeaderClick, onSendMessage, onStartPayment, setIsLoading }) => {
  const [message, setMessage] = useState('');
  const [suggestedReplies, setSuggestedReplies] = useState([]);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [chat.messages]);
  
  const handleSend = () => {
    if (message.trim()) {
      onSendMessage(chat.id, message);
      setMessage('');
      setSuggestedReplies([]);
    }
  };

  const handleSuggestReplies = async () => {
    setIsLoading(true);
    setSuggestedReplies([]);
    const messageHistory = chat.messages.slice(-3).map(m => `${users[m.userId].name}: ${m.text}`).join('\n');
    const replies = await callGeminiApi(messageHistory, 'suggest_replies');
    setSuggestedReplies(replies);
    setIsLoading(false);
  };

  const useSuggestion = (reply) => {
      setMessage(reply);
      setSuggestedReplies([]);
  }

  return (
    <div className="h-full flex flex-col bg-gray-800">
      <header className="bg-gray-900/80 backdrop-blur-sm p-3 flex items-center shadow-md z-10">
        <button onClick={onBack} className="mr-3 p-1 rounded-full hover:bg-gray-700"><icons.arrowLeft /></button>
        <div className="flex-grow cursor-pointer" onClick={onHeaderClick}>
          <h2 className="font-bold">{chat.name}</h2>
          <p className="text-xs text-gray-400">
             {chat.type === 'group' ? `${chat.participants.length} members` : 'online'}
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <icons.video className="cursor-pointer" />
          <icons.phone className="cursor-pointer" />
          <icons.ellipsisVertical className="cursor-pointer" />
        </div>
      </header>
      
      <div className="flex-grow p-4 overflow-y-auto space-y-4 bg-center bg-cover" style={{backgroundImage: "url('https://i.pinimg.com/736x/8c/98/99/8c98994518b575bfd8c949e91d20548b.jpg')"}}>
        {chat.messages.map((msg, index) => (
          <MessageBubble key={index} message={msg} />
        ))}
        <div ref={messagesEndRef} />
      </div>

      {suggestedReplies.length > 0 && (
          <div className="p-2 bg-gray-900/50 backdrop-blur-sm flex items-center gap-2 overflow-x-auto">
              {suggestedReplies.map((reply, i) => (
                  <button key={i} onClick={() => useSuggestion(reply)} className="bg-cyan-500/20 text-cyan-300 text-sm py-1 px-3 rounded-full whitespace-nowrap hover:bg-cyan-500/40">{reply}</button>
              ))}
          </div>
      )}

      <div className="bg-gray-900/80 backdrop-blur-sm p-3 flex items-center">
        <button onClick={handleSuggestReplies} className="p-2 text-gray-400 hover:text-cyan-400">
            <icons.sparkles />
        </button>
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSend()}
          placeholder="Type a message..."
          className="flex-grow bg-gray-700 rounded-full py-2 px-4 focus:outline-none"
        />
        <button onClick={onStartPayment} className="p-2 text-gray-400 hover:text-cyan-400"><icons.dollarSign /></button>
        <button className="p-2 text-gray-400 hover:text-cyan-400"><icons.paperclip /></button>
        <button onClick={handleSend} className="bg-cyan-500 text-white rounded-full p-3 ml-2 hover:bg-cyan-600 transition-colors">
          {message ? <icons.send className="w-5 h-5"/> : <icons.mic className="w-5 h-5"/>}
        </button>
      </div>
    </div>
  );
};

const MessageBubble = ({ message }) => {
  const isSent = message.userId === CURRENT_USER_ID;
  const sender = users[message.userId];
  
  return (
    <div className={`flex items-end gap-2 ${isSent ? 'justify-end' : 'justify-start'}`}>
      {!isSent && <img src={sender.avatar} alt="avatar" className="w-6 h-6 rounded-full"/>}
      <div className={`max-w-xs md:max-w-md rounded-2xl px-4 py-2 ${isSent ? 'bg-cyan-600 rounded-br-none' : 'bg-gray-700 rounded-bl-none'}`}>
        {!isSent && <p className="text-xs font-bold text-cyan-400 mb-1">{sender.name}</p>}
        <p className="text-white break-words">{message.text}</p>
        <p className="text-xs text-gray-300 text-right mt-1">{message.timestamp}</p>
      </div>
    </div>
  );
};

const GroupInfoScreen = ({ chat, onBack, onRoleChangeClick, onStartCall, onSummarize }) => {
  const currentUserRole = chat.participants.find(p => p.userId === CURRENT_USER_ID)?.role;

  return (
    <div className="h-full flex flex-col bg-gray-800">
      <header className="bg-gray-900/80 p-3 flex items-center shadow-md">
        <button onClick={onBack} className="mr-3 p-1 rounded-full hover:bg-gray-700"><icons.arrowLeft /></button>
        <h2 className="font-bold text-xl">Group Info</h2>
      </header>
      <div className="p-4 text-center">
        <img src={users[chat.participants[1].userId].avatar} alt="group icon" className="w-24 h-24 rounded-full mx-auto mb-4 ring-4 ring-cyan-500" />
        <h3 className="text-2xl font-bold">{chat.name}</h3>
        <p className="text-gray-400">{chat.participants.length} members</p>
      </div>
      <div className="p-4 flex-grow overflow-y-auto">
        <button onClick={() => onSummarize(chat)} className="w-full flex items-center justify-center gap-2 p-3 mb-4 rounded-lg bg-cyan-500/20 text-cyan-300 hover:bg-cyan-500/30 transition-colors">
            <icons.sparkles className="w-5 h-5" />
            <span className="font-semibold">✨ Summarize Recent Activity</span>
        </button>
        <div className="p-4 bg-gray-900/50 rounded-lg">
            <h4 className="font-bold text-lg mb-2 text-cyan-400">Participants</h4>
            <div className="space-y-2">
            {chat.participants.map(({ userId, role }) => {
                const user = users[userId];
                const canChangeRole = currentUserRole === 'admin' && userId !== CURRENT_USER_ID;
                return (
                <div key={userId} className="flex items-center justify-between bg-gray-700/50 p-3 rounded-lg">
                    <div className="flex items-center min-w-0">
                        <img src={user.avatar} alt="avatar" className="w-10 h-10 rounded-full mr-3 flex-shrink-0" />
                        <div className="min-w-0">
                            <p className="font-semibold truncate">{user.name}</p>
                            <p className="text-xs capitalize" style={{color: role === 'admin' ? '#FBBF24' : role === 'moderator' ? '#60A5FA' : '#9CA3AF'}}>{role}</p>
                        </div>
                    </div>
                    {canChangeRole ? (
                    <button onClick={() => onRoleChangeClick(userId)} className="text-sm text-cyan-400 hover:underline">
                        Change Role
                    </button>
                    ) : (
                    <div className="flex items-center space-x-2">
                        <button onClick={() => onStartCall(user, 'audio')} className="p-2 text-gray-400 hover:text-cyan-400"><icons.phone/></button>
                        <button onClick={() => onStartCall(user, 'video')} className="p-2 text-gray-400 hover:text-cyan-400"><icons.video/></button>
                    </div>
                    )}
                </div>
                );
            })}
            </div>
        </div>
      </div>
    </div>
  );
};


const RolePickerModal = ({ data, onAssignRole, onClose }) => {
  const { chatId, userId } = data;
  const user = users[userId];
  const roles = ['participant', 'moderator', 'admin'];

  return (
    <div className="absolute inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm" onClick={onClose}>
      <div className="bg-gray-800 rounded-lg shadow-xl p-6 w-80" onClick={e => e.stopPropagation()}>
        <h3 className="text-lg font-bold mb-2">Change Role for</h3>
        <p className="text-cyan-400 mb-4">{user.name}</p>
        <div className="space-y-2">
          {roles.map(role => (
            <button key={role} onClick={() => onAssignRole(chatId, userId, role)} className="w-full text-left p-3 rounded-md bg-gray-700 hover:bg-cyan-500/50 transition-colors capitalize">
              {role}
            </button>
          ))}
        </div>
        <button onClick={onClose} className="w-full mt-4 p-2 rounded-md bg-gray-600 hover:bg-gray-500">Cancel</button>
      </div>
    </div>
  );
};

const PaymentsScreen = ({ chat, onClose, onConfirm }) => {
    const [amount, setAmount] = useState('');
    const [note, setNote] = useState('');
    const [method, setMethod] = useState(null);
    const recipient = chat.type === 'direct' ? chat.name : 'the group';

    const paymentMethods = [
        { id: 'jazzcash', name: 'JazzCash', icon: '📱', color: 'bg-red-500' },
        { id: 'easypaisa', name: 'EasyPaisa', icon: '📱', color: 'bg-green-500' },
        { id: 'upaisa', name: 'UPaisa', icon: '📱', color: 'bg-blue-500' },
        { id: 'bank', name: 'Bank Transfer', icon: <icons.bank className="w-6 h-6"/>, color: 'bg-gray-600' }
    ];

    const handleConfirm = () => {
        if (amount && method) {
            onConfirm({ amount, note, method, recipient });
        }
    };

    return (
        <div className="absolute inset-0 bg-black/60 flex items-end justify-center z-50 backdrop-blur-sm" onClick={onClose}>
            <div className="bg-gray-800 rounded-t-2xl shadow-xl p-6 w-full max-w-md" onClick={e => e.stopPropagation()}>
                <h3 className="text-xl font-bold mb-2 text-center">Send Payment</h3>
                <p className="text-center text-gray-400 mb-6">to {recipient}</p>

                <div className="relative mb-6">
                    <span className="absolute left-3 top-1/2 -translate-y-1/2 text-3xl text-gray-400">Rs</span>
                    <input
                        type="number"
                        value={amount}
                        onChange={e => setAmount(e.target.value)}
                        placeholder="0"
                        className="w-full bg-transparent text-5xl font-bold text-center pl-12 focus:outline-none"
                    />
                </div>
                
                <input type="text" value={note} onChange={e => setNote(e.target.value)} placeholder="Add a note (optional)" className="w-full bg-gray-700 rounded-md p-3 mb-6 focus:outline-none" />
                
                <div className="grid grid-cols-2 gap-4 mb-6">
                    {paymentMethods.map(m => (
                        <button key={m.id} onClick={() => setMethod(m.name)} className={`p-4 rounded-lg flex flex-col items-center justify-center transition-all ${method === m.name ? 'ring-2 ring-cyan-400 bg-gray-600' : 'bg-gray-700 hover:bg-gray-600'}`}>
                           <div className={`w-10 h-10 rounded-full flex items-center justify-center text-xl mb-2 ${m.color}`}>{m.icon}</div>
                           <span className="font-semibold text-sm">{m.name}</span>
                        </button>
                    ))}
                </div>

                <button onClick={handleConfirm} disabled={!amount || !method} className="w-full p-4 rounded-lg bg-cyan-600 text-white font-bold disabled:bg-gray-600 disabled:opacity-50 hover:bg-cyan-700 transition-colors">
                    Send Payment
                </button>
            </div>
        </div>
    );
};

const PaymentConfirmationModal = ({ details, onClose }) => (
    <div className="absolute inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm" onClick={onClose}>
        <div className="bg-gray-800 rounded-lg shadow-xl p-8 w-80 text-center" onClick={e => e.stopPropagation()}>
            <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-4">
                <icons.check className="w-10 h-10 text-white" />
            </div>
            <h3 className="text-xl font-bold mb-2">Payment Sent!</h3>
            <p className="text-gray-300">You sent <span className="font-bold text-white">Rs {details.amount}</span> to <span className="font-bold text-white">{details.recipient}</span> via <span className="font-bold text-white">{details.method}</span>.</p>
            <button onClick={onClose} className="w-full mt-6 p-2 rounded-md bg-cyan-600 hover:bg-cyan-500">Done</button>
        </div>
    </div>
);

const CallingScreen = ({ callInfo, onEndCall }) => {
    const { user, type, status } = callInfo;
    return (
        <div className="h-full flex flex-col items-center justify-between bg-gray-900 p-8">
            <div className="text-center mt-16">
                <img src={user.avatar} alt="avatar" className="w-32 h-32 rounded-full mx-auto mb-4 ring-4 ring-cyan-500/50" />
                <h2 className="text-3xl font-bold">{user.name}</h2>
                <p className="text-gray-400 capitalize">{status}...</p>
            </div>
            
            {type === 'video' && 
              <div className="absolute top-0 left-0 w-full h-full bg-gray-800 -z-10">
                {/* This would be the remote video stream */}
                <img src={user.avatar} className="object-cover w-full h-full blur-sm opacity-50"/>
                <div className="absolute bottom-4 right-4 w-24 h-36 bg-gray-700 rounded-lg border-2 border-white">
                    {/* This would be the local video stream */}
                </div>
              </div>
            }

            <div className="flex items-center justify-center space-x-6 mb-16">
                <button className="bg-white/10 p-4 rounded-full text-white backdrop-blur-sm"><icons.volume2 /></button>
                <button className="bg-white/10 p-4 rounded-full text-white backdrop-blur-sm"><icons.micOff /></button>
                <button onClick={onEndCall} className="bg-red-500 p-5 rounded-full text-white animate-pulse"><icons.phoneOff /></button>
            </div>
        </div>
    );
};

const SummaryModal = ({ data, onClose }) => (
    <div className="absolute inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm" onClick={onClose}>
        <div className="bg-gray-800 rounded-lg shadow-xl p-6 w-80" onClick={e => e.stopPropagation()}>
            <div className="flex items-center mb-4">
                <icons.sparkles className="w-6 h-6 text-cyan-400 mr-2"/>
                <h3 className="text-lg font-bold">{data.title}</h3>
            </div>
            <p className="text-gray-300 text-sm mb-4">{data.content}</p>
            <button onClick={onClose} className="w-full mt-4 p-2 rounded-md bg-gray-600 hover:bg-gray-500">Close</button>
        </div>
    </div>
);


