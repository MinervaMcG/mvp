import React, { useState, useCallback, useEffect } from "react";

import { OnChain } from "src/onchain";
import {
  chainIdToName,
  chainNameToId,
  parseAndCommify,
} from "src/onchain/utils";
import { useWindowDimensionsHook } from "../../utils/window";
import { useTheme } from "src/contexts/ThemeContext";
import { ethers } from "ethers";
import cx from "classnames";
import { H3, P3, P2 } from "src/components/design_system/typography";
import { formatNumberWithSymbol, shortenAddress } from "src/utils/viewHelpers";
import Button from "src/components/design_system/button";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";
import { patch } from "src/utils/requests";

const Token = ({ talent, talentTokenPrice, railsContext, setLocalTalent }) => {
  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();
  const [staking, setStaking] = useState(null);
  const [onChainAPI, setOnChainAPI] = useState(null);
  const [factory, setFactory] = useState(null);

  const talentToken = talent.talentToken;

  const totalSupply = ethers.utils.formatUnits(talent.totalSupply);
  const maxSupply = ethers.utils.formatUnits(talent.maxSupply);

  const oppositeChain =
    chainIdToName(talentToken.chainId, railsContext.contractsEnv) === "Celo"
      ? "Polygon"
      : "Celo";

  const addTokenToMetamask = async () => {
    const chainId = await onChainAPI.getChainID();

    if (chainId != talentToken.chainId) {
      await onChainAPI.switchChain(talentToken.chainId);
    }

    await onChainAPI.addTokenToWallet(
      talentToken.contractId,
      talentToken.ticker
    );
  };

  const migrateNetwork = async () => {
    console.log(talentToken);
    const chainId = await onChainAPI.getChainID();
    if (chainId != talentToken.chainId) {
      await onChainAPI.switchChain(talentToken.chainId);
    }

    const newChainId = chainNameToId(oppositeChain, railsContext.contractsEnv);
    console.log(newChainId);
    const result = await staking.migrateTalentNetwork(
      talentToken.contractId,
      newChainId
    );
    if (result.error || result.canceled) {
      return;
    }

    const response = await patch(
      `/api/v1/talent/${talent.id}/tokens/${talentToken.id}`,
      {
        talent_token: {
          disabled: true,
        },
      }
    );

    if (response) {
      const chainSwitchResult = await onChainAPI.switchChain(newChainId);
      console.log("response", chainSwitchResult);
    }
  };

  const setupOnChain = useCallback(async () => {
    const newOnChain = new OnChain(railsContext.contractsEnv);
    setOnChainAPI(newOnChain);

    let result;
    result = await newOnChain.connectedAccount();
    if (!result) {
      return;
    }

    result = await newOnChain.loadStaking();
    if (result) {
      setStaking(newOnChain);
    }

    result = await newOnChain.loadFactory();
    if (result) {
      setFactory(newOnChain);
    }
  }, []);

  const launchTokenOnNewChain = async () => {
    if (!onChainAPI && !factory) {
      return;
    }
    toast.warning(
      <ToastBody
        heading="Token Disabled!"
        body={`Token has been disabled on ${chainIdToName(
          talentToken.chainId,
          railsContext.contractsEnv
        )} Network. Please proceed with the migration process`}
      />
    );

    const chainId = await onChainAPI.getChainID();
    if (chainId == talentToken.chainId) {
      await onChainAPI.switchChain(talentToken.chainId);
    }

    const result = await factory.createTalent(
      talent.user.username,
      talentToken.ticker,
      true
    );
    if (result.error || result.canceled) {
      toast.error(
        <ToastBody heading="Error!" body={result.error || result.canceled} />
      );
      return;
    }

    if (result) {
      const contractAddress = result.args.token;

      const response = await patch(
        `/api/v1/talent/${talent.id}/tokens/${talentToken.id}`,
        {
          talent_token: {
            contract_id: contractAddress.toLowerCase(),
            deployed: true,
            chain_id: chainId,
            disabled: false,
          },
        }
      );

      if (response) {
        toast.success(
          <ToastBody
            heading="Token Migrated!"
            body="Token has been successfully deployed to the new chain."
          />
        );
        setLocalTalent((prev) => ({
          ...prev,
          totalSupply: response.total_supply,
          talentToken: {
            ...prev.talentToken,
            contract_id: contractAddress.toLowerCase(),
            contractId: contractAddress.toLowerCase(),
            chainId: response.talent_token.chain_id,
            deployed: true,
          },
        }));
        return true;
      }
    }
  };

  useEffect(() => {
    setupOnChain();
  }, []);

  useEffect(() => {
    if (talentToken.disabled) {
      launchTokenOnNewChain();
    }
  }, [factory]);

  return (
    <section
      className={cx(
        "d-flex flex-column mx-4 token-section",
        mobile ? "py-6" : "py-7"
      )}
    >
      <div className="row">
        <div className={cx("col-12 col-lg-4", mobile && "mb-6")}>
          <H3
            text={`$${parseAndCommify(totalSupply * talentTokenPrice)}`}
            className="text-center inverted-text-primary-01"
          ></H3>
          <P3 className="text-center inverted-text-primary-03">Market Cap</P3>
        </div>
        <div className={cx("col-12 col-lg-4", mobile && "mb-6")}>
          <H3
            text={`${parseAndCommify(totalSupply)} $${talentToken.ticker}`}
            className="text-center inverted-text-primary-01"
          ></H3>
          <P3 className="text-center inverted-text-primary-03">
            Circulating Supply
          </P3>
        </div>
        <div className={cx("col-12 col-lg-4", mobile && "mb-6")}>
          <H3
            text={`${ethers.utils.commify(maxSupply)} $${talentToken.ticker}`}
            className="text-center inverted-text-primary-01"
          ></H3>
          <P3 className="text-center inverted-text-primary-03">Max Supply</P3>
        </div>
      </div>
      <div className={cx("row", mobile ? "" : "mt-7")}>
        <div className={cx("col-12 col-lg-4", mobile && "mb-6")}>
          <H3
            text={talent.supportersCount || "0"}
            className="text-center inverted-text-primary-01"
          ></H3>
          <P3 className="text-center inverted-text-primary-03">Supporters</P3>
        </div>
        <div className={cx("col-12 col-lg-4", mobile && "mb-6")}>
          <H3
            text={formatNumberWithSymbol(0.1)}
            className="text-center inverted-text-primary-01"
          ></H3>
          <P3 className="text-center inverted-text-primary-03">
            Current Price
          </P3>
        </div>
        <div className={cx("col-12 col-lg-4", mobile && "mb-6")}>
          <H3
            text={shortenAddress(talentToken.contractId)}
            className="text-center inverted-text-primary-01"
          ></H3>
          <P3
            text={`${chainIdToName(
              talentToken.chainId,
              railsContext.contractsEnv
            )} Network`}
            className="text-center inverted-text-primary-03"
          ></P3>
        </div>
      </div>
      <div className="d-flex flex-column justify-content-center mt-6">
        <Button
          className="mr-2 mt-2 mx-auto inverted-button"
          mode={mode() == "light" ? "dark" : "light"}
          type="white-default"
          onClick={() => addTokenToMetamask()}
        >
          <P2 bold text={`Add $${talentToken.ticker} to Metamask`} />
        </Button>
      </div>
      <div className="d-flex flex-column justify-content-center mt-6">
        <Button
          className="mx-auto inverted-button"
          mode={mode() == "light" ? "dark" : "light"}
          type="white-default"
          onClick={() => migrateNetwork()}
        >
          <P2 bold text={`Migrate to ${oppositeChain} Network`} />
        </Button>
      </div>
    </section>
  );
};

export default Token;
