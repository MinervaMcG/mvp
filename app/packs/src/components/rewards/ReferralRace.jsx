import React, { useState, useEffect } from "react";
import currency from "currency.js";
import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";

import { get } from "src/utils/requests";

import Dropdown from "react-bootstrap/Dropdown";
import { P1, P2, P3, H4, H3 } from "src/components/design_system/typography";
import { Copy, Help, Spinner, OrderBy } from "src/components/icons";
import Caption from "src/components/design_system/typography/caption";
import Button from "src/components/design_system/button";
import Table from "src/components/design_system/table";
import Tooltip from "src/components/design_system/tooltip";
import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import { lightTextPrimary03 } from "src/utils/colors";
import customParseFormat from "dayjs/plugin/customParseFormat";

dayjs.extend(customParseFormat);

const sumRewardAmounts = (total, reward) => total + reward.amount;

const amountToTal = (amount) => `${currency(amount).dollars()} $TAL`;

dayjs.extend(utc);

const RaceHeader = ({ isEligible, race }) => {
  const [timeUntilEnd, setTimeUntilEnd] = useState({
    days: 7,
    hours: 0,
    minutes: 0,
    seconds: 0,
  });
  let timeoutPointer;

  const updateTimeUntilEnd = () => {
    if (!race) {
      return;
    }
    // All calculations need to be done in UTC
    const currentTime = dayjs().utc();
    let raceEndTime = dayjs(race.ends_at).utc().endOf("day");

    if (currentTime.isAfter(raceEndTime)) {
      setTimeUntilEnd({
        days: 0,
        hours: 0,
        minutes: 0,
        seconds: 0,
      });

      return;
    }

    const days = raceEndTime.diff(currentTime, "days");
    raceEndTime = raceEndTime.subtract(days, "days");
    const hours = raceEndTime.diff(currentTime, "hours");
    raceEndTime = raceEndTime.subtract(hours, "hours");
    const minutes = raceEndTime.diff(currentTime, "minutes");
    raceEndTime = raceEndTime.subtract(minutes, "minutes");
    const seconds = raceEndTime.diff(currentTime, "seconds");

    setTimeUntilEnd({
      days,
      hours,
      minutes,
      seconds,
    });

    timeoutPointer = setTimeout(() => updateTimeUntilEnd(), 1000);
  };

  useEffect(() => {
    if (!isEligible) {
      return;
    }
    updateTimeUntilEnd();

    return () => clearTimeout(timeoutPointer);
  }, [race]);

  const activeRace = () => {
    return race && dayjs(race.started_at).utc() <= dayjs().utc();
  };

  if (!isEligible) {
    return (
      <div className="race-header-row">
        <div className="d-flex flex-column col-lg-5 px-4 px-lg-0">
          <H4 className="mb-4 d-flex flex-row align-items-center" bold>
            Talent Hunt
          </H4>
          <P1>
            To participate in the Talent Hunt you must first complete the
            Beginner Quest. After that you'll be able to join this ongoing
            program that rewards members for referring new talent to our
            community.
          </P1>
        </div>
        <div className="d-flex flex-row justify-content-center justify-content-lg-end col-lg-5 px-4 px-lg-0 mt-5 mt-lg-0">
          <a className="button-link" href="/earn?tab=quests">
            <Button
              onClick={() => null}
              type="primary-default"
              size="extra-big"
              className="mb-4"
            >
              Complete Beginner Quest
            </Button>
          </a>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="race-header-row">
        <div className="d-flex flex-column col-lg-5 px-4 px-lg-0">
          <H4 className="mb-4 d-flex flex-row align-items-center" bold>
            Talent Hunt
          </H4>
          <P1>
            Every week the 3 users who invite the most{" "}
            <a
              href="https://talentprotocol.notion.site/Community-Segments-3b64f6506bdb419ebe48441e7830e97b"
              target="_blank"
            >
              builders
            </a>{" "}
            will win a total of 1000 TAL. The 1st wins 500, the 2nd wins 300 and
            the 3rd 200 TAL. You will earn an additional 100 TAL for every user
            you invite that launches their own Talent Token.
          </P1>
        </div>

        {activeRace() ? (
          <div className="d-flex flex-row justify-content-center justify-content-lg-end col-lg-5 px-4 px-lg-0 mt-5 mt-lg-0">
            <div className="race-time-counter-box">
              <P2>Days</P2>
              <H3 bold>{timeUntilEnd.days}</H3>
            </div>
            <div className="race-time-counter-box">
              <P2>Hours</P2>
              <H3 bold>{timeUntilEnd.hours}</H3>
            </div>
            <div className="race-time-counter-box">
              <P2>Minutes</P2>
              <H3 bold>{timeUntilEnd.minutes}</H3>
            </div>
            <div className="race-time-counter-box hide-content-in-mobile">
              <P2>Seconds</P2>
              <H3 bold>{timeUntilEnd.seconds}</H3>
            </div>
          </div>
        ) : (
          <div className="d-flex flex-column justify-content-center col-lg-5 px-4 px-lg-0 mt-5 mt-lg-0">
            <H3 bold>No active race</H3>
            <P2>
              Stay tunned for the next race!{" "}
              {race &&
                `It will start at: ${dayjs(race.started_at).format(
                  "MMMM D, YYYY"
                )}`}
            </P2>
          </div>
        )}
      </div>
      {activeRace() && (
        <Caption
          className="align-self-end mr-4 mr-lg-0 mt-2"
          text="TIME LEFT UNTIL THIS RACE ENDS"
        />
      )}
    </>
  );
};

const Overview = ({ totalInvitesCount, raceInvitesCount, username }) => {
  const getInviteLink = (full) => {
    if (full) {
      return `https://beta.talentprotocol.com/join/${username}`;
    } else {
      return `https://beta.tal.../join/${username}`;
    }
  };
  const copyLink = () => navigator.clipboard.writeText(getInviteLink(true));

  return (
    <div className="d-flex flex-column px-4 px-lg-0 mt-6 mt-lg-7">
      <H4 className="mb-4 d-flex flex-row align-items-center" bold>
        Overview
      </H4>
      <div className="mx-0 py-6 d-flex flex-column flex-lg-row overview-section">
        <div
          className="d-flex flex-column mx-4 mb-4 mb-lg-0"
          style={{ flex: 1 }}
        >
          <P3 className="mb-2">Invite Link</P3>
          <div className="d-flex flex-row align-items-center">
            <P2 className="text-black">{getInviteLink(false)}</P2>
            <Tooltip
              body={"Copied!"}
              popOverAccessibilityId={"copy_link_success"}
              placement="top"
            >
              <Button
                type="white-ghost"
                size="icon"
                className="text-primary"
                onClick={copyLink}
              >
                <Copy color="currentColor" />
              </Button>
            </Tooltip>
          </div>
        </div>
        <div
          className="d-flex flex-column mx-4 mb-4 mb-lg-0"
          style={{ flex: 1 }}
        >
          <Tooltip
            body={
              "The total amount of invites since you joined Talent Protocol."
            }
            popOverAccessibilityId={"talent_invites_available"}
            placement="left"
          >
            <div className="mb-2 cursor-pointer d-flex align-items-center">
              <P3 className="mr-2">Total Invites</P3>
              <Help color={lightTextPrimary03} />
            </div>
          </Tooltip>
          <div className="d-flex flex-row align-items-center justify-content-between">
            <P2 className="text-black">{totalInvitesCount || 0}</P2>
          </div>
        </div>
        <div
          className="d-flex flex-column mx-4 mb-4 mb-lg-0"
          style={{ flex: 1 }}
        >
          <Tooltip
            body={
              "The number of users that registered with your invite during this race. For an invite to count as used, the new user has to complete the Beginner Quest."
            }
            popOverAccessibilityId={"talent_invites_available"}
            placement="left"
          >
            <div className="mb-2 cursor-pointer d-flex align-items-center">
              <P3 className="mr-2">Invites this race</P3>
              <Help color={lightTextPrimary03} />
            </div>
          </Tooltip>
          <div className="d-flex flex-row align-items-center justify-content-between">
            <P2 className="text-black">{raceInvitesCount || 0}</P2>
          </div>
        </div>
      </div>
    </div>
  );
};

const RaceDropdown = ({ allRaces, race, setRace }) => {
  const raceName = (race) => {
    if (!race) {
      return "No current race is active";
    }
    const raceStart = dayjs(race.started_at).utc();
    const raceEnd = dayjs(race.ends_at).utc();
    const currentTime = dayjs().utc();

    if (
      (raceStart <= currentTime && raceEnd > currentTime) ||
      allRaces.length == 1
    ) {
      return "Current Race";
    } else {
      return `Race ${raceStart.format("MMMM D")} - ${raceEnd.format("MMMM D")}`;
    }
  };

  // @TODO: Add other options & load a different race
  const options = allRaces.map((r) => ({
    name: raceName(r),
    value: r.id,
  }));

  const selectedClass = (selectedRace) =>
    selectedRace.id == race.id ? " text-primary" : "text-black";

  return (
    <Dropdown>
      <Dropdown.Toggle
        className="talent-button white-subtle-button normal-size-button no-caret d-flex justify-content-between align-items-center"
        id="referral-race-dropdown"
        bsPrefix=""
        as="div"
        style={{ height: 34, width: 225 }}
      >
        <P2
          bold
          text={raceName(race)}
          className="mr-2 align-middle text-black"
        />
        <OrderBy black />
      </Dropdown.Toggle>

      <Dropdown.Menu>
        {allRaces.map((race) => (
          <Dropdown.Item
            key={`tab-dropdown-${raceName(race)}`}
            className="d-flex flex-row justify-content-between"
            onClick={() => setRace(race)}
          >
            <P3 bold text={raceName(race)} className={selectedClass(race)} />
          </Dropdown.Item>
        ))}
      </Dropdown.Menu>
    </Dropdown>
  );
};

const RaceTable = ({ leaderboardResults, allRaces, currentRace }) => {
  const [selectedRace, setSelectedRace] = useState(currentRace);
  const [topInviters, setTopInviters] = useState([...leaderboardResults.top5]);
  const [loadingResults, setLoadingResults] = useState(true);

  useEffect(() => {
    if (selectedRace.id == currentRace.id) {
      let topUsers = [...leaderboardResults.top5];
      if (leaderboardResults.userStats?.position > 5) {
        topUsers = [...topUsers, leaderboardResults.userStats];
      }
      setTopInviters(topUsers);
      setLoadingResults(false);
      return;
    }

    setLoadingResults(true);
    get(`/api/v1/races/${selectedRace.id}`).then((response) => {
      let topUsers = [...response.top5];
      if (response.userStats?.position > 5) {
        topUsers = [...topUsers, response.userStats];
      }
      setTopInviters(topUsers);
      setLoadingResults(false);
      return;
    });
  }, [selectedRace]);

  const getRewardsForPosition = (position) => {
    if (position === 1) {
      return "500 $TAL";
    } else if (position === 2) {
      return "300 $TAL";
    } else if (position === 3) {
      return "200 $TAL";
    } else {
      return "0 $TAL";
    }
  };

  const getPositionCircle = (position) => {
    if (position <= 3) {
      return (
        <div
          style={{ width: 24, height: 24 }}
          className="bg-primary rounded-circle mr-4 text-center"
        >
          <P2 className="permanent-text-white" bold>
            {position}
          </P2>
        </div>
      );
    } else if (position <= 5) {
      return (
        <div
          style={{ width: 24, height: 24 }}
          className="bg-surface-hover text-primary-03 rounded-circle mr-4 text-center"
        >
          <P2 bold>{position}</P2>
        </div>
      );
    } else {
      return (
        <div
          style={{ width: 24, height: 24 }}
          className="text-primary-03 text-center mr-4"
        >
          <P2>{position}</P2>
        </div>
      );
    }
  };

  return (
    <>
      <div className="d-flex flex-row justify-content-between align-items-center px-4 px-lg-0 mt-6 mt-lg-7">
        <H4 className="mb-0" bold>
          Leaderboard
        </H4>
        <RaceDropdown
          race={selectedRace}
          setRace={setSelectedRace}
          allRaces={allRaces}
        />
      </div>
      {loadingResults && (
        <div className="w-100 my-6 d-flex flex-row justify-content-center">
          <Spinner />
        </div>
      )}
      {!loadingResults && (
        <Table mode={"dark"} className="px-3 horizontal-scroll mb-5 mt-5">
          <Table.Head>
            <Table.Th className="pl-4 pl-lg-3">
              <Caption bold text={"NAME"} />
            </Table.Th>
            <Table.Th className="pr-4 pr-lg-0">
              <Caption bold text={"INVITES"} />
            </Table.Th>
            <Table.Th className="hide-content-in-mobile text-black">
              <Caption bold text={"PRIZE"} />
            </Table.Th>
          </Table.Head>
          <Table.Body>
            {topInviters.length === 0 && (
              <Table.Tr>
                <td className="w-100 d-flex flex-row justify-content-center py-3">
                  <P2 bold>There are no participants in this race</P2>
                </td>
              </Table.Tr>
            )}
            {topInviters.map((inviter) => (
              <Table.Tr key={`inviter-${inviter.id}`}>
                <td
                  className="w-100 pl-4 pl-lg-3 py-3"
                  onClick={() =>
                    (window.location.href = `/u/${inviter.username}`)
                  }
                >
                  <div className="d-flex align-items-center">
                    {getPositionCircle(inviter.position)}
                    <TalentProfilePicture
                      src={inviter.profilePictureUrl}
                      height="32"
                    />
                    <P2 text={inviter.name} bold className="ml-3" />
                  </div>
                </td>
                <Table.Td
                  className="race-table-invites-cell py-3"
                  onClick={() =>
                    (window.location.href = `/u/${inviter.username}`)
                  }
                >
                  <P2
                    className={`${
                      inviter.position <= 3 ? "text-black" : "text-primary-03"
                    }`}
                    text={inviter.invites}
                  />
                </Table.Td>
                <Table.Td
                  className={
                    "race-table-rewards-cell hide-content-in-mobile py-3"
                  }
                  onClick={() =>
                    (window.location.href = `/u/${talent.user.username}`)
                  }
                >
                  <P2
                    className={`${
                      inviter.position <= 3 ? "text-black" : "text-primary-03"
                    }`}
                    text={getRewardsForPosition(inviter.position)}
                  />
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Body>
        </Table>
      )}
    </>
  );
};

const UserInvitesTable = ({
  invitedUsers,
  loadMoreInvitedUsers,
  showLoadMoreInvitedUsers,
}) => {
  return (
    <>
      <div className="d-flex flex-row justify-content-between align-items-center px-4 px-lg-0 mt-6 mt-lg-7">
        <H4 className="mb-0" bold>
          Users you invited
        </H4>
      </div>
      <Table mode={"dark"} className="px-3 horizontal-scroll mb-5 mt-5">
        <Table.Head>
          <Table.Th className="pl-4 pl-lg-3">
            <Caption bold text={"USER"} />
          </Table.Th>
          <Table.Th className="pr-4 pr-lg-0">
            <Caption bold text={"JOINED"} />
          </Table.Th>
          <Table.Th className="hide-content-in-mobile text-black">
            <Caption bold text={"STATUS"} />
          </Table.Th>
          <Table.Th className="text-black">
            <Tooltip
              body={
                "You earn 100 TAL for each user who launches a Talent Token after being invited by you. Talent Tokens are subject to an application and approval."
              }
              popOverAccessibilityId={"talent_invites_available"}
              placement="top"
            >
              <div className="mb-2 cursor-pointer d-flex align-items-center">
                <Caption bold text={"EARNED"} className="mr-2" />
                <Help color={lightTextPrimary03} />
              </div>
            </Tooltip>
          </Table.Th>
        </Table.Head>
        <Table.Body>
          {invitedUsers.map((user) => (
            <Table.Tr key={`user-${user.id}`}>
              <td
                className="pl-4 pl-lg-3 py-3"
                onClick={() => (window.location.href = `/u/${user.username}`)}
              >
                <div className="d-flex align-items-center">
                  <TalentProfilePicture
                    src={user.profilePictureUrl}
                    height="32"
                  />
                  <P2 text={user.name} bold className="ml-3" />
                  {user.ticker && (
                    <P2 text={user.ticker} bold className="ml-3" />
                  )}
                </div>
              </td>
              <Table.Td
                className="py-3"
                onClick={() => (window.location.href = `/u/${user.username}`)}
              >
                <P2 text={dayjs(user.created_at).format("MMMM D, YYYY")} />
              </Table.Td>
              <Table.Td
                className={"hide-content-in-mobile py-3"}
                onClick={() => (window.location.href = `/u/${user.username}`)}
              >
                <P2 text={user.status} />
              </Table.Td>
              <Table.Td
                className={"py-3"}
                onClick={() => (window.location.href = `/u/${user.username}`)}
              >
                <P2
                  text={user.status == "Token Launched" ? "100 TAL" : "-"}
                  className="mr-2"
                />
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Body>
      </Table>
      {showLoadMoreInvitedUsers && (
        <Button
          onClick={() => loadMoreInvitedUsers()}
          type="white-subtle"
          className="mt-4 mx-auto"
        >
          Load more
        </Button>
      )}
    </>
  );
};

const ReferralRace = ({
  user,
  allRaces,
  race,
  isEligible,
  leaderboardResults,
  invitedUsers,
  loadMoreInvitedUsers,
  showLoadMoreInvitedUsers,
  raceInvitesCount,
}) => {
  return (
    <div className="mt-6 mt-lg-7 d-flex flex-column">
      <RaceHeader isEligible={isEligible} race={race} />
      <Overview
        raceInvitesCount={raceInvitesCount}
        totalInvitesCount={invitedUsers.length}
        username={user.username}
      />
      {race && (
        <RaceTable
          leaderboardResults={leaderboardResults}
          allRaces={allRaces}
          currentRace={race}
        />
      )}
      <UserInvitesTable
        invitedUsers={invitedUsers}
        loadMoreInvitedUsers={loadMoreInvitedUsers}
        showLoadMoreInvitedUsers={showLoadMoreInvitedUsers}
      />
    </div>
  );
};

export default ReferralRace;
