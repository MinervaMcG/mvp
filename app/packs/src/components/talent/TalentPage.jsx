import React, { useEffect, useState, useContext, useMemo } from "react";

import { useWindowDimensionsHook } from "src/utils/window";
import { get } from "src/utils/requests";

import { getMarketCap, getProgress } from "src/utils/viewHelpers";
import { camelCaseObject } from "src/utils/transformObjects";
import { post, destroy } from "src/utils/requests";
import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";

import Button from "src/components/design_system/button";
import { H3, P1, P2 } from "src/components/design_system/typography";
import TalentTableListMode from "./TalentTableListMode";
import TalentTableCardMode from "./TalentTableCardMode";
import TalentOptions from "./TalentOptions";

import {
  compareName,
  compareOccupation,
  compareSupporters,
  compareMarketCap,
  compareMarketCapVariance,
} from "src/components/talent/utils/talent";

import cx from "classnames";

const TalentPage = ({ talents, pagination, isAdmin, env }) => {
  const theme = useContext(ThemeContext);
  const { mobile } = useWindowDimensionsHook();
  const url = new URL(document.location);

  const [localTalents, setLocalTalents] = useState(talents);
  const [watchlistOnly, setWatchlistOnly] = useState(false);
  const [listModeOnly, setListModeOnly] = useState(false);
  const [selectedSort, setSelectedSort] = useState("");
  const [sortDirection, setSortDirection] = useState("asc");
  const [localPagination, setLocalPagination] = useState(pagination);

  const changeTab = (tab) => {
    setWatchlistOnly(tab === "Watchlist" ? true : false);
  };

  const updateFollow = async (talent) => {
    const newLocalTalents = localTalents.map((currTalent) => {
      if (currTalent.id === talent.id) {
        return { ...currTalent, isFollowing: !talent.isFollowing };
      } else {
        return { ...currTalent };
      }
    });

    if (talent.isFollowing) {
      const response = await destroy(
        `/api/v1/follows?user_id=${talent.userId}`
      );

      if (response.success) {
        setLocalTalents([...newLocalTalents]);
      }
    } else {
      const response = await post(`/api/v1/follows`, {
        user_id: talent.userId,
      });

      if (response.success) {
        setLocalTalents([...newLocalTalents]);
      }
    }
  };

  const filteredTalents = useMemo(() => {
    let desiredTalent = [...localTalents];
    if (watchlistOnly) {
      desiredTalent = localTalents.filter((talent) => talent.isFollowing);
    }
    let comparisonFunction;

    switch (selectedSort) {
      case "Supporters":
        comparisonFunction = compareSupporters;
        break;
      case "Occupation":
        comparisonFunction = compareOccupation;
        break;
      case "Market Cap":
        comparisonFunction = compareMarketCap;
        break;
      case "Alphabetical Order":
        comparisonFunction = compareName;
        break;
      case "Market Cap Variance":
        comparisonFunction = compareMarketCapVariance;
        break;
    }

    if (sortDirection === "asc") {
      desiredTalent.sort(comparisonFunction).reverse();
    } else if (sortDirection === "desc") {
      desiredTalent.sort(comparisonFunction);
    }

    return desiredTalent;
  }, [localTalents, watchlistOnly, selectedSort, sortDirection]);

  const loadMoreTalents = () => {
    const nextPage = localPagination.currentPage + 1;

    const params = new URLSearchParams(document.location.search);
    params.set("page", nextPage);

    get(`talent?${params.toString()}`).then((response) => {
      let responseTalents = response.talents.map((talent) => ({
        ...camelCaseObject(talent),
      }));
      const newTalents = [...localTalents, ...responseTalents];
      setLocalTalents(newTalents);
      setLocalPagination(response.pagination);

      window.history.replaceState(
        {},
        document.title,
        `${url.pathname}?${params.toString()}`
      );
    });
  };

  const showLoadMoreTalents =
    localPagination.currentPage < localPagination.lastPage;

  useEffect(() => {
    setLocalTalents(addTalentData(talents));
  }, [talents]);

  const addTalentData = (talents) => {
    const newTalents = talents.map((talent) => ({
      ...talent,
      marketCap: getMarketCap(talent.totalSupply),
      progress: getProgress(
        talent.totalSupply || "0",
        talent.maxSupply,
        talent.id
      ),
    }));
    return newTalents;
  };

  return (
    <div className={cx("pb-6", mobile && "p-4")}>
      <div className="mb-5 talent-list-header d-flex flex-column justify-content-center">
        <H3 className="text-black mb-3" bold text="Explore All Talent" />
        <P1
          className="text-primary-03"
          text="Support undiscovered talent and be rewarded as they grow."
        />
      </div>
      <TalentOptions
        changeTab={changeTab}
        listModeOnly={listModeOnly}
        searchUrl="/api/v1/talent"
        setListModeOnly={setListModeOnly}
        setLocalTalents={setLocalTalents}
        setLocalPagination={setLocalPagination}
        setSelectedSort={setSelectedSort}
        setSortDirection={setSortDirection}
        addTalentData={addTalentData}
        isAdmin={isAdmin}
      />
      {localTalents.length === 0 && (
        <div className="d-flex justify-content-center mt-6">
          <P2
            className="text-black"
            bold
            text="We couldn't find any talent based on your search."
          />
        </div>
      )}
      {listModeOnly ? (
        <TalentTableListMode
          theme={theme}
          talents={filteredTalents}
          updateFollow={updateFollow}
          selectedSort={selectedSort}
          setSelectedSort={setSelectedSort}
          sortDirection={sortDirection}
          setSortDirection={setSortDirection}
          showFirstBoughtField={false}
        />
      ) : (
        <TalentTableCardMode
          talents={filteredTalents}
          updateFollow={updateFollow}
          env={env}
        />
      )}
      {showLoadMoreTalents && (
        <Button
          onClick={() => loadMoreTalents()}
          type="white-subtle"
          className="d-flex mt-4 mx-auto"
        >
          Load more
        </Button>
      )}
    </div>
  );
};

export default (props, railsContext) => {
  return () => (
    <ThemeContainer {...props}>
      <TalentPage {...props} env={railsContext.contractsEnv} />
    </ThemeContainer>
  );
};
