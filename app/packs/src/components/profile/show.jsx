import React, { useContext } from "react";

import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";

import Poaps from "./web3/poaps";
import Nfts from "./web3/nfts";
import Tokens from "./web3/tokens";

const Show = ({
  admin,
  talent,
  talentToken,
  perks,
  milestones,
  currentUserId,
  user,
  profilePictureUrl,
  bannerUrl,
  tags,
  careerGoal,
  goals,
  posts,
  isFollowing,
  followersCount,
  supportersCount,
  railsContext,
  isCurrentUserImpersonated,
}) => {
  const url = new URL(window.location);
  const searchParams = new URLSearchParams(url.search);

  const theme = useContext(ThemeContext);

  return (
    <div className="d-flex flex-column lg-h-100 p-0">
      <Poaps userId={user.id} />
      <Nfts userId={user.id} />
      <Tokens userId={user.id} />
    </div>
  );
};

export default (props, railsContext) => {
  return () => (
    <ThemeContainer>
      <Show {...props} railsContext={railsContext} />
    </ThemeContainer>
  );
};
