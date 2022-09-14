import React, { useContext } from "react";

import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";

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

  return <div className="d-flex flex-column lg-h-100 p-0"></div>;
};

export default (props, railsContext) => {
  return () => (
    <ThemeContainer>
      <Show {...props} railsContext={railsContext} />
    </ThemeContainer>
  );
};
