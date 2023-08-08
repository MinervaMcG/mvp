import React, { useState, useCallback, useEffect } from "react";
import Modal from "react-bootstrap/Modal";

import SendMessageModal from "./SendMessageModal";

import { OnChain } from "src/onchain";
import { parseAndCommify, chainIdToName } from "src/onchain/utils";

import { post, patch } from "src/utils/requests";

import { WalletConnectionError } from "../login/Web3ModalConnect";

import LoadingButton from "src/components/button/LoadingButton";
import { P1, P2 } from "src/components/design_system/typography";
import TextInput from "src/components/design_system/fields/textinput";
import Button from "src/components/design_system/button";
import { useWindowDimensionsHook } from "src/utils/window";
import { darkTextPrimary01, black } from "src/utils/colors";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";
import CurrencySelectionDropdown from "./CurrencySelectionDropdown";

const StakeModal = ({
  show,
  setShow,
  ticker,
  tokenAddress,
  tokenId,
  userId,
  userUsername,
  talentName,
  mode,
  tokenChainId,
  talentIsFromCurrentUser,
  railsContext
}) => {
  const { mobile } = useWindowDimensionsHook();

  const [amount, setAmount] = useState("");
  const [showWalletConnectionError, setShowWalletConnectionError] = useState(false);
  const [availableAmount, setAvailableAmount] = useState("0");
  const [availableAmountTAL, setAvailableAmountTAL] = useState("0");
  const [currentAccount, setCurrentAccount] = useState(null);
  const [maxMinting, setMaxMinting] = useState("0");
  const [chainData, setChainData] = useState(null);
  const [targetToken, setTargetToken] = useState(null);
  const [stage, setStage] = useState(null);
  const [approving, setApproving] = useState(false);
  const [didAllowance, setDidAllowance] = useState(false);
  const [validChain, setValidChain] = useState(true);
  // eslint-disable-next-line no-unused-vars
  const [valueError, setValueError] = useState(false);
  const [showNewMessageModal, setShowNewMessageModal] = useState(false);
  const [chainName, setChainName] = useState("celo");
  const [selectedCurrency, setSelectedCurrency] = useState("TAL");

  const setupOnChain = useCallback(async errorCallback => {
    try {
      const newOnChain = new OnChain(railsContext.contractsEnv);

      newOnChain.connectedAccount();

      const validChain = await newOnChain.recognizedChain();
      const chainId = await newOnChain.getChainID();

      setValidChain(validChain && chainId == tokenChainId);

      if (newOnChain.account) {
        setCurrentAccount(newOnChain.account);
      }

      if (tokenAddress) {
        setTargetToken(tokenAddress);
      }

      setChainData(newOnChain);

      const _availableAmount = await newOnChain.getStableBalance(true);
      setAvailableAmount(_availableAmount);

      const _talBalance = await newOnChain.getTALBalance(null, true);
      setAvailableAmountTAL(_talBalance);

      const chainName = chainIdToName(tokenChainId, railsContext.contractsEnv);
      setChainName(chainName);

      if (tokenAddress) {
        const _tokenAvailability = await newOnChain.getTokenAvailability(tokenAddress, chainId, true);
        setMaxMinting(parseAndCommify(_tokenAvailability));
      }
    } catch (e) {
      console.error(e);
      errorCallback();
    }
  }, []);

  const getWalletBalance = useCallback(async () => {
    if (chainData) {
      const _availableAmount = await chainData.getStableBalance(true);

      setAvailableAmount(_availableAmount);

      const _talBalance = await chainData.getTALBalance(null, true);
      setAvailableAmountTAL(_talBalance);
    }
  }, [currentAccount]);

  useEffect(() => {
    let maxTries = 5;
    const errorCallback = () => {
      setTimeout(() => {
        if (!!maxTries) {
          setupOnChain(errorCallback);
          maxTries--;
        }
        return;
      }, 500);
    };
    setupOnChain(errorCallback);
  }, []);

  useEffect(() => {
    getWalletBalance();
  }, [currentAccount]);

  const onSubmit = async e => {
    e.preventDefault();

    if (!currentAccount) {
      // No current account
      toast.error(
        <ToastBody
          heading="No wallet connected"
          body="You must connect your wallet before you're able to buy tokens."
        />
      );
      return;
    }

    if (parseFloat(amount) > parseFloat(amountOnWallet())) {
      // AMOUNT IS TOO HIGH
      toast.error(
        <ToastBody
          heading="Amount is too high"
          body="Your balance is too low for the amount of tokens you want to buy."
        />
      );
      return;
    }

    setStage("Confirm");

    const result = await chainData.createStake(targetToken, amount).catch(error => {
      console.error(error);
      setStage("Error");
    });

    if (result) {
      const _availableAmount = await chainData.getStableBalance(true);
      setAvailableAmount(_availableAmount);

      const _talBalance = await chainData.getTALBalance(null, true);
      setAvailableAmountTAL(_talBalance);

      const chainId = await chainData.getChainID();

      const _tokenAvailability = await chainData.getTokenAvailability(targetToken, chainId, true);
      setMaxMinting(_tokenAvailability);

      await post(`/api/v1/stakes`, { stake: { amount: amount * 10, token_id: tokenId } }).catch(e => console.log(e));

      setStage("Verified");

      if (!talentIsFromCurrentUser) {
        showSendMessageModal();
      }
    } else {
      setStage("Error");
    }
  };

  const showSendMessageModal = () => {
    setTimeout(() => {
      setShow(false);
      setShowNewMessageModal(true);
    }, 1000);
  };

  const approve = async e => {
    e.preventDefault();
    setApproving(true);

    if (selectedCurrency !== "TAL") {
      const allowedValue = await chainData.getStableAllowance(true);

      if (parseFloat(amount) > parseFloat(allowedValue)) {
        await chainData.approveStable(amount);
      }
    }

    setDidAllowance(true);
    setApproving(false);
  };

  const connectWallet = async e => {
    e.preventDefault();

    if (chainData) {
      const result = await chainData.retrieveAccount();

      if (result) {
        await patch(`/api/v1/users/${userId}`, {
          wallet_id: chainData.account.toLowerCase()
        }).catch(() => null);
        setCurrentAccount(chainData.account);
      }
    } else {
      setShow(false);
      setShowWalletConnectionError(true);
    }
  };

  const changeNetwork = async () => {
    await chainData.switchChain(tokenChainId);
    window.location.reload();
  };

  const step = () => {
    if (currentAccount) {
      if (!validChain) {
        return "Change network";
      }
      return "Stake";
    } else {
      return "Connect";
    }
  };

  const amountOnWallet = () => {
    return selectedCurrency === "TAL" ? availableAmountTAL : availableAmount;
  };

  const setValidAmount = value => {
    if (parseFloat(value) < 0 || parseFloat(value) > parseFloat(amountOnWallet())) {
      setValueError(true);
    } else {
      setValueError(false);
    }

    if (didAllowance) {
      setDidAllowance(false);
    }

    setAmount(value);
  };

  const stableSymbol = () => {
    if (selectedCurrency === "TAL") {
      return "TAL";
    }
    if (chainName == "Celo") {
      return "cUSD";
    } else {
      return "USDC";
    }
  };

  return (
    <>
      <WalletConnectionError show={showWalletConnectionError} hide={() => setShowWalletConnectionError(false)} />
      <SendMessageModal
        show={showNewMessageModal}
        setShow={setShowNewMessageModal}
        ticker={ticker}
        talentName={talentName}
        userUsername={userUsername}
        amountBought={amount * 10}
        mode={mode}
      />
      <Modal
        scrollable={true}
        show={show}
        centered={mobile ? false : true}
        onHide={() => setShow(false)}
        dialogClassName={mobile ? "mw-100 mh-100 m-0" : "remove-background rewards-modal"}
        fullscreen={"md-down"}
      >
        <>
          <Modal.Header closeButton className="pt-4 px-4 pb-0">
            <P1
              text={`BUY ${ticker} ${railsContext.disableSmartContracts == "true" ? "(currently unavailable)" : ""}`}
              bold
              className="text-black mb-3"
            />
          </Modal.Header>
          <Modal.Body className="show-grid p-4">
            <div className="container-fluid">
              <div className="row d-flex flex-column">
                {railsContext.disableSmartContracts == "true" ? (
                  <P2
                    className="my-2"
                    text="For security reasons buying talent tokens is currently disabled, we're working
                  to solve this and apologize for any inconvenience."
                  />
                ) : (
                  <>
                    <P2>Please insert the amount and the currency you wish to use to buy Talent Tokens.</P2>
                    <P2 className="my-2">
                      Check the{" "}
                      <a
                        target="self"
                        href="https://talentprotocol.notion.site/Top-Up-Your-Account-b4c96000187442daa126cb843e87ab1d"
                      >
                        guide
                      </a>{" "}
                      if you need help to top up your account.
                    </P2>
                  </>
                )}
                <div className="d-flex flex-column">
                  <div className="form-group position-relative m-0">
                    <P2 bold style={{ marginBottom: 10, marginTop: 40 }}>
                      Currency
                    </P2>
                    <CurrencySelectionDropdown
                      mode={mode}
                      chain={chainName}
                      selectedCurrency={selectedCurrency}
                      setSelectedCurrency={setSelectedCurrency}
                    />
                    <TextInput
                      title={"Total Amount"}
                      mode={mode}
                      type={"number"}
                      disabled={railsContext.disableSmartContracts == "true"}
                      topCaption={
                        currentAccount ? `Available amount: ${parseAndCommify(amountOnWallet())} ${stableSymbol()}` : ""
                      }
                      placeholder={"0.0"}
                      onChange={e => setValidAmount(e.target.value)}
                      value={amount}
                    />
                    <div className={`divider ${mode} my-3`}></div>
                    <div className="d-flex flex-row justify-content-between w-100">
                      <P2>{ticker} tokens still available</P2>
                      <P2>
                        <>{maxMinting}</>
                      </P2>
                    </div>
                    <div className="d-flex flex-row justify-content-between w-100 mt-2">
                      <P2>{ticker} Price</P2>
                      <P2>$0.1</P2>
                    </div>
                    <div className={`divider ${mode} my-3`}></div>
                    <div className="d-flex flex-row justify-content-between w-100">
                      <P1 bold className="text-black">
                        You will receive
                      </P1>
                      <P1 bold className="text-black">
                        {amount * 10} {ticker}
                      </P1>
                    </div>
                    <div className={`divider ${mode} mt-3`}></div>
                    <div className="d-flex flex-row justify-content-between align-items-center mt-6">
                      {step() == "Connect" && (
                        <Button className="w-100" type="primary-default" size="big" onClick={connectWallet}>
                          Connect Wallet
                        </Button>
                      )}
                      {step() == "Change network" && (
                        <Button className="w-100" type="primary-default" size="big" onClick={changeNetwork}>
                          Switch Network
                        </Button>
                      )}
                      {step() == "Stake" && (
                        <>
                          <LoadingButton
                            onClick={approve}
                            type={"primary-default"}
                            mode={mode}
                            className="w-100 mr-2"
                            loading={approving}
                            disabled={approving || didAllowance || railsContext.disableSmartContracts == "true"}
                            success={didAllowance}
                            fillPrimary={darkTextPrimary01}
                            fillSecondary={black}
                            opacity={"1"}
                          >
                            Approve
                          </LoadingButton>
                          <LoadingButton
                            onClick={onSubmit}
                            type={"primary-default"}
                            mode={mode}
                            className="w-100 ml-2"
                            disabled={
                              !didAllowance || stage == "Confirm" || railsContext.disableSmartContracts == "true"
                            }
                            loading={stage == "Confirm"}
                            success={stage == "Verified"}
                            fillPrimary={darkTextPrimary01}
                            fillSecondary={black}
                            opacity={"1"}
                          >
                            Buy
                          </LoadingButton>
                        </>
                      )}
                    </div>

                    {stage == "Error" && (
                      <P2 className="text-danger">
                        There was an issue with the transaction. Check your metamask and reach out to us if the error
                        persists.
                      </P2>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </Modal.Body>
        </>
      </Modal>
    </>
  );
};

export default StakeModal;
