import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";
import { P3, H3, P2 } from "src/components/design_system/typography";
import { Edit } from "src/components/icons";
import ThemedButton from "src/components/design_system/button";
import { getNftData } from "src/onchain/utils";
import { ToastBody } from "src/components/design_system/toasts";
import { useWindowDimensionsHook } from "src/utils/window";

import NftsModal from "./edit/nftsModal";

const Nfts = ({ userId, canUpdate }) => {
  const [nfts, setNfts] = useState([]);
  const [editShow, setEditShow] = useState(false);
  const [pagination, setPagination] = useState({});
  const [chain, setChain] = useState(0);
  const { mobile } = useWindowDimensionsHook();

  useEffect(() => {
    get(`/api/v1/users/${userId}/profile/web3/nfts?visible=${true}`).then(
      (response) => {
        if (response.error) {
          toast.error(<ToastBody heading="Error!" body={response.error} />);
          console.log(response.error);
        } else {
          setPagination(response.pagination);
          mergeNfts(response.tokens);
        }
      }
    );
  }, [userId]);

  const mergeNfts = (newNfts) => {
    newNfts.map((nft) => {
      // Query blockchain when the local image is not defined
      if (nft.local_image_url) {
        setNfts((prev) => [...prev, nft]);
      } else {
        getNftData(nft).then((result) => {
          if (result?.name && result?.image && result?.imageType == "image") {
            const newNft = {
              ...nft,
              local_image_url: result.image,
            };
            setNfts((prev) => [...prev, newNft]);
          }
        });
      }
    });
  };

  const appendNft = (newNft) => {
    setNfts((prev) => [newNft, ...prev]);
  };

  const loadMoreNfts = () => {
    const nextPage = pagination.currentPage + 1;

    get(
      `/api/v1/users/${userId}/profile/web3/nfts?page=${nextPage}&visible=${true}`
    ).then((response) => {
      mergeNfts(response.tokens);
      setPagination(response.pagination);
    });
  };

  const showLoadMoreNfts = () => {
    return pagination.currentPage < pagination.lastPage;
  };

  return (
    <section className="d-flex flex-column align-items-center mt-6 mb-6">
      <NftsModal
        userId={userId}
        appendNft={appendNft}
        show={editShow && canUpdate}
        setShow={setEditShow}
        mobile={mobile}
        setChain={setChain}
        chain={chain}
      />
      <div className="container">
        <div className="d-flex w-100 mb-3">
          <H3 className="w-100 text-center mr-3">Nfts</H3>
          {canUpdate && (
            <a onClick={() => setEditShow(true)} className="ml-auto">
              <Edit />
            </a>
          )}
        </div>
        <P2 className="text-center mb-6">A curated list of my main nfts</P2>
        <div className="row d-flex flex-row justify-content-center mb-3">
          {nfts.map((nft) => (
            <div className="col-12 col-md-4 mb-4" key={nft.id}>
              <div className="web3-card">
                <div className="mb-3 d-flex flex-column justify-content-between">
                  <img src={nft.local_image_url} className="nft-img mb-4" />
                  <P2 text={nft.name} className="text-primary-04" />
                  <P3
                    text={
                      nft.description?.length > 200
                        ? `${nft.description.substring(0, 200)}...`
                        : nft.description
                    }
                    className="text-primary-01"
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
        {showLoadMoreNfts() && (
          <div className="d-flex flex-column justify-content-center mt-2">
            <ThemedButton
              onClick={() => loadMoreNfts()}
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

export default Nfts;
