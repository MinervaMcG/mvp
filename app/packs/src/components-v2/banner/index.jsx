import React, { useMemo } from "react";
import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import defaultBanner from "images/standard-banner.png";
import { Spinner } from "src/components/icons";
import cameraButtonImage from "images/camera-button.png";
import deleteButtonImage from "images/delete-button.png";
import { Container, EditImagePositioner, ProfilePicture, SpinnerContainer, StyledButton, StyledLabel } from "./styles";
import { useResize } from "../../hooks/use-resize";

export const Banner = ({ bannerUrl, deleteBannerCallback, canUpdate, isUploading }) => {
  const { width } = useResize();
  const uploadSpinner = useMemo(() => (
    <SpinnerContainer>
      <Spinner width={50} />
    </SpinnerContainer>
  ), []);
  const updateActions = useMemo(() => (
    <>
      <input
        id="overviewBannerFileInput"
        className="d-none"
        type="file"
        accept=".jpg,.png,.jpeg,.gif"
      />
      <EditImagePositioner
        className="edit-image banner-profile"
      >
        <StyledLabel htmlFor="overviewBannerFileInput">
          <TalentProfilePicture
            className="cursor-pointer"
            src={cameraButtonImage}
            height={40}
          />
        </StyledLabel>
        <StyledButton
          className="button-link"
          onClick={deleteBannerCallback}
        >
          <TalentProfilePicture
            className="cursor-pointer"
            src={deleteButtonImage}
            height={40}
          />
        </StyledButton>
      </EditImagePositioner>
    </>
  ), []);
  return (
      <Container width={width}>
        {canUpdate && isUploading && uploadSpinner}
        <ProfilePicture
            className="position-relative banner-profile cursor-pointer"
            src={bannerUrl || defaultBanner}
            straight
        />
        {canUpdate && updateActions}
      </Container>
  );
}
