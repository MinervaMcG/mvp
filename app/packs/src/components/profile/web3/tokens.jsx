import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";

import { Caption } from "src/components/design_system/typography";
import { P3, H3, P2 } from "src/components/design_system/typography";
import { Polygon, Celo } from "src/components/icons";
import ethLogo from "images/eth-logo.png";

import { ToastBody } from "src/components/design_system/toasts";

const Tokens = (userId) => {
  const [tokens, setTokens] = useState([]);

  useEffect(() => {
    get(`/api/v1/users/${userId}/profile/web3/tokens`).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
        console.log(response.error);
      } else {
        setTokens(response);
      }
    });
  }, [userId]);

  const tokenLogo = (token) => {
    if (token.logo) {
      return <img src={token.logo} className="token-img" />;
    }

    switch (token.chain_id.toString()) {
      case "1":
        return <img src={ethLogo} className="token-img" />;
      case "89":
        return <Polygon width={48} />;
      case "44787":
        return <Celo width={48} />;
      default:
        return <Celo width={48} />;
    }
  };

  return (
    <section className="d-flex flex-column align-items-center mt-6">
      <H3>Tokens</H3>
      <P2 className="mb-6">A curated list of my main Tokens</P2>
      {tokens.map((token) => (
        <div key={`token_list_${token.id}`} className="web3-card mb-3">
          <div className="row">
            <div className="col-3">{tokenLogo(token)}</div>
            <div className="col-9">
              <P2 text={token.name} bold className="text-primary-04" />
              <P3 text={token.symbol} className="text-primary-04" />
            </div>
          </div>
        </div>
      ))}
    </section>
  );
};

export default Tokens;
