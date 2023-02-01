import React, { useEffect, useState, useContext } from "react";
import debounce from "lodash/debounce";

import { post, get } from "src/utils/requests";
import { setupChannel, removeChannel } from "channels/message_channel";

import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";

import MessageUserList from "./MessageUserList";
import MessageExchange from "./MessageExchange";
import { useWindowDimensionsHook } from "../../utils/window";

const Chat = ({ chats, user, pagination }) => {
  const url = new URL(document.location);
  const [activeUserId, setActiveUserId] = useState(
    url.searchParams.get("user") || 0
  );
  const [localChats, setLocalChats] = useState(chats);
  const [localPagination, setLocalPagination] = useState(pagination);
  const [perkId] = useState(url.searchParams.get("perk") || 0);
  const [activeChannel, setActiveChannel] = useState(null); // @TODO: Refactor chat
  const [messages, setMessages] = useState([]);
  const [message, setMessage] = useState("");
  const [lastMessageId, setLastMessageId] = useState(0);
  const [searchValue, setSearchValue] = useState(
    url.searchParams.get("q") || ""
  );
  const [chatId, setChatId] = useState("");
  const [sendingMessage, setSendingMessage] = useState(false);
  const [gettingMessages, setGettingMessages] = useState(false);
  const [messengerProfilePicture, setMessengerProfilePicture] = useState();
  const [messengerUsername, setMessengerUsername] = useState();
  const [lastOnline, setLastOnline] = useState();
  const { mobile } = useWindowDimensionsHook();
  const theme = useContext(ThemeContext);

  const updateChats = (previousChats, newChat) => {
    const receiverIndex = previousChats.findIndex(
      (chat) => chat.receiver_id === newChat.receiver_id
    );

    const newChats = [
      {
        ...previousChats[receiverIndex],
        ...newChat,
      },
      ...previousChats.slice(0, receiverIndex),
      ...previousChats.slice(receiverIndex + 1),
    ];

    return newChats;
  };

  // Get user from URL
  useEffect(() => {
    if (activeUserId == 0) {
      return;
    }

    if (activeUserId == user.id) {
      window.location.replace("/messages");
    }

    setGettingMessages(true);
    setMessage("");
    setMessages([]);

    get(`messages/${activeUserId}`).then((response) => {
      setMessages(response.messages);
      setLastMessageId(response.messages[response.messages.length - 1]?.id);
      setChatId(response.chat_id || "");
      setMessengerProfilePicture(response.profilePictureUrl);
      setMessengerUsername(response.username);
      setLastOnline(response.lastOnline);
      setGettingMessages(false);
      if (response.readChat) {
        setLocalChats((previousChats) =>
          updateChats(previousChats, response.readChat)
        );
      }
    });
  }, [activeUserId]);

  useEffect(() => {
    if (perkId <= 0) {
      return;
    }

    get(`api/v1/perks/${perkId}`).then((response) => {
      if (response.title) {
        setMessage(
          `Hi! I'm reaching out because of your perk "${response.title}"`
        );
      }
    });
  }, [perkId]);

  useEffect(() => {
    if (chatId != "") {
      setActiveChannel(setupChannel(chatId, getNewMessage));
    }

    return () => {
      if (activeChannel) {
        removeChannel(activeChannel);
      }
    };
  }, [chatId, messages]);

  useEffect(() => {
    const element = document.getElementById(`message-date-${lastMessageId}`);
    if (element) {
      element.scrollIntoView({ behavior: "smooth" });
    }
  }, [lastMessageId, messages]);

  const getNewMessage = (response) => {
    setMessages([...messages, response.message]);
    setLastMessageId(response.message.id);
  };

  const sendNewMessage = () => {
    if (message.replace(/\s+/g, "") == "") {
      return;
    }

    setSendingMessage(true);

    post("/messages", { id: activeUserId, message }).then((response) => {
      if (response.error) {
        console.log(response.error);
        // setError("Unable to send message, try again") // @TODO: Create error box (absolute positioned)
      } else {
        setLocalChats((previousChats) =>
          updateChats(previousChats, response.chat)
        );
        setMessages([...messages, response.message]);
        setLastMessageId(response.message.id);
        setMessage("");
      }
      setSendingMessage(false);
    });
  };

  const debouncedNewMessage = debounce(() => sendNewMessage(), 200);

  const ignoreAndCallDebounce = (e) => {
    e.preventDefault();
    debouncedNewMessage();
  };

  const clearActiveUser = () => {
    setActiveUserId(0);
    setMessages([]);
    setMessage("");
  };

  const setActiveUser = (userId) => {
    setActiveUserId(userId);
    window.history.pushState({}, document.title, `/messages?user=${userId}`);
  };

  window.addEventListener("popstate", () => {
    const params = new URLSearchParams(document.location.search);
    setActiveUserId(params.get("user"));
  });

  useEffect(() => {
    const currentUserId = localChats.findIndex(
      (chat) => chat.receiver_id === activeUserId
    );

    if (
      currentUserId > 0 &&
      localChats.length > 0 &&
      localChats[currentUserId].unreadMessagesCount > 0
    ) {
      const newChats = [
        ...localChats.slice(0, currentUserId),
        {
          ...localChats[currentUserId],
          unreadMessagesCount: 0,
        },
        ...localChats.slice(currentUserId + 1),
      ];
      setLocalChats(newChats);
    }
  }, [activeUserId]);

  const messagingDisabled = () => {
    const activeUser = chats.find((chat) => chat.receiver_id == activeUserId);
    return (
      user.messagingDisabled || (activeUser && activeUser.messagingDisabled)
    );
  };

  const activeUserWithTalent = () => {
    const activeUser = chats.find((chat) => chat.receiver_id == activeUserId);
    return activeUser && activeUser.receiver_with_talent;
  };

  const loadMoreChats = () => {
    const nextPage = localPagination.currentPage + 1;

    get(`messages?page=${nextPage}&q=${searchValue}`).then((response) => {
      const newChats = [...localChats, ...response.chats];
      setLocalChats(newChats);
      setLocalPagination(response.pagination);
    });
  };

  const showLoadMoreChats = () => {
    return localPagination.currentPage < localPagination.lastPage;
  };

  const searchChats = (value) => {
    setSearchValue(value);
    get(`messages?page=1&q=${value}`).then((response) => {
      setLocalChats(response.chats);
      setLocalPagination(response.pagination);
    });
  };

  const debouncedSearchChats = debounce(searchChats, 300);

  return (
    <>
      <div className="d-flex flex-column w-100 h-100 themed-border-top">
        <main className="d-flex flex-row h-100 themed-border-left chat-container">
          {(!mobile || activeUserId == 0) && (
            <section className="col-lg-4 mx-auto mx-lg-0 px-0 d-flex flex-column themed-border-right chat-section">
              <MessageUserList
                onClick={(userId) => setActiveUser(userId)}
                activeUserId={activeUserId}
                chats={localChats}
                setChats={setLocalChats}
                mode={theme.mode()}
                mobile={mobile}
                messengerWithTalent={user.withTalent}
                supportersCount={user.supportersCount}
                showLoadMoreChats={showLoadMoreChats()}
                loadMoreChats={loadMoreChats}
                searchChats={debouncedSearchChats}
                searchValue={searchValue}
              />
            </section>
          )}
          {(!mobile || activeUserId > 0) && !gettingMessages && (
            <section className="col-lg-8 px-0 lg-overflow-y-hidden themed-border-right chat-section">
              <MessageExchange
                smallScreen={mobile}
                activeUserId={activeUserId}
                clearActiveUserId={() => clearActiveUser()}
                value={message}
                onChange={setMessage}
                onSubmit={ignoreAndCallDebounce}
                messages={messages}
                sendingMessage={sendingMessage}
                messagingDisabled={messagingDisabled()}
                user={user}
                profilePictureUrl={messengerProfilePicture}
                username={messengerUsername}
                lastOnline={lastOnline}
                messengerWithTalent={activeUserWithTalent()}
                supportersCount={user.supportersCount}
                mode={theme.mode()}
              />
            </section>
          )}
        </main>
      </div>
    </>
  );
};

export default (props, railsContext) => {
  return () => (
    <ThemeContainer>
      <Chat {...props} railsContext={railsContext} />
    </ThemeContainer>
  );
};
