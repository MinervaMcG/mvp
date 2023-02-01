import React, { useEffect, useState } from "react";

import { urlStore } from "src/contexts/state";
import { get } from "src/utils/requests";

import ReferralRace from "./ReferralRace";
import RewardsHeader from "./RewardsHeader";
import Quests from "./quests";

const Tabs = ({ changeTab, activeTab }) => {
  return (
    <div className="talent-table-tabs d-flex flex-row align-items-center overflow-x-scroll hide-scrollbar">
      <div
        onClick={() => changeTab("quests")}
        className={`d-flex align-items-center text-no-wrap talent-table-tab ml-4 ml-lg-0${
          activeTab == "quests" ? " active-talent-table-tab" : ""
        }`}
      >
        Quests
      </div>
      <div
        onClick={() => changeTab("talent")}
        className={`text-no-wrap talent-table-tab${activeTab == "talent" ? " active-talent-table-tab" : ""}`}
      >
        Invites
      </div>
    </div>
  );
};

const Rewards = ({
  user,
  allRaces,
  userRewards,
  raceRewards,
  quests,
  withPersonaRequest,
  race,
  invitedUsers,
  leaderboardResults,
  raceInvitesCount,
  pagination
}) => {
  const changeURL = urlStore(state => state.changeURL);

  const { isEligible } = user;
  const url = new URL(window.location);
  const searchParams = new URLSearchParams(url.search);
  const [activeTab, setTab] = useState("quests");
  const [questId, setQuestId] = useState(null);
  const [localInvitedUsers, setLocalInvitedUsers] = useState(invitedUsers);
  const [localPagination, setLocalPagination] = useState(pagination);

  const changeTab = tab => {
    window.history.pushState({}, document.title, `${url.pathname}?tab=${tab}`);
    changeURL(new URL(document.location));
    setTab(tab);
    setQuestId(null);
  };

  const loadMoreInvitedUsers = () => {
    const nextPage = localPagination.currentPage + 1;

    get(`earn?page=${nextPage}`).then(response => {
      const newInvitedUsers = [...localInvitedUsers, ...response.invitedUsers];
      setLocalInvitedUsers(newInvitedUsers);
      setLocalPagination(response.pagination);
    });
  };

  const showLoadMoreInvitedUsers = localPagination.currentPage < localPagination.lastPage;

  useEffect(() => {
    if (searchParams.get("tab")) {
      setTab(searchParams.get("tab"));
    } else {
      window.history.replaceState({}, document.title, `${url.pathname}?tab=quests`);
    }
  }, [searchParams]);

  window.addEventListener("popstate", () => {
    const params = new URLSearchParams(document.location.search);
    if (document.location.search !== "") {
      setTab(params.get("tab"));
    }
  });

  return (
    <>
      <RewardsHeader rewards={userRewards} />
      <Tabs activeTab={activeTab} changeTab={changeTab} />
      {activeTab == "talent" && (
        <ReferralRace
          allRaces={allRaces}
          raceRewards={raceRewards}
          isEligible={isEligible}
          race={race}
          user={user}
          leaderboardResults={leaderboardResults}
          invitedUsers={localInvitedUsers}
          loadMoreInvitedUsers={loadMoreInvitedUsers}
          showLoadMoreInvitedUsers={showLoadMoreInvitedUsers}
          raceInvitesCount={raceInvitesCount}
        />
      )}
      {activeTab == "quests" && (
        <Quests
          quests={quests}
          questId={questId}
          setQuestId={setQuestId}
          userId={user.id}
          username={user.username}
          withPersonaRequest={withPersonaRequest}
        />
      )}
    </>
  );
};

// eslint-disable-next-line no-unused-vars
export default (props, _railsContext) => {
  return () => <Rewards {...props} />;
};
