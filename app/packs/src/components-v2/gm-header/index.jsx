import React from "react";
import { Container, InnerContainer } from "./styled";
import { Avatar, useModal } from "@talentprotocol/design-system";
import TextInput from "src/components/design_system/fields/textinput";
import { SendCareerUpdateModal } from "../send-career-update-modal";

export const GmHeader = ({ profile }) => {
  const modalState = useModal();

  return profile ? (
    <Container>
      <Avatar size="md" url={profile.profile_picture_url} userId={1} profileURL={`/u/${profile.username}`} />
      <InnerContainer>
        <TextInput
          placeholder={`What's new in your career ${profile.name}?`}
          onClick={() => modalState.openModal()}
          className="w-100"
        />
        <SendCareerUpdateModal isOpen={modalState.isOpen} closeModal={modalState.closeModal} profile={profile} />
      </InnerContainer>
    </Container>
  ) : (
    <></>
  );
};
