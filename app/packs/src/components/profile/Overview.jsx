import React, { useState } from "react";
import dayjs from "dayjs";

import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import { H4, H5, P2 } from "src/components/design_system/typography";
import { useWindowDimensionsHook } from "src/utils/window";
import UserTags from "src/components/talent/UserTags";
import Button from "src/components/design_system/button";
import StakeModal from "src/components/token/StakeModal";
import { Globe, Calendar, Envelope } from "src/components/icons";
import { lightTextPrimary04, darkTextPrimary04 } from "src/utils/colors";

import cx from "classnames";

const Overview = ({ className, talent, currentUserId, railsContext }) => {
  console.log({ talent });
  const joinedAt = dayjs(talent.user.createdAt).format("MMMM YYYY");
  const talentIsFromCurrentUser = talent.userId == currentUserId;

  const { mobile } = useWindowDimensionsHook();
  const [showStakeModal, setShowStakeModal] = useState(false);

  return (
    <div className={cx(className)}>
      <div className={cx(mobile ? "" : "d-flex", "mb-7")}>
        <div className={cx(mobile ? "col-12" : "col-6")}>
          <TalentProfilePicture
            className="mb-3"
            src={talent.profilePictureUrl}
            height={120}
          />
          <H4
            className="mb-1"
            bold
            text={talent.user.displayName || talent.user.username}
          />
          <P2 className="text-primary-03 mb-4" text={talent.occupation} />
          {mobile && (
            <div className="d-flex mb-4">
              <a href="/messages" className="button-link">
                <Button
                  className="mr-2"
                  type="white-outline"
                  size="icon"
                  onClick={() => null}
                >
                  <Envelope
                    className="h-100"
                    color="currentColor"
                    size={16}
                    viewBox="0 0 24 24"
                  />
                </Button>
              </a>
            </div>
          )}
          <H5 className="text-primary-01 mb-4" text={talent.headline} />
          <UserTags
            tags={talent.tags.map((tag) => tag.description)}
            className="mr-2 mb-4"
          />
          <div className="mb-4">Market cap and etc</div>
          <div className="d-flex align-items-center mb-4">
            <div className="mr-4 d-flex align-items-center">
              <Globe className="mr-2" size={16} color={lightTextPrimary04} />
              <P2 className="text-primary-03" text={talent.profile.location} />
            </div>
            <div className="mr-4 d-flex align-items-center">
              <Calendar className="mr-2" size={16} color={lightTextPrimary04} />
              <P2 className="text-primary-03" text={`Joined ${joinedAt}`} />
            </div>
          </div>
          {talent.user.invitedBy && (
            <div className="d-flex align-items-center">
              <P2 className="mr-3" text="Invited by" />
              <TalentProfilePicture
                className="mr-2"
                src={talent.user.invitedBy.profilePictureUrl}
                height={32}
              />
              <P2 bold text={talent.user.invitedBy.name} />
            </div>
          )}
        </div>
        {!mobile && <div className="col-1"></div>}
        {!mobile && (
          <div
            className={cx(
              mobile ? "col-12" : "col-5 p-0",
              "d-flex flex-column align-items-end justify-content-center"
            )}
          >
            <TalentProfilePicture
              className="banner-profile"
              src={talent.bannerUrl}
              straight
            />
          </div>
        )}
      </div>
      <div className="d-flex align-items-center justify-content-between">
        <div></div>
        {!mobile && (
          <div>
            <a href="/messages" className="button-link">
              <Button
                className="mr-2"
                type="white-outline"
                size="icon"
                onClick={() => null}
              >
                <Envelope
                  className="h-100"
                  color="currentColor"
                  size={16}
                  viewBox="0 0 24 24"
                />
              </Button>
            </a>
            <Button
              type="primary-default"
              text="Support"
              onClick={() => setShowStakeModal(true)}
            />
          </div>
        )}
        {mobile && (
          <Button
            className="w-100 mx-4"
            type="primary-default"
            size="extra-big"
            text="Support"
            onClick={() => setShowStakeModal(true)}
          />
        )}
      </div>
      <StakeModal
        show={showStakeModal}
        setShow={setShowStakeModal}
        tokenAddress={talent.token.contractId}
        tokenId={talent.token.id}
        userId={currentUserId}
        talentUserId={talent.userId}
        tokenChainId={talent.token.chainId}
        talentName={talent.user.displayName || talent.user.username}
        ticker={talent.token.ticker}
        talentIsFromCurrentUser={talentIsFromCurrentUser}
        railsContext={railsContext}
      />
    </div>
  );
};

export default Overview;
