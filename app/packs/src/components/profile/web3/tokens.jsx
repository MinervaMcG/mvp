import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";

import { P3, H3, P2 } from "src/components/design_system/typography";
import ThemedButton from "src/components/design_system/button";
import { Edit } from "src/components/icons";
import { Polygon, Celo } from "src/components/icons";
import ethLogo from "images/eth-logo.png";
import bitcoinLogo from "images/bitcoin-logo.png";

import { ToastBody } from "src/components/design_system/toasts";
import { useWindowDimensionsHook } from "src/utils/window";

import TokensModal from "./edit/tokensModal";

const Tokens = ({ userId, canUpdate }) => {
  const [tokens, setTokens] = useState([]);
  const [editShow, setEditShow] = useState(false);
  const [chain, setChain] = useState(0);
  const [pagination, setPagination] = useState({});
  const { mobile } = useWindowDimensionsHook();

  useEffect(() => {
    get(`/api/v1/users/${userId}/profile/web3/tokens?visible=${true}`).then(
      (response) => {
        if (response.error) {
          toast.error(<ToastBody heading="Error!" body={response.error} />);
          console.log(response.error);
        } else {
          setPagination(response.pagination);
          setTokens(response.tokens);
        }
      }
    );
  }, [userId]);

  const removeToken = (previousTokens, updatedToken) => {
    const tokenIndex = previousTokens.findIndex(
      (token) => token.id === updatedToken.id
    );

    const newTokens = [
      ...previousTokens.slice(0, tokenIndex),
      ...previousTokens.slice(tokenIndex + 1),
    ];

    return newTokens;
  };

  const appendToken = (updatedToken) => {
    if (updatedToken.show) {
      setTokens((prev) => [updatedToken, ...prev]);
    } else {
      setTokens((previousTokens) => removeToken(previousTokens, updatedToken));
    }
  };

  const loadMoreTokens = () => {
    const nextPage = pagination.currentPage + 1;

    get(
      `/api/v1/users/${userId}/profile/web3/tokens?page=${nextPage}&visible=${true}`
    ).then((response) => {
      setTokens((prev) => [...prev, ...response.tokens]);
      setPagination(response.pagination);
    });
  };

  const showLoadMoreTokens = () => {
    return pagination.currentPage < pagination.lastPage;
  };

  const tokenLogo = (token) => {
    if (token.logo) {
      return <img src={token.logo} className="token-img" />;
    }

    switch (token.chain_id.toString()) {
      case "1":
        return <img src={ethLogo} className="token-img" />;
      case "137":
        return <Polygon width={48} />;
      case "42220":
        return <Celo width={48} />;
      default:
        return <img src={bitcoinLogo} className="token-img" />;
    }
  };

  return (
    <section className="d-flex flex-column align-items-center mt-6">
      <TokensModal
        userId={userId}
        appendToken={appendToken}
        show={editShow && canUpdate}
        setShow={setEditShow}
        mobile={mobile}
        tokenLogo={tokenLogo}
        setChain={setChain}
        chain={chain}
      />
      <div className="container">
        <div className="d-flex w-100 mb-3">
          <H3 className="w-100 text-center mr-3">Tokens</H3>
          {canUpdate && (
            <a onClick={() => setEditShow(true)} className="ml-auto">
              <Edit />
            </a>
          )}
        </div>
        <P2 className="text-center mb-6">A curated list of my main Tokens</P2>
        <div className="row d-flex flex-row justify-content-center mb-3">
          {tokens.map((token) => (
            <div
              className="col-12 col-md-4 mb-4"
              key={`token_list_${token.id}`}
            >
              <div className="web3-card web3-card__full_height">
                <div className="row">
                  <div className="col-3">{tokenLogo(token)}</div>
                  <div className="col-9 d-flex flex-column justify-content-center">
                    <P2 text={token.symbol} bold className="text-primary-01" />
                    <P3 text={token.name} className="text-primary-04" />
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
        {showLoadMoreTokens() && (
          <div className="d-flex flex-column justify-content-center mt-2">
            <ThemedButton
              onClick={() => loadMoreTokens()}
              type="white-subtle"
              className="mx-auto"
            >
              Show More
            </ThemedButton>
          </div>
        )}
      </div>
    </section>
  );
};

export default Tokens;
