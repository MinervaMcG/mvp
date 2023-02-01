import React from "react";
import NewTalentCard from "src/components/design_system/cards/NewTalentCard";
import { useWindowDimensionsHook } from "src/utils/window";

import { displayableAmount } from "src/utils/viewHelpers";

import cx from "classnames";

const TalentTableCardMode = ({
  updateFollow,
  talents,
  publicPageViewer = false,
  env,
}) => {
  const { mobile } = useWindowDimensionsHook();

  return (
    <div
      className={cx(
        "w-100 d-flex flex-wrap talents-cards-container",
        mobile ? "justify-content-center" : "justify-start"
      )}
    >
      {talents.map((talent) => (
        <div key={talent.id} className={cx("mb-3", !mobile && "pr-4")}>
          <NewTalentCard
            name={talent.user.name}
            ticker={talent.talentToken.ticker}
            contractId={talent.talentToken.contractId}
            occupation={talent.occupation}
            profilePictureUrl={talent.profilePictureUrl}
            headline={talent.headline}
            isFollowing={talent.isFollowing}
            updateFollow={() => updateFollow(talent)}
            talentLink={`/u/${talent.user.username}`}
            marketCap={displayableAmount(talent.marketCap)}
            supporterCount={talent.supportersCount?.toString()}
            publicPageViewer={publicPageViewer}
            isVerified={talent.isVerified}
            profileType={talent.user.profileType}
            chainId={talent.talentToken.chainId}
            userId={talent.user.id}
            env={env}
          />
        </div>
      ))}
    </div>
  );
};

export default TalentTableCardMode;
