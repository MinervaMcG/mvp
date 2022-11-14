import { ethers } from "ethers";
import { faGlobeEurope } from "@fortawesome/free-solid-svg-icons";
import { faTwitter } from "@fortawesome/free-brands-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import cx from "classnames";
import React, { useState, useContext, useMemo } from "react";

import { ArrowLeft, Help } from "src/components/icons";

import {
  compareName,
  compareOccupation,
  compareSupporters,
  compareMarketCap,
  compareMarketCapVariance,
} from "src/components/talent/utils/talent";

import { destroy, post } from "src/utils/requests";
import { H3, P1, P2 } from "src/components/design_system/typography";
import { lightTextPrimary03 } from "src/utils/colors";
import { parseAndCommify } from "src/onchain/utils";
import { useWindowDimensionsHook } from "src/utils/window";
import Button from "src/components/design_system/button";
import TalentOptions from "src/components/talent/TalentOptions";
import TalentTableCardMode from "src/components/talent/TalentTableCardMode";
import TalentTableListMode from "src/components/talent/TalentTableListMode";
import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";
import Tooltip from "src/components/design_system/tooltip";

const DiscoveryShow = ({ discoveryRow, talents, env }) => {
  const theme = useContext(ThemeContext);
  const { mobile } = useWindowDimensionsHook();
  const [localTalents, setLocalTalents] = useState(talents);
  const [listModeOnly, setListModeOnly] = useState(false);
  const [selectedSort, setSelectedSort] = useState("");
  const [sortDirection, setSortDirection] = useState("asc");
  const partnership = discoveryRow.partnership;
  const partnershipSocialLinks =
    partnership && (partnership.website_url || partnership.twitter_url);

  const showPartnershipButton =
    partnership?.button_name && partnership?.button_url;

  const totalSupplyToString = (totalSupply) => {
    const bignumber = ethers.BigNumber.from(totalSupply).div(10);
    const formattedNumber = ethers.utils.formatUnits(bignumber);
    return parseAndCommify(formattedNumber);
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
  }, [localTalents, selectedSort, sortDirection]);

  return (
    <div className={cx(mobile && "p-4")}>
      <div
        className={cx(
          "talent-list-header d-flex flex-column justify-content-center",
          partnership && "partnership"
        )}
      >
        <a className="button-link mb-5" href="/">
          <Button
            onClick={() => null}
            type="white-ghost"
            size="icon"
            className="d-flex align-items-center justify-content-center"
          >
            <ArrowLeft color="currentColor" size={16} />
          </Button>
        </a>
        {partnership?.banner_url && (
          <div
            className="partnership-banner"
            style={{ backgroundImage: `url(${partnership.banner_url})` }}
          ></div>
        )}
        <div
          className={cx(
            "d-flex flex-column flex-lg-row justify-content-between mb-4 row"
          )}
        >
          <div className="col-lg-8 d-flex flex-column">
            <div className="d-flex">
              {partnership?.logo_url && (
                <img
                  alt="Partnership Picture"
                  className={cx(
                    "image-fit rounded-circle",
                    partnership.banner_url && "partnership-logo"
                  )}
                  height={mobile ? 120 : 173}
                  src={partnership.logo_url}
                  width={mobile ? 120 : 173}
                />
              )}
              <div className={cx(partnership?.logo_url && "ml-5 mt-3")}>
                <div className="d-flex align-items-center">
                  <H3
                    className="mb-0 text-black mr-2"
                    bold
                    text={discoveryRow.title}
                  />

                  {discoveryRow.tags && (
                    <Tooltip
                      body={discoveryRow.tags}
                      popOverAccessibilityId={"discovery_row_tags"}
                      placement="top"
                    >
                      <div className="cursor-pointer d-flex align-items-center">
                        <Help color={lightTextPrimary03} />
                      </div>
                    </Tooltip>
                  )}
                </div>
                {partnershipSocialLinks && (
                  <div className="d-flex flex-row flex-wrap text-primary-03 mt-3">
                    {partnership.website_url && (
                      <a
                        className="hover-primary mr-4 partnership-social-link px-2 py-1 text-reset"
                        href={partnership.website_url}
                        target="self"
                      >
                        <FontAwesomeIcon icon={faGlobeEurope} />
                      </a>
                    )}
                    {partnership.twitter_url && (
                      <a
                        className="hover-primary partnership-social-link px-2 text-reset"
                        href={partnership.twitter_url}
                        target="self"
                      >
                        <FontAwesomeIcon className="mt-2" icon={faTwitter} />
                      </a>
                    )}
                  </div>
                )}
              </div>
            </div>
            <div className="my-4">
              <span className="caption">{`@${discoveryRow.slug.toUpperCase()}`}</span>
              {partnership?.location && (
                <span className="caption ml-4">
                  {partnership.location.toUpperCase()}
                </span>
              )}
            </div>
            {showPartnershipButton && (
              <div className="d-block d-lg-none mb-3">
                <a href={partnership.button_url} target="_blank">
                  <div className="partnership-button primary-default-button">
                    {partnership.button_name}
                  </div>
                </a>
              </div>
            )}
            {discoveryRow.description && (
              <P1 className="text-primary-03" text={discoveryRow.description} />
            )}
          </div>
          <div className={cx("col-lg-4", partnership?.logo_url && "mt-3")}>
            {showPartnershipButton && (
              <div className="d-none d-lg-flex justify-content-lg-end mb-3">
                <a href={partnership.button_url} target="_blank">
                  <div className="partnership-button primary-default-button">
                    {partnership.button_name}
                  </div>
                </a>
              </div>
            )}
            <div className="d-flex flex-column flex-sm-row flex-lg-column discovery-stats">
              <div className="discovery-stat">
                <P1
                  bold
                  className="text-primary-03 d-inline"
                  text={`${discoveryRow.title} Market Cap`}
                />
                <P1
                  bold
                  className="text-black d-inline"
                  text={`$${totalSupplyToString(
                    discoveryRow.talentsTotalSupply
                  )}`}
                />
              </div>
              <div className="discovery-stat">
                <P1
                  bold
                  className="text-primary-03 d-inline"
                  text={`${discoveryRow.title} Talent List`}
                />
                <P1
                  bold
                  className="text-black d-inline"
                  text={discoveryRow.talentsCount}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      <TalentOptions
        headerDescription={`${discoveryRow.title} Talent List`}
        listModeOnly={listModeOnly}
        searchUrl={`/discovery/${discoveryRow.slug}`}
        setListModeOnly={setListModeOnly}
        setLocalTalents={setLocalTalents}
        setSelectedSort={setSelectedSort}
        setSortDirection={setSortDirection}
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
          selectedSort={selectedSort}
          setSelectedSort={setSelectedSort}
          sortDirection={sortDirection}
          setSortDirection={setSortDirection}
          showFirstBoughtField={false}
          updateFollow={updateFollow}
        />
      ) : (
        <TalentTableCardMode
          talents={filteredTalents}
          updateFollow={updateFollow}
          env={env}
        />
      )}
    </div>
  );
};

export default (props, railsContext) => {
  return () => (
    <ThemeContainer {...props}>
      <DiscoveryShow {...props} env={railsContext.contractsEnv} />
    </ThemeContainer>
  );
};
