import React, { useState, useEffect, useCallback } from "react";
import Modal from "react-bootstrap/Modal";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";
import { patch } from "src/utils/requests";
import { OnChain } from "src/onchain";
import {
  chainIdToName,
  chainNameToId,
  getAllChainOptions,
} from "src/onchain/utils";
import H5 from "src/components/design_system/typography/h5";
import P2 from "src/components/design_system/typography/p2";
import TextInput from "src/components/design_system/fields/textinput";
import Button from "src/components/design_system/button";
import ChainSelectionDropdown from "src/components/design_system/dropdowns/chain_selection_dropdown";
import { Spinner, GreenCheck, Celo, Polygon } from "src/components/icons";

const LaunchToken = ({
  mode,
  ticker,
  changeTicker,
  setSelectedChain,
  error,
}) => {
  const [selectedNetwork, setSelectedNetwork] = useState("Polygon");

  return (
    <>
      <Modal.Header closeButton>
        <Modal.Title className="px-3">Launch your Talent Token</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <div className="d-flex flex-column w-100 px-3 pb-3">
          <P2 mode={mode}>
            All Talent Tokens have a 1,000,000.00 Maximum Supply. Until your
            token reaches the maximum supply it will have a fixed price of 5
            TAL.
          </P2>
          <TextInput
            title={"Ticker Name"}
            mode={mode}
            placeholder={"TAL"}
            shortCaption={"Upcase letters only. 3 to 8 characters"}
            onChange={(e) => changeTicker(e.target.value)}
            value={ticker || ""}
            className="w-100 mt-4"
            maxLength={8}
            required={true}
            error={error?.length || error?.characters || error?.tickerTaken}
          />
          {error?.length && (
            <P2 className="text-danger">
              Your ticker needs to be between 3 and 8 characters.
            </P2>
          )}
          {error?.characters && (
            <P2 className="text-danger">
              Your ticker can only have uppercase characters.
            </P2>
          )}
          {error?.tickerTaken && (
            <P2 className="text-danger">Your ticker is already taken.</P2>
          )}
          <ChainSelectionDropdown
            className="my-3"
            selectedNetwork={selectedNetwork}
            setSelectedNetwork={setSelectedNetwork}
          />
          <div className={`divider ${mode} my-3`}></div>
          <P2>
            Deploying a Talent Token requires you to confirm a transaction and
            pay a small transaction fee. After you launch your token we'll send
            you 2,000 of your own token!
          </P2>
          <Button
            onClick={() => setSelectedChain(selectedNetwork)}
            type="primary-default"
            className="w-100 mt-5"
            mode={mode}
          >
            Create your Talent Token
          </Button>
        </div>
      </Modal.Body>
    </>
  );
};

const WalletNotConnected = ({ mode }) => (
  <>
    <Modal.Header closeButton>
      <Modal.Title className="px-3">Launch your Talent Token</Modal.Title>
    </Modal.Header>
    <Modal.Body>
      <div className="d-flex flex-column w-100 p-3">
        <P2 mode={mode}>
          You need to connect your metamask before you are able to deploy your
          own Talent Token.
        </P2>
      </div>
    </Modal.Body>
  </>
);

const UnrecognizedChain = ({ mode, switchNetwork, env }) => {
  const chainOptions = getAllChainOptions(env);
  return (
    <>
      <Modal.Header closeButton></Modal.Header>
      <Modal.Body>
        <div className="d-flex flex-column justify-content-center align-items-center w-100 px-3 pb-3">
          <H5>Switch Network</H5>
          <P2 className="mb-3 text-center">
            You're currently connected to a network that we do not support.
            Please switch to one of the networks below.
          </P2>
          <div className="d-flex flex-column flex-lg-row">
            {chainOptions.map((option) => (
              <Button
                key={option.id}
                onClick={() => switchNetwork(option.id)}
                mode={mode}
                type="primary-outline"
                className="ml-lg-2 mb-lg-0 mb-2"
              >
                {option.name == "Polygon" ? (
                  <Polygon width={24} />
                ) : (
                  <Celo width={24} />
                )}{" "}
                Switch to {option.name}
              </Button>
            ))}
          </div>
        </div>
      </Modal.Body>
    </>
  );
};

