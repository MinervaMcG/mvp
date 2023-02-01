import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { post, put, get } from "src/utils/requests";
import { P1, P2, P3 } from "src/components/design_system/typography";
import debounce from "lodash/debounce";

import Slider from "src/components/design_system/slider";

import { getPOAPData } from "src/onchain/utils";
import { ToastBody } from "src/components/design_system/toasts";
import ThemedButton from "src/components/design_system/button";
import { Spinner } from "src/components/icons";

import Modal from "react-bootstrap/Modal";
import EmptyStateModal from "./emptyStateModal";

import cx from "classnames";
import imagePlaceholder from "images/image-placeholder.jpeg";

const DisplayPoapsModal = ({ poaps, updatePoap, loading, showLoadMorePoaps, loadMorePoaps, closeModal }) => {
  // Display placeholder until the image fully loads
  const [loadedImagePoaps, setLoadedImagePoaps] = useState({});

  const loadedImage = poap =>
    setLoadedImagePoaps(previousLoadedImages => ({
      ...previousLoadedImages,
      [poap.id]: true
    }));

  return (
    <>
      <Modal.Header className="py-3 px-4 modal-border mb-4" closeButton>
        <Modal.Title>Choose your Poaps</Modal.Title>
      </Modal.Header>
      <Modal.Body className="show-grid pt-0 pb-4 px-4">
        <div className="row d-flex flex-row justify-content-between mb-3">
          {loading && (
            <div className="w-100 d-flex flex-row my-2 justify-content-center">
              <Spinner />
            </div>
          )}
          {poaps.map(poap => (
            <div className="col-12 col-md-6 mb-4" key={poap.id}>
              <div className="card web3-card">
                <div className="mb-3 d-flex align-items-center">
                  <Slider checked={poap.show} onChange={() => updatePoap(poap)} className="d-inline mr-2 mb-0" />
                  <P1 text={"Showcase Poap"} className="text-primary-01 d-inline align-middle" />
                </div>
                <img src={imagePlaceholder} className={cx("nft-img mb-4", loadedImagePoaps[poap.id] ? "d-none" : "")} />
                <img
                  src={poap.imageUrl || poap.external_image_url}
                  onLoad={() => loadedImage(poap)}
                  className={cx("nft-img poap-img mb-4", loadedImagePoaps[poap.id] ? "" : "d-none")}
                />
                <P2 text={poap.name} className="text-primary-04" />
                <P3
                  text={poap.description?.length > 80 ? `${poap.description.substring(0, 80)}...` : poap.description}
                  className="text-primary-01"
                />
              </div>
            </div>
          ))}
        </div>
        {showLoadMorePoaps && (
          <div className="d-flex flex-column align-items-center mt-6 mb-6">
            <ThemedButton onClick={() => loadMorePoaps()} type="white-subtle" className="mx-6 mt-2">
              Show More
            </ThemedButton>
          </div>
        )}
      </Modal.Body>
      <Modal.Footer>
        <ThemedButton onClick={() => closeModal()} type="white-ghost" className="mr-3">
          Cancel
        </ThemedButton>
      </Modal.Footer>
    </>
  );
};

