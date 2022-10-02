import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import currency from "currency.js";
import { OnChain } from "src/onchain";

import MetamaskFox from "images/metamask-fox.svg";
import { Polygon, Celo } from "src/components/icons";
import { chainIdToName } from "src/onchain/utils";

import { H4, P2 } from "src/components/design_system/typography";
import { Copy } from "src/components/icons";
import Button from "src/components/design_system/button";
import Tooltip from "src/components/design_system/tooltip";
import { shortenAddress } from "src/utils/viewHelpers";

import {
  ApolloProvider,
  useQuery,
  GET_TALENT_PORTFOLIO_FOR_ID_SIMPLE,
  client,
} from "src/utils/thegraph";

const SimpleTokenDetails = ({
  token,
  ticker,
  supportingCount,
  supportersCount,
  mode,
  railsContext,
}) => {
  const [listLoaded, setListLoaded] = useState(false);
  const { loading, data } = useQuery(GET_TALENT_PORTFOLIO_FOR_ID_SIMPLE, {
    variables: { id: token?.contract_id?.toLowerCase() },
    skip: listLoaded,
  });

  const [tokenData, setTokenData] = useState({
    price: 0.1,
    totalSupply: 0,
  });

  const chainName = chainIdToName(token?.chain_id, railsContext.contractsEnv);

  useEffect(() => {
    if (loading || !data || !data.talentToken) {
      if (!loading) {
        setListLoaded(true);
      }
      return;
    }

    setListLoaded(true);
    setTokenData({
      ...tokenData,
      totalSupply: ethers.utils.formatUnits(data.talentToken.totalSupply || 0),
    });
  }, [data, loading]);

  const formatNumberWithSymbol = (value) => currency(value).format();

  const formatNumberWithoutSymbol = (value) =>
    currency(value, { symbol: "" }).format();

  const copyTokenAdddres = () =>
    navigator.clipboard.writeText(token.contract_id);

  const addTokenToMetamask = async () => {
    const onChainAPI = new OnChain(railsContext.contractsEnv);

    const chainId = await onChainAPI.getChainID();

    if (chainId != token.chainId) {
      await onChainAPI.switchChain(token.chain_id);
    }

    await onChainAPI.addTokenToWallet(token.contract_id, token.ticker);
  };

  return (
    <>
      {ticker ? (
        <>
          <div className="portfolio-amounts-overview d-flex flex-column align-items-center justify-content-center mb-4 p-3">
            <P2 className="mb-2 text-primary-04" bold text="Market Value" />
            <H4
              bold
              text={formatNumberWithSymbol(tokenData.totalSupply * 0.1)}
            />
          </div>
          <div className="portfolio-amounts-overview d-flex flex-column align-items-center justify-content-center mb-4 p-3">
            <P2
              className="mb-2 text-primary-04"
              bold
              text="Circulating Supply"
            />
            <H4
              bold
              text={`${formatNumberWithoutSymbol(
                tokenData.totalSupply
              )} ${ticker}`}
            />
          </div>
          <div className="portfolio-amounts-overview d-flex flex-column align-items-center justify-content-center mb-4 p-3">
            <P2 className="mb-2 text-primary-04" bold text="Supporters" />
            <H4 bold text={`${supportersCount}`} />
          </div>
          {token?.contract_id && (
            <div className="card card-no-hover d-flex flex-column align-items-center justify-content-center p-3">
              <P2 className="mb-2 text-primary-04" bold text="Contract" />
              <div className="d-flex flex-row justify-content-center align-items-center">
                {chainName == "Polygon" ? <Polygon /> : <Celo />}
                <P2 text={`${chainName}:`} className="ml-2 mr-1" />
                <P2
                  bold
                  className="text-black"
                  text={shortenAddress(token.contract_id)}
                />
                <Tooltip
                  body={"Copied!"}
                  popOverAccessibilityId={"coppy_address_success"}
                  mode={mode}
                  placement="top"
                >
                  <Button
                    type="white-subtle"
                    size="icon"
                    mode={mode}
                    className="ml-2"
                    onClick={copyTokenAdddres}
                  >
                    <Copy color="currentColor" />
                  </Button>
                </Tooltip>
                <Button
                  type="white-subtle"
                  size="icon"
                  mode={mode}
                  className="ml-2"
                  onClick={addTokenToMetamask}
                >
                  <img
                    src={MetamaskFox}
                    width={16}
                    height={16}
                    alt="Metamask Fox"
                  />
                </Button>
              </div>
            </div>
          )}
        </>
      ) : (
        <>
          <div className="portfolio-amounts-overview d-flex flex-column align-items-center justify-content-center mb-4 p-3">
            <P2 className="mb-2 text-primary-04" bold text="Supporting" />
            <H4 bold text={`${supportingCount || 0}`} />
          </div>
        </>
      )}
    </>
  );
};

export default (props) => (
  <ApolloProvider client={client(props.token?.chain_id)}>
    <SimpleTokenDetails {...props} />
  </ApolloProvider>
);
