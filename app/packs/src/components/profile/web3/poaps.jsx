import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";
import { P3, H3, P2 } from "src/components/design_system/typography";
import { Edit } from "src/components/icons";
import ThemedButton from "src/components/design_system/button";
import { getPOAPData } from "src/onchain/utils";
import { ToastBody } from "src/components/design_system/toasts";
import { useWindowDimensionsHook } from "src/utils/window";

import PoapsModal from "./edit/poapsModal";

const Poaps = ({ userId, canUpdate }) => {
  const [poaps, setPoaps] = useState([]);
  const [editShow, setEditShow] = useState(false);
  const [pagination, setPagination] = useState({});
  const { mobile } = useWindowDimensionsHook();

  useEffect(() => {
    get(`/api/v1/users/${userId}/profile/web3/poaps?visible=${true}`).then(
      (response) => {
        if (response.error) {
          toast.error(<ToastBody heading="Error!" body={response.error} />);
          console.log(response.error);
        } else {
          setPagination(response.pagination);
          mergePoaps(response.tokens);
        }
      }
    );
  }, [userId]);

  const mergePoaps = (newPoaps) => {
    newPoaps.map((poap) => {
      // Query blockchain when the local image is not defined
      if (poap.local_image_url) {
        setPoaps((prev) => [...prev, poap]);
      } else {
        getPOAPData(poap.address, poap.token_id).then((result) => {
          if (result?.name && result?.image_url) {
            const newPoap = {
              ...poap,
              local_image_url: result.image_url,
            };
            setPoaps((prev) => [...prev, newPoap]);
          }
        });
      }
    });
  };

  const removePoap = (previousPoaps, updatedPoap) => {
    const poapIndex = previousPoaps.findIndex(
      (poap) => poap.id === updatedPoap.id
    );

    const newPoaps = [
      ...previousPoaps.slice(0, poapIndex),
      ...previousPoaps.slice(poapIndex + 1),
    ];

    return newPoaps;
  };

  const appendPoap = (updatedPoap) => {
    if (updatedPoap.show) {
      setPoaps((prev) => [updatedPoap, ...prev]);
    } else {
      setPoaps((previousPoaps) => removePoap(previousPoaps, updatedPoap));
    }
  };

  const loadMorePoaps = () => {
    const nextPage = pagination.currentPage + 1;

    get(
      `/api/v1/users/${userId}/profile/web3/poaps?page=${nextPage}&visible=${true}`
    ).then((response) => {
      mergePoaps(response.tokens);
      setPagination(response.pagination);
    });
  };

  const showLoadMorePoaps = () => {
    return pagination.currentPage < pagination.lastPage;
  };

  return (
    <section className="d-flex flex-column align-items-center mt-6 mb-6">
      <PoapsModal
        userId={userId}
        appendPoap={appendPoap}
        show={editShow && canUpdate}
        setShow={setEditShow}
        mobile={mobile}
      />
      <div className="container">
        <div className="d-flex w-100 mb-3">
          <H3 className="w-100 text-center mr-3">Poaps</H3>
          {canUpdate && (
            <a onClick={() => setEditShow(true)} className="ml-auto">
              <Edit />
            </a>
          )}
        </div>
        <P2 className="text-center mb-6">A curated list of my main Poaps</P2>
        <div className="row d-flex flex-row justify-content-center mb-3">
          {poaps.map((poap) => (
            <div className="col-12 col-md-4 mb-4" key={poap.id}>
              <div className="web3-card">
                <div className="mb-3 d-flex flex-column justify-content-between">
                  <img src={poap.local_image_url} className="nft-img mb-4" />
                  <P2 text={poap.name} className="text-primary-04" />
                  <P3
                    text={
                      poap.description?.length > 200
                        ? `${poap.description.substring(0, 200)}...`
                        : poap.description
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
            <ThemedButton
              onClick={() => loadMorePoaps()}
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

export default Poaps;