const PoapsModal = ({ userId, show, setShow, mobile, appendPoap }) => {
  const [poaps, setPoaps] = useState([]);
  const [loading, setLoading] = useState(0);
  const [pagination, setPagination] = useState({});

  const loadPoaps = async poaps => {
    for (const poap of poaps) {
      getPOAPData(poap.address, poap.token_id).then(result => {
        if (result?.name && result?.image_url) {
          const newPoap = {
            ...poap,
            imageUrl: result.image_url,
            description: result.description,
            name: result.name
          };
          setPoaps(previousPoaps => [...previousPoaps, newPoap]);
        }
      });
    }
  };

  const setupPoaps = async () => {
    if (!show || poaps.length > 0) {
      return;
    }

    setLoading(true);

    post(`/api/v1/users/${userId}/profile/web3/refresh_poaps`, {
      per_page: 10
    }).then(response => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
      } else {
        setPagination(response.pagination);
        loadPoaps(response.tokens);
      }
    });
  };

  useEffect(() => {
    setupPoaps();
  }, [userId]);

  useEffect(() => {
    if (loading == 0) {
      return;
    }
    // We're using pagination.
    // It might happen that the initial set is not possible to load
    // We keep loading until we have something to show to the user
    if (poaps.length == 0 && moreToLoad()) {
      loadMorePoaps();
    } else {
      setLoading(false);
    }
  }, [poaps]);

  const updatePoaps = (previousPoaps, newPoap) => {
    const poapIndex = previousPoaps.findIndex(poap => poap.id === newPoap.id);

    const newPoaps = [
      ...previousPoaps.slice(0, poapIndex),
      {
        ...previousPoaps[poapIndex],
        ...newPoap
      },
      ...previousPoaps.slice(poapIndex + 1)
    ];

    return newPoaps;
  };

  const debouncedUpdatePoap = debounce(poap => updatePoap(poap), 400);

  const updatePoap = poap => {
    const params = {
      show: !poap.show,
      address: poap.address,
      token_id: poap.token_id,
      chain_id: poap.chain_id,
      external_image_url: poap.imageUrl,
      description: poap.description,
      name: poap.name
    };
    put(`/api/v1/users/${userId}/profile/web3/${poap.id}`, params).then(updatedPoap => {
      if (updatedPoap.error) {
        toast.error(<ToastBody heading="Error!" body={updatedPoap.error} />);
      } else {
        toast.success(<ToastBody heading="Success" body={"POAP updated successfully!"} />, { autoClose: 1500 });
        setPoaps(previousPoaps => updatePoaps(previousPoaps, updatedPoap));
        appendPoap({ ...updatedPoap, external_image_url: poap.imageUrl });
      }
    });
  };

  const mergePoaps = newPoaps => {
    newPoaps.map(poap => {
      // Query blockchain when the local image is not defined
      if (poap.external_image_url) {
        setPoaps(prev => [...prev, poap]);
      } else {
        getPOAPData(poap.address, poap.token_id).then(result => {
          if (result?.name && result?.image_url) {
            const newPoap = {
              ...poap,
              imageUrl: result.image_url,
              description: result.description,
              name: result.name
            };
            setPoaps(prev => [...prev, newPoap]);
          }
        });
      }
    });
  };

  const loadMorePoaps = () => {
    const nextPage = pagination.currentPage + 1;

    get(`/api/v1/users/${userId}/profile/web3/poaps?page=${nextPage}&per_page=10`).then(response => {
      mergePoaps(response.tokens);
      setPagination(response.pagination);
    });
  };

  const showLoadMorePoaps = () => {
    return !loading && moreToLoad();
  };

  const moreToLoad = () => {
    return pagination.currentPage < pagination.lastPage;
  };

  const closeModal = () => {
    setShow(false);
  };

  const getCurrentModal = () => {
    if (poaps.length == 0 && !loading) {
      return EmptyStateModal;
    }

    return DisplayPoapsModal;
  };

  const CurrentModal = getCurrentModal();

  return (
    <Modal
      scrollable={true}
      centered
      show={show}
      onHide={() => setShow(false)}
      dialogClassName={mobile ? "mw-100 mh-100 m-0" : "modal-lg remove-background"}
      fullscreen={"md-down"}
    >
      <CurrentModal
        poaps={poaps}
        loading={loading}
        updatePoap={debouncedUpdatePoap}
        showLoadMorePoaps={showLoadMorePoaps()}
        loadMorePoaps={loadMorePoaps}
        closeModal={setShow}
        emptyStateHeader={"No POAPs"}
        emptyStateClickAction={closeModal}
        emptyStateActionTitle={"Back to Profile"}
        emptyStateMessage={"Oh no! It seems you don't have any poaps to showcase."}
      />
    </Modal>
  );
};

export default PoapsModal;
