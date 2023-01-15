import React, { useState, useEffect } from "react";
import { useWindowDimensionsHook } from "src/utils/window";
import { P1, P3 } from "src/components/design_system/typography";
import Link from "src/components/design_system/link";
import { Caret } from "src/components/icons";
import NewTalentCard from "src/components/design_system/cards/NewTalentCard";
import Button from "src/components/design_system/button";
import Tag from "src/components/design_system/tag";
import { displayableAmount } from "src/utils/viewHelpers";

import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";

import { get, post } from "src/utils/requests";

import cx from "classnames";

const DiscoveryRow = ({ discoveryRow, env }) => {
  const { mobile, width } = useWindowDimensionsHook();
  const [talents, setTalents] = useState([]);
  const [pagination, setPagination] = useState({});
  const calculatePerPage = () => {
    if (width < 590) {
      return 1;
    }
    if (width < 900) {
      return 2;
    }

    if (width < 1240) {
      return 3;
    }

    return 4;
  };
  const [perPage, setPerPage] = useState(calculatePerPage());

  useEffect(() => {
    loadTalents(1);
  }, [discoveryRow, perPage]);

  useEffect(() => {
    setPerPage(calculatePerPage());
  }, [width]);

  const loadTalents = (page) => {
    get(
      `/api/v1/talent?discovery_row_id=${discoveryRow.id}&page=${page}&per_page=${perPage}`
    ).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
      } else {
        setPagination(response.pagination);
        setTalents(response.talents);
      }
    });
  };

  const updateFollow = async (talent) => {
    let response;
    if (talent.is_following) {
      response = await destroy(`/api/v1/follows?user_id=${talent.user_id}`);
    } else {
      response = await post(`/api/v1/follows`, {
        user_id: talent.user_id,
      });
    }

    if (response.success) {
      const newLocalTalents = talents.map((currentTalent) => {
        if (currentTalent.id === talent.id) {
          return { ...currentTalent, is_following: !talent.is_following };
        } else {
          return { ...currentTalent };
        }
      });

      setTalents(newLocalTalents);
    } else {
      toast.error(
        <ToastBody heading="Unable to update follow" body={response?.error} />
      );
    }
  };

  const slideLeft = () => {
    const previousPage = pagination.currentPage - 1;
    loadTalents(previousPage);
  };
  const slideRight = () => {
    const nextPage = pagination.currentPage + 1;
    loadTalents(nextPage);
  };
  const disableLeft = () => pagination.currentPage == 1;
  const disableRight = () => pagination.currentPage == pagination.lastPage;
  const displayPaginationButtons = () => pagination.lastPage != 1;

  const discoveryBadge = () => {
    if (!!discoveryRow.badge_link) {
      return (
        <a
          href={discoveryRow.badge_link}
          className="cursor-pointer ml-2"
          target="_blank"
        >
          <Tag className="cursor-pointer secondary">
            <P3 className="current-color" bold text={discoveryRow.badge} />
          </Tag>
        </a>
      );
    } else {
      return (
        <Tag className="ml-2 secondary">
          <P3 className="current-color" bold text={discoveryRow.badge} />
        </Tag>
      );
    }
  };

  return (
    <div className="discovery-row">
      {talents.length > 0 ? (
        <>
          <div className="d-flex justify-content-between">
            <div className="d-flex flex-row">
              <P1
                bold
                text={discoveryRow.title}
                className={cx("text-black", mobile && "pl-4")}
              />
              {!!discoveryRow.badge && discoveryBadge()}
              <Link
                className="mb-2 ml-3 d-flex align-items-center discover-all-link"
                bold
                href={`discovery/${discoveryRow.slug}`}
                text="Discover all"
              >
                <Caret
                  size={12}
                  color="currentColor"
                  className="rotate-270 ml-2"
                />
              </Link>
            </div>
            {displayPaginationButtons() && (
              <div className="d-flex flex-row">
                <Button
                  onClick={() => slideLeft()}
                  disabled={disableLeft()}
                  type="white-ghost"
                  size="icon"
                  className="mr-2"
                >
                  <Caret size={16} color="currentColor" className="rotate-90" />
                </Button>
                <Button
                  onClick={() => slideRight()}
                  disabled={disableRight()}
                  type="white-ghost"
                  size="icon"
                >
                  <Caret
                    size={16}
                    color="currentColor"
                    className="rotate-270"
                  />
                </Button>
              </div>
            )}
          </div>
          <div
            className={cx(
              "w-100 d-flex hide-scrollbar talents-cards-container justify-content-around pb-6",
              mobile && "pl-4"
            )}
          >
            {talents.map((talent) => (
              <div
                key={talent.id}
                className={cx("pt-3 pr-4", perPage == 1 && "mx-auto")}
              >
                <NewTalentCard
                  name={talent.user.name}
                  ticker={talent.talent_token.ticker}
                  contractId={talent.talent_token.contract_id}
                  occupation={talent.occupation}
                  profilePictureUrl={talent.profile_picture_url}
                  headline={talent.headline}
                  isFollowing={talent.is_following}
                  isVerified={talent.verified}
                  updateFollow={() => updateFollow(talent)}
                  talentLink={`/u/${talent.user.username}`}
                  profileType={talent.profile_type}
                  marketCap={displayableAmount(talent.market_cap)}
                  supporterCount={talent.supporters_count?.toString()}
                  chainId={talent.talent_token.chain_id}
                  env={env}
                />
              </div>
            ))}
          </div>
        </>
      ) : (
        <></>
      )}
    </div>
  );
};

export default DiscoveryRow;
