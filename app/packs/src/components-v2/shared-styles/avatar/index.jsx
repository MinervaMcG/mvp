import React from "react";
import { StyledImage } from "./styles";

export const Avatar = ({ src, size, userOrTalentId = 0 }) => (
  <StyledImage
    src={
      src ||
      // eslint-disable-next-line no-undef
      require(`images/default-profile-icon-${Math.floor((userOrTalentId || 0) % 5)}.png`)
    }
    size={size}
  />
);