const WrongNetwork = ({
  chainId,
  mode,
  hide,
  switchNetwork,
  selectedChain,
  env,
}) => {
  const chainName = chainIdToName(chainId, env);
  const selectedChainName = chainIdToName(selectedChain, env);
  const areDifferent = chainName != selectedChainName;
  const realDesiredChain = areDifferent ? selectedChainName : chainName;
  const realDesiredChainId = areDifferent ? selectedChain : chainId;

  return (
    <>
      <Modal.Header closeButton></Modal.Header>
      <Modal.Body>
        <div className="d-flex flex-column justify-content-center align-items-center w-100 px-3 pb-3">
          {realDesiredChain == "Polygon" ? (
            <Polygon width={48} />
          ) : (
            <Celo width={48} />
          )}
          <H5 className="mt-4">Switch Network</H5>
          <P2 className="mb-3 text-center">
            To launch your talent token on the {realDesiredChain} network please
            change your current network.
          </P2>
          <div className="d-flex flex-row justify-content-between w-100 align-items-center">
            <Button
              onClick={hide}
              type="white-subtle"
              mode={mode}
              className="w-100 mt-3 mr-2"
            >
              Back
            </Button>
            <Button
              onClick={() => switchNetwork(realDesiredChainId)}
              mode={mode}
              type="primary-default"
              className="w-100 mt-3"
            >
              Switch to {realDesiredChain}
            </Button>
          </div>
        </div>
      </Modal.Body>
    </>
  );
};

const WaitingForConfirmation = () => (
  <>
    <Modal.Header closeButton>
      <Modal.Title className="px-3">Launch your Talent Token</Modal.Title>
    </Modal.Header>
    <Modal.Body>
      <div className="d-flex flex-column justify-content-center align-items-center w-100 p-3">
        <P2 className="mb-3">
          Open your Metamask Wallet and confirm the transaction to deploy your
          Talent Token. After confirmation we need to wait for the transaction
          to be approved on the blockchain.
        </P2>
        <Spinner />
      </div>
    </Modal.Body>
  </>
);

const SuccessConfirmation = ({ mode, hide }) => {
  return (
    <>
      <Modal.Header closeButton>
        <Modal.Title className="px-3">Launch your Talent Token</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <div className="d-flex flex-column justify-content-center align-items-center w-100 p-3">
          <P2 className="w-100 mx-5 mb-5">
            You've successfully deployed your token! You can track your token
            activity in your portfolio.
          </P2>
          <GreenCheck mode={mode} />
          <Button
            onClick={hide}
            type="primary-default"
            mode={mode}
            className="w-100 mt-5"
          >
            Confirm
          </Button>
        </div>
      </Modal.Body>
    </>
  );
};

