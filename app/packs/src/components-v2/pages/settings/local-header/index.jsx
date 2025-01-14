import React from "react";
import { TextLink } from "@talentprotocol/design-system";
import { HeaderContainer, InnerHeaderContainer } from "./styled";
import { useEditProfileStore } from "src/contexts/state";

export const LocalHeader = ({ username, setIsDiscardModalOpen }) => {
  const { subFormCallback } = useEditProfileStore();

  return (
    <>
      <HeaderContainer>
        <InnerHeaderContainer>
          <TextLink
            color="primary01"
            href={!subFormCallback ? `/u/${username}` : undefined}
            text={"Edit Profile"}
            leftIcon="back-arrow"
            size="small"
            onClick={() => {
              if (!subFormCallback) return;
              setIsDiscardModalOpen(true);
            }}
          />
          <div id="save-button"></div>
        </InnerHeaderContainer>
      </HeaderContainer>
    </>
  );
};
