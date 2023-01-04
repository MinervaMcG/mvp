import React, { useEffect, useState, useContext } from "react";

import { useWindowDimensionsHook } from "src/utils/window";
import { get } from "src/utils/requests";

import { camelCaseObject } from "src/utils/transformObjects";
import { post, destroy } from "src/utils/requests";
import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";

import Button from "src/components/design_system/button";
import { H3, P1, P2 } from "src/components/design_system/typography";
import TalentTableListMode from "./TalentTableListMode";
import TalentTableCardMode from "./TalentTableCardMode";
import TalentOptions from "./TalentOptions";

import { Spinner } from "src/components/icons";

import {
  compareName,
  compareOccupation,
  compareSupporters,
  compareMarketCap,
  compareMarketCapVariance,
} from "src/components/talent/utils/talent";

import cx from "classnames";

const TalentPage = ({ isAdminOrModerator, env }) => {
  const theme = useContext(ThemeContext);
  const { mobile } = useWindowDimensionsHook();
  const url = new URL(document.location);

  const [talents, setTalents] = useState([]);
  const [watchlistOnly, setWatchlistOnly] = useState(
    url.searchParams.get("watchlist_only") == "true" || false
  );
  const [listModeOnly, setListModeOnly] = useState(false);
  const [selectedSort, setSelectedSort] = useState("");
  const [sortDirection, setSortDirection] = useState("asc");
  const [pagination, setPagination] = useState({
    currentPage: 1,
    lastPage: null,
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams(document.location.search);
    params.set("page", 1);
    params.set("watchlist_only", watchlistOnly);
    loadTalents(params);
  }, [watchlistOnly]);

  const changeTab = (tab) => {
    setWatchlistOnly(tab === "Watchlist" ? true : false);
  };

  const updateFollow = async (talent) => {
    const newtalents = talents.map((currTalent) => {
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
        setTalents([...newtalents]);
      }
    } else {
      const response = await post(`/api/v1/follows`, {
        user_id: talent.userId,
      });

      if (response.success) {
        setTalents([...newtalents]);
      }
    }
  };

  useEffect(() => {
    let sortedTalent = [...talents];

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
      sortedTalent.sort(comparisonFunction).reverse();
    } else if (sortDirection === "desc") {
      sortedTalent.sort(comparisonFunction);
    }

    setTalents(sortedTalent);
  }, [selectedSort, sortDirection]);

  const loadTalents = (params) => {
    setLoading(true);
    get(`/api/v1/talent?${params.toString()}`).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
      } else {
        setPagination(response.pagination);
        let responseTalents = response.talents.map((talent) => ({
          ...camelCaseObject(talent),
        }));
        setTalents(responseTalents);

        window.history.replaceState(
          {},
          document.title,
          `${url.pathname}?${params.toString()}`
        );
        setLoading(false);
      }
    });
  };

  const loadMoreTalents = () => {
    setLoading(true);
    const nextPage = pagination.currentPage + 1;

    const params = new URLSearchParams(document.location.search);
    params.set("page", nextPage);

    get(`/api/v1/talent?${params.toString()}`).then((response) => {
      let responseTalents = response.talents.map((talent) => ({
        ...camelCaseObject(talent),
      }));
      const newTalents = [...localTalents, ...responseTalents];
      setTalents(newTalents);
      setPagination(camelCaseObject(response.pagination));

      window.history.replaceState(
        {},
        document.title,
        `${url.pathname}?${params.toString()}`
      );
      setLoading(false);
    });
  };

  const showLoadMoreTalents = pagination.currentPage < pagination.lastPage;

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
        watchlistOnly={watchlistOnly}
        listModeOnly={listModeOnly}
        searchUrl="/api/v1/talent"
        setListModeOnly={setListModeOnly}
        setTalents={setTalents}
        setPagination={setPagination}
        setSelectedSort={setSelectedSort}
        setSortDirection={setSortDirection}
        isAdminOrModerator={isAdminOrModerator}
      />
      {talents.length === 0 && !loading && (
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
          talents={talents}
          updateFollow={updateFollow}
          selectedSort={selectedSort}
          setSelectedSort={setSelectedSort}
          sortDirection={sortDirection}
          setSortDirection={setSortDirection}
          showFirstBoughtField={false}
        />
      ) : (
        <TalentTableCardMode
          talents={talents}
          updateFollow={updateFollow}
          env={env}
        />
      )}
      {loading && (
        <div className="w-100 d-flex flex-row my-2 justify-content-center">
          <Spinner />
        </div>
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
