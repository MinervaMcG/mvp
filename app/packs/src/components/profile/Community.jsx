import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";

import { get } from "src/utils/requests";
import { ethers } from "ethers";
import { parseAndCommify } from "src/onchain/utils";
import dayjs from "dayjs";
import customParseFormat from "dayjs/plugin/customParseFormat";
dayjs.extend(customParseFormat);
import debounce from "lodash/debounce";

import { H4, H5, P2, P3, Caption } from "src/components/design_system/typography";
import Tag from "src/components/design_system/tag";
import ThemedButton from "src/components/design_system/button";
import { useWindowDimensionsHook } from "src/utils/window";
import { useTheme } from "src/contexts/ThemeContext";
import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import Table from "src/components/design_system/table";
import { darkBg01, lightBg01, lightTextPrimary03, darkTextPrimary03 } from "src/utils/colors.js";
import TextInput from "src/components/design_system/fields/textinput";
import { Search, Star, OrderBy } from "src/components/icons";
import Dropdown from "react-bootstrap/Dropdown";

import cx from "classnames";

const CommunityTable = ({ connections, mode, ticker, mobile }) => {
  const displayableAmount = amount => {
    return `${parseAndCommify(ethers.utils.formatUnits(amount || 0))}`;
  };

  const formattedConnectionType = connection_type => {
    return {
      super_connection: "Super Connection",
      supporter: "Supporter",
      supporting: "Supporting",
      follower: "Follower",
      following: "Following"
    }[connection_type];
  };

  return (
    <Table mode={mode}>
      <Table.Head>
        <Table.Th>
          <Caption bold text="Talent" />
        </Table.Th>
        <Table.Th className={cx(mobile ? "text-right" : "")}>
          <Caption bold text="Connection" />
        </Table.Th>
        <Table.Th className="hide-content-in-mobile">
          <Caption bold text="Connection Strength" />
        </Table.Th>
        <Table.Th className="hide-content-in-mobile">
          <Caption bold text="Since" />
        </Table.Th>
      </Table.Head>
      <Table.Body>
        {connections.map(connection => (
          <Table.Tr key={connection.id} onClick={() => (window.location.href = `/profiles/${connection.username}`)}>
            <Table.Td>
              <div className="d-flex align-items-center">
                <TalentProfilePicture src={connection.profile_picture_url} userId={connection.id} height={24} />
                <P2 text={connection.name} bold className="ml-2" />
                {connection.ticker && (
                  <P2
                    text={`$${connection.ticker}`}
                    className="ml-2 text-uppercase hide-content-in-mobile"
                    style={{
                      color: mode == "dark" ? darkTextPrimary03 : lightTextPrimary03
                    }}
                  />
                )}
              </div>
            </Table.Td>
            <Table.Td>
              <Tag className={cx("connection", `connection__${connection.connection_type}`, mobile ? "ml-auto" : "")}>
                <div className="d-flex align-items-center">
                  {connection.connection_type == "super_connection" && (
                    <Star
                      fill={mode == "dark" ? darkBg01 : lightBg01}
                      color={mode == "dark" ? darkBg01 : lightBg01}
                      className="mr-1"
                    />
                  )}
                  <P2 mode={mode} text={formattedConnectionType(connection.connection_type)} bold role="button" />
                </div>
              </Tag>
            </Table.Td>
            <Table.Td className="hide-content-in-mobile">
              <P2>
                {connection.user_invested_amount > 0 && (
                  <>
                    <span className="bold">{displayableAmount(connection.user_invested_amount)}</span>
                    <span className="ml-1">{`$${connection.ticker}`}</span>
                  </>
                )}
                {connection.user_invested_amount > 0 && connection.connected_user_invested_amount > 0 && (
                  <span className="ml-2 mr-2">+</span>
                )}
                {connection.connected_user_invested_amount > 0 && (
                  <>
                    <span className="bold">{displayableAmount(connection.connected_user_invested_amount)}</span>
                    <span className="ml-1">{`$${ticker}`}</span>
                  </>
                )}
              </P2>
            </Table.Td>
            <Table.Td className="hide-content-in-mobile">
              <P2 text={dayjs(connection.connected_at, "YYYY-MM-DD").format("MMM DD, YYYY")} />
            </Table.Td>
          </Table.Tr>
        ))}
      </Table.Body>
    </Table>
  );
};

const SearchForm = ({ options, changeOptions, connectionType, keyword, mobile }) => {
  const selectedClass = option => (option.name == connectionType.name ? " text-primary" : "text-black");

  return (
    <div className="d-flex justify-content-between my-4">
      <div className="position-relative">
        <TextInput
          value={keyword}
          onChange={e => changeOptions(e, "keyword", e.target.value)}
          placeholder="Search"
          inputClassName={cx("pl-5", mobile ? "w-75" : "w-100")}
          className="w-100"
        />
        <Search color="currentColor" className="position-absolute chat-search-icon" />
      </div>
      <Dropdown>
        <Dropdown.Toggle
          className="talent-button white-subtle-button normal-size-button no-caret d-flex justify-content-between align-items-center"
          id="talent-filters-dropdown"
          bsPrefix=""
          as="div"
          style={{ height: 34, width: 150 }}
        >
          <P2 bold text={connectionType.name} className="mr-2 align-middle text-black text-ellipsis" />
          <OrderBy black />
        </Dropdown.Toggle>

        <Dropdown.Menu>
          {options.map(option => (
            <Dropdown.Item
              key={`tab-dropdown-${option.name}`}
              className="d-flex flex-row justify-content-between"
              onClick={e => changeOptions(e, "connectionType", option)}
            >
              <P3 bold text={option.name} className={selectedClass(option)} />
            </Dropdown.Item>
          ))}
        </Dropdown.Menu>
      </Dropdown>
    </div>
  );
};

