import React, { useState } from "react";
import Dropdown from "react-bootstrap/Dropdown";
import TalentProfilePicture from "../talent/TalentProfilePicture";
import Button from "src/components/design_system/button";
import ApplyToLaunchTokenModal from "src/components/design_system/modals/ApplyToLaunchTokenModal";
import { P2 } from "src/components/design_system/typography";

import {
  ArrowFill,
  User,
  Edit,
  Settings,
  SignOut,
  Sun,
  Moon,
} from "src/components/icons";

const UserMenu = ({ user, toggleTheme, mode, onClickTransak, signOut }) => {
  const [showApplyToLaunchTokenModal, setShowApplyToLaunchTokenModal] =
    useState(false);

  const onClickInvites = () => {
    const url = `/u/${user.username}/edit_profile?tab=Invites`;

    window.location.href = url;
  };

  return (
    <Dropdown>
      <Dropdown.Toggle
        className="talent-button white-subtle-button normal-size-button p-2 no-caret d-flex align-items-center text-primary-03"
        id="user-dropdown"
        bsPrefix=""
        as="div"
      >
        <TalentProfilePicture src={user.profilePictureUrl} height={20} />
      </Dropdown.Toggle>

      <Dropdown.Menu className="user-menu-dropdown">
        <Dropdown.Item
          key="tab-dropdown-my-profile"
          className="text-black d-flex flex-row align-items-center user-menu-dropdown-item"
          href={`/u/${user.username}`}
        >
          <User pathClassName="icon-dropdown-item" />
          <P2 bold text="My profile" className="text-black ml-3" />
        </Dropdown.Item>
        <Dropdown.Item
          key="tab-dropdown-settings"
          className="text-black d-flex flex-row align-items-center user-menu-dropdown-item"
          href={`/u/${user.username}/account_settings`}
        >
          <Settings pathClassName="icon-dropdown-item" />
          <P2 bold text="Settings" className="text-black ml-3" />
        </Dropdown.Item>
        <Dropdown.Divider className="menu-divider mx-2 my-2" />
        <Dropdown.Item
          key="tab-dropdown-theme"
          className="text-black d-flex flex-row align-items-center user-menu-dropdown-item"
          onClick={toggleTheme}
        >
          {mode == "light" ? (
            <Moon pathClassName="icon-dropdown-item" color="currentColor" />
          ) : (
            <Sun pathClassName="icon-dropdown-item" color="currentColor" />
          )}
          <P2
            bold
            text={`Dark Theme: ${mode === "light" ? "Off" : "On"}`}
            className="text-black ml-3"
          />
        </Dropdown.Item>
        <Dropdown.Divider className="menu-divider mx-2 my-2" />
        <Dropdown.Item
          key="tab-dropdown-sign-out"
          onClick={signOut}
          className="text-black d-flex flex-row align-items-center user-menu-dropdown-item"
        >
          <SignOut pathClassName="icon-dropdown-item" />
          <P2 bold text="Sign out" className="text-black ml-3" />
        </Dropdown.Item>
        <Dropdown.Divider className="menu-divider mx-2 mt-2 mb-3" />
        {user.isTalent ? (
          <Button
            onClick={onClickInvites}
            type="primary-default"
            size="big"
            className="w-100 mb-2"
          >
            <P2 bold text="Invites" className="bg-01" />
          </Button>
        ) : (
          <Button
            onClick={() => setShowApplyToLaunchTokenModal(true)}
            type="primary-default"
            size="big"
            className="w-100 mb-2"
          >
            <P2 bold text="Apply to Launch Token" className="bg-01" />
          </Button>
        )}
        <Button
          onClick={onClickTransak}
          type="primary-outline"
          size="big"
          className="w-100 mb-2"
        >
          <P2 bold text="Get funds" className="current-color" />
        </Button>
      </Dropdown.Menu>
      <ApplyToLaunchTokenModal
        show={showApplyToLaunchTokenModal}
        hide={() => setShowApplyToLaunchTokenModal(false)}
        investorId={user.investorId}
        username={user.username}
      />
    </Dropdown>
  );
};

export default UserMenu;
