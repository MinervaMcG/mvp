import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";
import { P1, P3, H3, H5, P2 } from "src/components/design_system/typography";
import ThemedButton from "src/components/design_system/button";
import { getPOAPData } from "src/onchain/utils";
import { ToastBody } from "src/components/design_system/toasts";
import { useWindowDimensionsHook } from "src/utils/window";

import cx from "classnames";
import imagePlaceholder from "images/image-placeholder.jpeg";

import Web3ModalConnect from "src/components/login/Web3ModalConnect";
import PoapsModal from "./edit/poapsModal";

const Poaps = ({ user, canUpdate, setShowLastDivider, onWalletConnect, railsContext }) => {
  const [poaps, setPoaps] = useState([]);
  const [editShow, setEditShow] = useState(false);
  const [pagination, setPagination] = useState({});
  const { mobile } = useWindowDimensionsHook();
  // Display placeholder until the image fully loads
  const [loadedImagePoaps, setLoadedImagePoaps] = useState({});
  const userId = user.id;
  const walletConnected = user.walletId;

  const loadedImage = poap =>
    setLoadedImagePoaps(previousLoadedImages => ({
      ...previousLoadedImages,
      [poap.id]: true
    }));

  useEffect(() => {
    if (!walletConnected) {
      return;
    }
    get(`/api/v1/users/${userId}/profile/web3/poaps?visible=${true}`).then(response => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
      } else {
        setPagination(response.pagination);
        mergePoaps(response.tokens);
      }
    });
  }, [userId]);

  useEffect(() => {
    if (poaps.length > 0) {
      setShowLastDivider(true);
    }
  }, [poaps]);

  const mergePoaps = newPoaps => {
    newPoaps.map(poap => {
      // Query blockchain when the local image is not defined
      if (poap.image_url) {
        setPoaps(prev => [...prev, poap]);
      } else {
        getPOAPData(poap.address, poap.token_id).then(result => {
          if (result?.name && result?.image_url) {
            const newPoap = {
              ...poap,
              image_url: result.image_url
            };
            setPoaps(prev => [...prev, newPoap]);
          }
        });
      }
    });
  };

  const removePoap = (previousPoaps, updatedPoap) => {
    const poapIndex = previousPoaps.findIndex(poap => poap.id === updatedPoap.id);

    const newPoaps = [...previousPoaps.slice(0, poapIndex), ...previousPoaps.slice(poapIndex + 1)];

    return newPoaps;
  };

  const appendPoap = updatedPoap => {
    if (updatedPoap.show) {
      setPoaps(prev => [updatedPoap, ...prev]);
    } else {
      setPoaps(previousPoaps => removePoap(previousPoaps, updatedPoap));
    }
  };

  const loadMorePoaps = () => {
    const nextPage = pagination.currentPage + 1;

    get(`/api/v1/users/${userId}/profile/web3/poaps?page=${nextPage}&visible=${true}`).then(response => {
      mergePoaps(response.tokens);
      setPagination(response.pagination);
    });
  };

  const showLoadMorePoaps = () => {
    return pagination.currentPage < pagination.lastPage;
  };

  if (poaps.length == 0 && !canUpdate) {
    return <></>;
  }

  return (
    <section className="d-flex flex-column align-items-center mb-7">
      {editShow && walletConnected && (
        <PoapsModal
          userId={userId}
          appendPoap={appendPoap}
          show={editShow && canUpdate}
          setShow={setEditShow}
          mobile={mobile}
        />
      )}
      <div className="container">
        <div className={cx("d-flex w-100 mb-3 position-relative", mobile && "flex-column")}>
          <H3 className="w-100 text-center mb-0">POAPs</H3>
          {canUpdate && walletConnected && (
            <ThemedButton
              type="primary-default"
              size="big"
              text="Edit POAPs"
              onClick={() => setEditShow(true)}
              className={cx(mobile ? "mx-auto mt-3" : "ml-auto position-absolute")}
              style={{ width: "190px", right: 0 }}
            />
          )}
        </div>
        <P1 className="text-center pb-3 mb-4">A curated list of my main Poaps</P1>
        {(poaps.length == 0 || !walletConnected) && canUpdate && (
          <>
            <H5 bold text={"You don't have any POAPs to showcase"} className="text-primary-01 text-center mb-2 mt-7" />
            <P2
              text={
                "This section will be disable until you connect your wallet and enable the POAPs you want to showcase to your community."
              }
              className="text-primary-03 text-center"
            />
            <div className="d-flex flex-column justify-content-center my-5">
              {walletConnected ? (
                <ThemedButton onClick={() => setEditShow(true)} type="primary-default" className="mx-auto">
                  Choose your Poaps
                </ThemedButton>
              ) : (
                <Web3ModalConnect
                  user_id={userId}
                  onConnect={onWalletConnect}
                  railsContext={railsContext}
                  buttonClassName="primary-default-button mx-auto"
                />
              )}
            </div>
          </>
        )}
        <div className="row d-flex flex-row justify-content-center mb-3">
          {walletConnected &&
            poaps.map(poap => (
              <div className="col-12 col-md-4 mb-4" key={poap.id}>
                <div className="card web3-card">
                  <div className="mb-3 d-flex flex-column justify-content-between">
                    <img
                      src={imagePlaceholder}
                      className={cx("nft-img mb-4", loadedImagePoaps[poap.id] ? "d-none" : "")}
                    />
                    <img
                      src={poap.imageUrl || poap.image_url}
                      onLoad={() => loadedImage(poap)}
                      className={cx("nft-img mb-4", loadedImagePoaps[poap.id] ? "" : "d-none")}
                    />
                    <P2 text={poap.name} className="text-primary-04" />
                    <P3
                      text={
                        poap.description?.length > 200 ? `${poap.description.substring(0, 200)}...` : poap.description
                      }
                      className="text-primary-01"
                    />
                  </div>
                </div>
              </div>
            ))}
        </div>
        {showLoadMorePoaps() && (
          <div className="d-flex flex-column justify-content-center mt-2">
            <ThemedButton onClick={() => loadMorePoaps()} type="white-subtle" className="mx-auto">
              Show More
            </ThemedButton>
          </div>
        )}
      </div>
    </section>
  );
};

export default Poaps;
