import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { post, put, get } from "src/utils/requests";
import { P1, P2, P3 } from "src/components/design_system/typography";

import Slider from "src/components/design_system/slider";

import { getNftData } from "src/onchain/utils";
import { ToastBody } from "src/components/design_system/toasts";
import ThemedButton from "src/components/design_system/button";

import { Spinner } from "src/components/icons";

import Modal from "react-bootstrap/Modal";
import PickNetworkModal from "./pickNetworkModal";
import EmptyStateModal from "./emptyStateModal";

const DisplayNftsModal = ({
  nfts,
  updateNft,
  loading,
  showLoadMoreNfts,
  loadMoreNfts,
  back,
  closeModal,
}) => (
  <>
    <Modal.Header className="py-3 px-4 modal-border mb-4" closeButton>
      <Modal.Title>Choose your NFTs</Modal.Title>
    </Modal.Header>
    <Modal.Body className="show-grid pt-0 pb-4 px-4">
      <div className="row d-flex flex-row justify-content-between mb-3">
        {loading && (
          <div className="w-100 d-flex flex-row my-2 justify-content-center">
            <Spinner />
          </div>
        )}
        {nfts.map((nft) => (
          <div className="col-12 col-md-6 mb-4">
            <div className="web3-card">
              <div className="mb-3 d-flex align-items-center">
                <Slider
                  checked={nft.show}
                  onChange={() => updateNft(nft)}
                  className="d-inline mr-2 mb-0"
                />
                <P1
                  text={"Showcase Nft"}
                  className="text-primary-01 d-inline align-middle"
                />
              </div>
              <img src={nft.imageUrl} className="nft-img mb-4" />
              <P2 text={nft.name} className="text-primary-04" />
              <P3
                text={
                  nft.description?.length > 80
                    ? `${nft.description.substring(0, 80)}...`
                    : nft.description
                }
                className="text-primary-01"
              />
            </div>
          </div>
        ))}
      </div>
      {showLoadMoreNfts && (
        <div className="d-flex flex-column align-items-center mt-6 mb-6">
          <ThemedButton
            onClick={() => loadMoreNfts()}
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

const NftsModal = ({
  userId,
  show,
  setShow,
  mobile,
  chain,
  setChain,
  appendNft,
}) => {
  const [nfts, setNfts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({});

  useEffect(() => {
    if (!chain || nfts.length > 0) {
      return;
    }

    setLoading(true);

    post(`/api/v1/users/${userId}/profile/web3/refresh_nfts`, {
      per_page: 10,
      chain_id: chain,
    }).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
        console.log(response.error);
      } else {
        setPagination(response.pagination);

        response.tokens.map((nft) => {
          getNftData(nft).then((result) => {
            if (result?.name && result?.image && result?.imageType == "image") {
              const newNft = {
                ...nft,
                imageUrl: result.image,
                description: result.description,
                name: result.name,
              };
              setNfts((prev) => [...prev, newNft]);
            }
          });
        });
      }
    });
  }, [userId, chain]);

  useEffect(() => {
    setLoading(false);
  }, [nfts]);

  const updateNfts = (previousNfts, newNft) => {
    const nftIndex = previousNfts.findIndex((nft) => nft.id === newNft.id);

    const newNfts = [
      ...previousNfts.slice(0, nftIndex),
      {
        ...previousNfts[nftIndex],
        ...newNft,
      },
      ...previousNfts.slice(nftIndex + 1),
    ];

    return newNfts;
  };

  const updateNft = (nft) => {
    const params = {
      show: !nft.show,
      address: nft.address,
      token_id: nft.token_id,
      chain_id: nft.chain_id,
      image_url: nft.imageUrl,
      description: nft.description,
      name: nft.name,
    };
    put(`/api/v1/users/${userId}/profile/web3/${nft.id}`, params).then(
      (response) => {
        if (response.error) {
          toast.error(<ToastBody heading="Error!" body={response.error} />);
          console.log(response.error);
        } else {
          toast.success(
            <ToastBody heading="Success" body={"NFT updated successfully!"} />,
            { autoClose: 1500 }
          );
          setNfts((previousNfts) => updateNfts(previousNfts, response));
          appendNft({ ...response, local_image_url: nft.imageUrl });
        }
      }
    );
  };

  const mergeNfts = (newNfts) => {
    newNfts.map((nft) => {
      // Query blockchain when the local image is not defined
      if (nft.local_image_url) {
        setNfts((prev) => [...prev, { ...nft, imageUrl: nft.local_image_url }]);
      } else {
        getNftData(nft).then((result) => {
          if (result?.name && result?.image) {
            console.log(nft);
            const newNft = {
              ...nft,
              imageUrl: result.image,
              description: result.description,
              name: result.name,
            };
            setNfts((prev) => [...prev, newNft]);
          }
        });
      }
    });
  };

  const loadMoreNfts = () => {
    const nextPage = pagination.currentPage + 1;

    get(
      `/api/v1/users/${userId}/profile/web3/nfts?per_page=10&page=${nextPage}&chain_id=${chain}`
    ).then((response) => {
      mergeNfts(response.tokens);
      setPagination(response.pagination);
    });
  };

  const showLoadMoreNfts = () => {
    return !loading && pagination.currentPage < pagination.lastPage;
  };

  const getCurrentModal = () => {
    if ((!!chain && nfts.length > 0) || loading) {
      return DisplayNftsModal;
    } else if (!chain) {
      return PickNetworkModal;
    }

    return EmptyStateModal;
  };

  const CurrentModal = getCurrentModal();

  const closeModal = () => {
    setShow(false);
    setChain(0);
    setNfts([]);
  };

  const back = () => {
    setChain(0);
    setNfts([]);
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
        nfts={nfts}
        chain={chain}
        setChain={setChain}
        mobile={mobile}
        loading={loading}
        updateNft={updateNft}
        showLoadMoreNfts={showLoadMoreNfts()}
        loadMoreNfts={loadMoreNfts}
        back={back}
        closeModal={closeModal}
        emptyStateHeader={"No NFTs"}
        emptyStateClickAction={back}
        emptyStateActionTitle={"Choose another network"}
        emptyStateMessage={
          "Oh no! It seems you don't have any nft to showcase. Please, choose another network."
        }
      />
    </Modal>
  );
};

export default NftsModal;