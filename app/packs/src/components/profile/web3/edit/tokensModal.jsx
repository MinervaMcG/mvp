import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { post, put, get } from "src/utils/requests";
import { P1, P2, P3 } from "src/components/design_system/typography";
import debounce from "lodash/debounce";

import Slider from "src/components/design_system/slider";

import { ToastBody } from "src/components/design_system/toasts";
import ThemedButton from "src/components/design_system/button";

import { Spinner } from "src/components/icons";

import Modal from "react-bootstrap/Modal";
import PickNetworkModal from "./pickNetworkModal";
import EmptyStateModal from "./emptyStateModal";

const DisplayTokensModal = ({
  tokens,
  updateToken,
  loading,
  showLoadMoreTokens,
  loadMoreTokens,
  tokenLogo,
  back,
  closeModal,
}) => (
  <>
    <Modal.Header className="py-3 px-4 modal-border mb-4" closeButton>
      <Modal.Title>Choose your Tokens</Modal.Title>
    </Modal.Header>
    <Modal.Body className="show-grid pt-0 pb-4 px-4">
      <div className="row d-flex flex-row justify-content-between mb-3">
        {loading && (
          <div className="w-100 d-flex flex-row my-2 justify-content-center">
            <Spinner />
          </div>
        )}
        {tokens.map((token) => (
          <div className="col-12 col-md-6 mb-4" key={token.id}>
            <div className="card web3-card web3-card__full_height">
              <div className="mb-4 d-flex align-items-center">
                <Slider
                  checked={token.show}
                  onChange={() => updateToken(token)}
                  className="d-inline mr-2 mb-0"
                />
                <P1
                  text={"Showcase Token"}
                  className="text-primary-01 d-inline align-middle"
                />
              </div>
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
      {showLoadMoreTokens && (
        <div className="d-flex flex-column align-items-center mt-6 mb-6">
          <ThemedButton
            onClick={() => loadMoreTokens()}
            type="white-subtle"
            className="mx-6 mt-2"
          >
            Show More
          </ThemedButton>
        </div>
      )}
    </Modal.Body>
    <Modal.Footer>
      <ThemedButton
        onClick={() => back()}
        type="primary-outline"
        className="mr-auto"
      >
        Back
      </ThemedButton>
      <a onClick={() => closeModal()} className="mr-3">
        Cancel
      </a>
      <ThemedButton
        onClick={() => closeModal()}
        type="primary-default"
        className="ml-2"
      >
        Save
      </ThemedButton>
    </Modal.Footer>
  </>
);

const TokensModal = ({
  userId,
  show,
  setShow,
  mobile,
  chain,
  setChain,
  appendToken,
  tokenLogo,
}) => {
  const [tokens, setTokens] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({});

  useEffect(() => {
    if (!chain || tokens.length > 0) {
      return;
    }

    setLoading(true);

    post(`/api/v1/users/${userId}/profile/web3/refresh_tokens`, {
      per_page: 10,
      chain_id: chain,
    }).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
        console.log(response.error);
      } else {
        setPagination(response.pagination);
        setTokens(response.tokens);
      }
    });
  }, [userId, chain]);

  useEffect(() => {
    setLoading(false);
  }, [tokens]);

  const updateTokens = (previousTokens, newToken) => {
    const tokenIndex = previousTokens.findIndex(
      (token) => token.id === newToken.id
    );

    const newTokens = [
      ...previousTokens.slice(0, tokenIndex),
      {
        ...previousTokens[tokenIndex],
        ...newToken,
      },
      ...previousTokens.slice(tokenIndex + 1),
    ];

    return newTokens;
  };

  const debouncedUpdateToken = debounce((token) => updateToken(token), 400);

  const updateToken = (token) => {
    const params = {
      show: !token.show,
      address: token.address,
      token_id: token.token_id,
      chain_id: token.chain_id,
    };
    put(`/api/v1/users/${userId}/profile/web3/${token.id}`, params).then(
      (response) => {
        if (response.error) {
          toast.error(<ToastBody heading="Error!" body={response.error} />);
          console.log(response.error);
        } else {
          toast.success(
            <ToastBody
              heading="Success"
              body={"Token updated successfully!"}
            />,
            { autoClose: 1500 }
          );
          setTokens((previousTokens) => updateTokens(previousTokens, response));
          appendToken(response);
        }
      }
    );
  };

  const loadMoreTokens = () => {
    const nextPage = pagination.currentPage + 1;

    get(
      `/api/v1/users/${userId}/profile/web3/tokens?per_page=10&page=${nextPage}&chain_id=${chain}`
    ).then((response) => {
      setTokens((prev) => [...prev, ...response.tokens]);
      setPagination(response.pagination);
    });
  };

  const showLoadMoreTokens = () => {
    return !loading && pagination.currentPage < pagination.lastPage;
  };

  const getCurrentModal = () => {
    if ((!!chain && tokens.length > 0) || loading) {
      return DisplayTokensModal;
    } else if (!chain) {
      return PickNetworkModal;
    }

    return EmptyStateModal;
  };

  const CurrentModal = getCurrentModal();

  const closeModal = () => {
    setShow(false);
    setChain(0);
    setTokens([]);
  };

  const back = () => {
    setChain(0);
    setTokens([]);
  };

  return (
    <Modal
      scrollable={true}
      centered
      show={show}
      onHide={() => closeModal()}
      dialogClassName={
        mobile ? "mw-100 mh-100 m-0" : "modal-lg remove-background"
      }
      fullscreen={"md-down"}
    >
      <CurrentModal
        tokens={tokens}
        chain={chain}
        setChain={setChain}
        mobile={mobile}
        loading={loading}
        updateToken={debouncedUpdateToken}
        showLoadMoreTokens={showLoadMoreTokens()}
        loadMoreTokens={loadMoreTokens}
        tokenLogo={tokenLogo}
        back={back}
        closeModal={closeModal}
        emptyStateHeader={"No tokens"}
        emptyStateClickAction={back}
        emptyStateActionTitle={"Choose another network"}
        emptyStateMessage={
          "Oh no! It seems you don't have any token to showcase. Please, choose another network."
        }
      />
    </Modal>
  );
};

export default TokensModal;