const Community = ({ userId, talent, canUpdate }) => {
  const { mobile } = useWindowDimensionsHook();
  const [connections, setConnections] = useState([]);
  const [pagination, setPagination] = useState({});
  const { mode } = useTheme();
  const url = new URL(document.location);

  const options = [
    { name: "All", value: null },
    { name: "Super Connection", value: "super_connection" },
    { name: "Supporter", value: "supporter" },
    { name: "Supporting", value: "supporting" },
    { name: "Follower", value: "follower" },
    { name: "Following", value: "following" }
  ];
  const connectionTypeOption = value => {
    for (let i = 0; i < options.length; i++) {
      if (options[i].value === value) {
        return options[i];
      }
    }
    return null;
  };
  const [connectionType, setConnectionType] = useState(
    connectionTypeOption(url.searchParams.get("connection_type")) || {
      name: "All",
      value: null
    }
  );
  const [keyword, setKeyword] = useState(url.searchParams.get("community_q") || "");

  useEffect(() => {
    const params = new URLSearchParams(document.location.search);

    get(`/api/v1/users/${userId}/profile/community?${params.toString()}`).then(response => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
      } else {
        setPagination(response.pagination);
        setConnections(response.connections);
      }
    });
  }, [userId]);

  const showLoadMoreConnections = () => {
    return pagination.currentPage < pagination.lastPage;
  };

  const loadMoreConnections = () => {
    const nextPage = pagination.currentPage + 1;

    const params = new URLSearchParams(document.location.search);
    params.set("page", nextPage);

    get(`/api/v1/users/${userId}/profile/community?${params.toString()}`).then(response => {
      setConnections(prev => [...prev, ...response.connections]);
      setPagination(response.pagination);
      window.history.replaceState({}, document.title, `${url.pathname}?${params.toString()}`);
    });
  };

  const search = params => {
    get(`/api/v1/users/${userId}/profile/community?${params.toString()}`).then(response => {
      setConnections(response.connections);
      setPagination(response.pagination);
      window.history.replaceState({}, document.title, `${url.pathname}?${params.toString()}`);
    });
  };

  const debouncedSetParamsAndSearch = debounce((field, option) => setParamsAndSearch(field, option), 500);

  const setParamsAndSearch = (field, option) => {
    const params = new URLSearchParams(document.location.search);

    if (field === "connectionType") {
      if (option.name == "All") {
        params.delete("connection_type");
      } else {
        params.set("connection_type", option.value);
      }
      params.set("community_q", keyword);
    }

    if (field === "keyword") {
      if (connectionType.name != "All") {
        params.set("connection_type", connectionType.value);
      }

      params.set("community_q", option);
    }

    params.set("page", 1);
    search(params);
  };

  const changeOptions = (e, field, option) => {
    e.preventDefault();

    if (field === "connectionType") {
      setConnectionType(option);
    }
    if (field === "keyword") {
      setKeyword(option);
    }
    debouncedSetParamsAndSearch(field, option);
  };

  return (
    <section className="d-flex flex-column mx-4">
      <H4 className="text-center mb-3" text="Community" />
      <div className="mb-5 row justify-content-center ">
        <div className="col-6 col-lg-2 d-flex">
          <P2 className={cx("text-primary-01 mr-1", mobile && "ml-5")} bold text={talent.supportersCount || "0"} />
          <P2 className="text-primary-04" text="Supporters" />
        </div>
        <div className="col-6 col-lg-2 d-flex">
          <P2 className="text-primary-01 mr-1" bold text={talent.supportingCount || "0"} />
          <P2 className="text-primary-04" text="Supporting" />
        </div>
        <div className="col-6 col-lg-2 d-flex">
          <P2 className={cx("text-primary-01 mr-1", mobile && "ml-5")} bold text={talent.followersCount || "0"} />
          <P2 className="text-primary-04" text="Followers" />
        </div>
        <div className="col-6 col-lg-2 d-flex">
          <P2 className="text-primary-01 mr-1" bold text={talent.followingCount || "0"} />
          <P2 className="text-primary-04" text="Following" />
        </div>
      </div>
      {talent.connectionsCount > 0 && (
        <>
          <SearchForm
            options={options}
            changeOptions={changeOptions}
            connectionType={connectionType}
            keyword={keyword}
            mobile={mobile}
          />
          <CommunityTable connections={connections} mode={mode()} ticker={talent.talentToken.ticker} mobile={mobile} />
        </>
      )}

      {talent.connectionsCount == 0 && canUpdate && (
        <>
          <H5 bold text={"You don't have any Community members"} className="text-primary-01 text-center mt-7 mb-2" />
          <P2
            bold
            text={
              "Community is compound by people that support your career and people you are supporting. If you support someone that is also your supporter, you get a Super Connection!"
            }
            className="text-primary-03 text-center"
          />
          <div className="d-flex flex-column justify-content-center my-5">
            <ThemedButton onClick={() => (window.location.href = `/talent`)} type="primary-default" className="mx-auto">
              Connect with talent
            </ThemedButton>
          </div>
        </>
      )}
      {showLoadMoreConnections() && (
        <div className="d-flex flex-column justify-content-center mt-6">
          <ThemedButton onClick={() => loadMoreConnections()} type="white-default" className="mx-auto">
            Show More
          </ThemedButton>
        </div>
      )}
    </section>
  );
};

export default Community;