const LaunchTokenModals = (props) => {
  const {
    mode,
    talentToken,
    user,
    talent,
    railsContext,
    changeSharedState,
    setContractId,
    show,
    setShow,
    ticker,
    changeTicker,
  } = props;

  const profileType = user.profile_type || user.profileType;
  if (profileType !== "approved" && profileType !== "talent") {
    window.location.href = "edit_profile";
    return;
  }

  const [deploying, setDeploying] = useState(false);
  const [success, setSuccess] = useState(false);
  const [validChain, setValidChain] = useState(true);
  const [walletConnected, setWalletConnected] = useState(true);
  const [error, setError] = useState({});
  const [factory, setFactory] = useState(null);
  const [selectedChain, setSelectedChain] = useState("");
  const [currentChain, setCurrentChain] = useState("");

  const switchNetwork = async (networkId) => {
    const newOnChain = new OnChain(railsContext.contractsEnv);

    await newOnChain.switchChain(networkId);

    window.location.reload();
  };

  const createToken = async () => {
    if (factory) {
      setDeploying(true);
      const result = await factory.createTalent(user.username, ticker);
      if (result.error) {
        setError((prev) => ({ ...prev, tickerTaken: true }));
        setDeploying(false);
        return;
      }

      if (result.canceled) {
        setDeploying(false);
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
            },
          }
        );

        if (response) {
          setSuccess(true);
          setDeploying(false);
          setContractId(contractAddress.toLowerCase());
          changeSharedState((prev) => ({
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
      return false;
    }
  };

  const setupOnChain = useCallback(async () => {
    const newOnChain = new OnChain(railsContext.contractsEnv);
    let result;

    result = await newOnChain.connectedAccount();

    if (!result) {
      setWalletConnected(false);
      return;
    }

    const chainId = await newOnChain.getChainID();
    setCurrentChain(chainId);

    const validChain = await newOnChain.recognizedChain();
    setValidChain(validChain);

    result = newOnChain.loadFactory();

    if (result) {
      setFactory(newOnChain);
    } else {
      try {
        // eslint-disable-next-line no-undef
        setDeploy("Unable to deploy token");
      } catch {
    toast.error(
        <ToastBody heading="Error!" body={"Unable to deploy token"} mode={mode}/>,  
        { autoClose: 5000 }
    );
      }
      return;
    }
  }, []);

  useEffect(() => {
    setupOnChain();
  }, []);

  const saveTicker = async () => {
    const response = await patch(
      `/api/v1/talent/${talent.id}/tokens/${talentToken.id}`,
      {
        talent_token: {
          ticker,
          chain_id: currentChain,
        },
      }
    ).catch(() => {
      console.log("error updating ticker");
      setShow(false);
      return;
    });

    if (response) {
      if (!response.error) {
        changeSharedState((prev) => ({
          ...prev,
          talentToken: {
            ...prev.talentToken,
            ticker,
          },
        }));
        return true;
      }

    toast.error(
      <ToastBody heading="Error!" body={response?.error} mode={mode}/>,
      { autoClose: 5000 }
    );
    }

    return false;
  };

  const handleDeploy = async () => {
    const tickerValidator = new RegExp("[^A-Z]+");
    if (tickerValidator.test(ticker)) {
      setError((prev) => ({ ...prev, characters: true }));
      return;
    }

    if (ticker.length < 3 || ticker.length > 8) {
      setError((prev) => ({ ...prev, length: true }));
      return;
    }

    const result = await saveTicker();

    if (result) {
      const deployed = await createToken();

      if (!deployed) {
        setError((prev) => ({ ...prev, deploy: true, ticker: false }));
      }
    } else {
      setError((prev) => ({ ...prev, ticker: true }));
    }
  };

  const onClose = () => setShow(false);

  const getCurrentModal = () => {
    if (deploying) {
      return WaitingForConfirmation;
    }

    if (success) {
      return SuccessConfirmation;
    }

    if (!walletConnected) {
      return WalletNotConnected;
    }

    if (!validChain) {
      return UnrecognizedChain;
    }

    if (selectedChain !== "" && selectedChain !== currentChain) {
      return WrongNetwork;
    }

    return LaunchToken;
  };

  const CurrentModal = getCurrentModal();

  const deployOrChangeNetwork = (network) => {
    if (chainNameToId(network, railsContext.contractsEnv) == currentChain) {
      handleDeploy();
    } else {
      setSelectedChain(chainNameToId(network, railsContext.contractsEnv));
    }
  };

  return (
    <>
      <Modal
        scrollable={true}
        fullscreen={"md-down"}
        show={show}
        centered
        onHide={onClose}
        dialogClassName="remove-background"
      >
        <CurrentModal
          mode={mode}
          ticker={ticker}
          changeTicker={changeTicker}
          deployToken={handleDeploy}
          hide={onClose}
          error={error}
          backdrop={false}
          setShow={setShow}
          chainId={currentChain}
          selectedChain={selectedChain}
          setSelectedChain={deployOrChangeNetwork}
          switchNetwork={switchNetwork}
          env={railsContext.contractsEnv}
        />
      </Modal>
    </>
  );
};

export default LaunchTokenModals;
