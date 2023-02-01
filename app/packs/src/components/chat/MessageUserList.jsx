import React, { useState } from "react";

import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import customParseFormat from "dayjs/plugin/customParseFormat";
dayjs.extend(customParseFormat);
dayjs.extend(relativeTime);

import TalentProfilePicture from "../talent/TalentProfilePicture";
import NewMessageModal from "./NewMessageModal";
import NewMessageToAllSupportersModal from "./NewMessageToAllSupportersModal";
import ThemedButton from "src/components/design_system/button";
import { P2, P3 } from "src/components/design_system/typography";
import TextInput from "src/components/design_system/fields/textinput";
import { NewChat, Search } from "src/components/icons";

const lastMessageText = (lastMessage) => {
  if (lastMessage) {
    return lastMessage.length > 30
      ? `${lastMessage.substring(0, 28)}...`
      : lastMessage;
  } else {
    return "";
  }
};

const ChatMessage = ({ chat, activeUserId, onClick }) => {
  const message = lastMessageText(chat.last_message_text);
  const active = chat.receiver_id == activeUserId ? " active" : "";

  const displayTime = () => {
    if (chat.last_message_at) {
      return dayjs(chat.last_message_at).fromNow();
    } else {
      return "";
    }
  };

  return (
    <a
      className={`pt-3 pl-6 pr-6 chat-user ${active} text-reset`}
      onClick={() => onClick(chat.receiver_id)}
    >
      <div className="d-flex flex-row justify-content-between themed-border-bottom">
        <TalentProfilePicture
          src={chat.receiver_profile_picture_url}
          height={48}
          userId={chat.receiver_id}
        />
        <div className="d-flex flex-column w-100 h-100 pl-2 pb-3 ml-2">
          <div style={{ minHeight: 48 }}>
            <div className="d-flex flex-row justify-content-between">
              <div className="d-flex flex-row">
                <P2 text={chat.receiver_username} bold className="mr-2" />
              </div>
              <P3 text={displayTime()} />
            </div>
            <div className="d-flex flex-row mb-0 justify-content-between">
              <P2 text={message} className="mr-2" />
              <UnreadMessagesCount count={chat.unread_messages_count} />
            </div>
          </div>
        </div>
      </div>
    </a>
  );
};

const UnreadMessagesCount = ({ count }) => {
  count ||= 0;

  if (count > 0) {
    const value = count > 99 ? "+99" : count.toString();
    return <span className="chat-unread-count">{value}</span>;
  } else {
    return null;
  }
};

const EmptyChats = ({ mode }) => (
  <div className="w-100 p-3 themed-border-top d-flex flex-column align-items-center">
    <ThemedButton
      onClick={() => (window.location.href = "/talent")}
      type="primary-default"
      mode={mode}
    >
      Browse Talent
    </ThemedButton>
  </div>
);

const MessageUserList = ({
  chats,
  setChats,
  activeUserId,
  onClick,
  mode,
  mobile,
  messengerWithTalent,
  supportersCount,
  loadMoreChats,
  showLoadMoreChats,
  searchChats,
  searchValue,
}) => {
  const [showNewMessageModal, setShowNewMessageModal] = useState(false);
  const [showNewMessageToAllSupporters, setShowNewMessageToAllSupporters] =
    useState(false);

  const onNewMessageUser = (user) => {
    onClick(user.id);
    const index = chats.findIndex((chat) => chat.receiver_id == user.id);
    const newChat = {
      receiver_id: user.id,
      receiver_username: user.username,
      receiver_profile_picture_url: user.profilePictureUrl,
    };

    if (index < 0) {
      setChats((prev) => [newChat, ...prev]);
    }
    setShowNewMessageModal(false);
  };

  const onSendMessageToAllSupporters = () => {
    setShowNewMessageModal(false);
    setShowNewMessageToAllSupporters(true);
  };

  const showMessageToAllSupporters = () => {
    return messengerWithTalent && supportersCount > 0;
  };

  return (
    <>
      <NewMessageModal
        show={showNewMessageModal}
        setShow={setShowNewMessageModal}
        onUserChosen={onNewMessageUser}
        setShowMessageToAllSupporters={onSendMessageToAllSupporters}
        mobile={mobile}
        showMessageToAllSupporter={showMessageToAllSupporters()}
        mode={mode}
      />
      <NewMessageToAllSupportersModal
        show={showNewMessageToAllSupporters}
        setShow={setShowNewMessageToAllSupporters}
        mobile={mobile}
      />
      <div className="d-flex flex-column align-items-stretch lg-h-100">
        <div className="w-100 d-flex flex-row themed-border-bottom align-items-center py-4 pl-6 pr-6">
          <div className="position-relative w-100">
            <TextInput
              disabled={chats.length == 0 && searchValue.length == 0}
              onChange={(e) => searchChats(e.target.value)}
              value={searchValue}
              placeholder="Search in messages..."
              inputClassName="pl-5"
              className="w-100"
            />
            <Search
              color="currentColor"
              className="position-absolute chat-search-icon"
            />
          </div>
          <ThemedButton
            onClick={() => setShowNewMessageModal(true)}
            type="white-subtle"
            mode={mode}
            className="ml-2 p-2"
            size="icon"
          >
            <NewChat color="currentColor" />
          </ThemedButton>
        </div>
        {chats.length == 0 && searchValue.length == 0 && (
          <EmptyChats mode={mode} />
        )}
        <div className="w-100 d-flex flex-column lg-overflow-y-scroll lg-h-50">
          {chats.map((chat) => (
            <ChatMessage
              onClick={onClick}
              key={`user-message-list-${chat.receiver_id}`}
              chat={chat}
              activeUserId={activeUserId}
              mode={mode}
            />
          ))}
          {showLoadMoreChats && (
            <ThemedButton
              onClick={() => loadMoreChats()}
              type="white-subtle"
              mode={mode}
              className="mx-6 mt-4"
            >
              Load more
            </ThemedButton>
          )}
        </div>
      </div>
    </>
  );
};

export default MessageUserList;
