import React, { useState } from "react";

import { Dropdown } from "react-bootstrap";
import Modal from "react-bootstrap/Modal";

import Bell from "../icons/Bell";
import { formatDistance } from "date-fns";
import { patch } from "src/utils/requests";

import { useWindowDimensionsHook } from "../../utils/window";
import NotificationTemplate from "src/components/design_system/notification";
import Button from "src/components/design_system/button";

const Notification = ({ notification, mode }) => {
  const presentDay = new Date();
  const createdAt = new Date(notification.created_at);

  const type = () => {
    switch (notification.type) {
      case "Notifications::TokenAcquired":
        return "wallet";
      case "Notifications::MessageReceived":
        return "chat";
      case "Notifications::TalentListed":
        return "talent";
      case "Notifications::TalentChanged":
        return "star";
      default:
        return "globe";
    }
  };

  return (
    <NotificationTemplate
      type={type()}
      mode={mode}
      title={notification.title}
      description={notification.body}
      time_information={formatDistance(presentDay, createdAt)}
      is_new={!notification.read}
    />
  );
};

const Notifications = ({ notifications, mode, hideBackground = false }) => {
  const { height, width } = useWindowDimensionsHook();
  const [currentNotifications, setCurrentNotifications] =
    useState(notifications);
  const [showNotifications, setShowNotifications] = useState(false);

  const notificationHref = (type, notification) => {
    switch (type) {
      case "Notifications::TokenAcquired":
        return `/talent/${notification.username}/supporters`;
      case "Notifications::MessageReceived":
        return "/messages";
      case "Notifications::TalentListed":
        return "/talent";
      case "Notifications::TalentChanged":
        return `/talent/${notification.source_username}`;
      default:
        return "";
    }
  };

  const notificationsUnread = currentNotifications.some(
    (notif) => notif.read === false
  );

  const notificationRead = async (notification) => {
    if (!notification.read) {
      await patch(`/api/v1/notifications/${notification.id}`, {
        notification: { read: true },
      });
    }
    window.location.href = notificationHref(notification.type, notification);
  };

  if (width < 992) {
    return (
      <>
        <Button
          onClick={() => setShowNotifications(true)}
          type="white-ghost"
          mode={mode}
          className="ml-2"
        >
          <Bell color="currentColor" />
        </Button>
        <Modal
          show={showNotifications}
          fullscreen="true"
          onHide={() => setShowNotifications(false)}
          dialogClassName={"m-0 mh-100 mw-100"}
          backdrop={false}
          className="p-0"
        >
          <Modal.Header closeButton>
            <Modal.Title>Notifications</Modal.Title>
          </Modal.Header>
          <Modal.Body className="d-flex flex-column">
            {currentNotifications.length == 0 && (
              <small className="w-100 text-center">No notifications</small>
            )}
            {currentNotifications.map((notification) => (
              <Button
                onClick={() => notificationRead(notification)}
                type="white-ghost"
                mode={mode}
                className="text-left text-black"
              >
                <Notification notification={notification} mode={mode} />
              </Button>
            ))}
          </Modal.Body>
        </Modal>
      </>
    );
  }

  return (
    <>
      <Dropdown drop="bottom" className="ml-1">
        <Dropdown.Toggle
          className={`user-menu-dropdown-btn no-caret ${mode}${
            hideBackground ? " remove-background" : ""
          }`}
          id="notifications-dropdown"
        >
          <Bell color="currentColor" style={{ marginRight: -10 }} />
          {notificationsUnread && (
            <span className="notifications-unread-icon"></span>
          )}
        </Dropdown.Toggle>

        <Dropdown.Menu
          className="notifications-menu"
          style={width < 400 ? { width: width - 50 } : {}}
        >
          {currentNotifications.length == 0 && (
            <Dropdown.ItemText key="no-notifications">
              <small className="w-100 text-center">No notifications</small>
            </Dropdown.ItemText>
          )}
          {currentNotifications.map((notification) => (
            <Dropdown.Item
              key={`${notification.id}-notification`}
              className="p-0 notifications-menu-dropdown-item"
              onClick={() => notificationRead(notification)}
            >
              <Notification notification={notification} mode={mode} />
            </Dropdown.Item>
          ))}
        </Dropdown.Menu>
      </Dropdown>
    </>
  );
};

export default Notifications;
