import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";

import { Caption } from "src/components/design_system/typography";
import { P3, H3, P2 } from "src/components/design_system/typography";

import { getNftData } from "src/onchain/utils";

import { ToastBody } from "src/components/design_system/toasts";

const Nfts = (userId) => {
  const [nfts, setNfts] = useState([]);

  useEffect(() => {
    get(`/api/v1/users/${userId}/profile/web3/nfts`).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
        console.log(response.error);
      } else {
        response.map((nft) => {
          getNftData(nft).then((result) => {
            const newNft = {
              ...nft,
              imageUrl: result.image,
              description: result.description,
            };
            setNfts((prev) => [...prev, newNft]);
          });
        });
      }
    });
  }, [userId]);

  return (
    <section className="d-flex flex-column align-items-center mt-6">
      <H3>Nfts</H3>
      <P2 className="mb-6">A curated list of my main nfts</P2>
      {nfts.map((nft) => (
        <div className="d-flex flex-row web3-card mb-3">
          <div className="d-flex flex-column w-100 align-items-center">
            <img src={nft.imageUrl} className="nft-img mb-4" />
            <P2 text={nft.name} className="text-primary-04" />
            <P3 text={nft.description} className="text-primary-04" />
          </div>
        </div>
      ))}
    </section>
  );
};

export default Nfts;
