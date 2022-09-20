import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";

import { Caption } from "src/components/design_system/typography";
import { P3, H3, P2, P4, H4 } from "src/components/design_system/typography";

import { getPOAPData } from "src/onchain/utils";

import { ToastBody } from "src/components/design_system/toasts";

const Poaps = (userId) => {
  const [poaps, setPoaps] = useState([]);

  useEffect(() => {
    get(`/api/v1/users/${userId}/profile/web3/poaps`).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
        console.error(response.error);
      } else {
        response.map((poap) =>
          getPOAPData(poap.address, poap.token_id).then((result) => {
            const newPoap = {
              ...poap,
              imageUrl: result.image_url,
              description: result.description,
              name: result.name,
              year: result.year,
            };
            setPoaps((prev) => [...prev, newPoap]);
          })
        );
      }
    });
  }, [userId]);

  return (
    <section className="d-flex flex-column align-items-center">
      <H3>Poaps</H3>
      <P2 className="mb-6">A curated list of my main POAPs</P2>
      {poaps.map((poap) => (
        <div key={`poap_list_${poap.id}`} className="d-flex flex-row web3-card">
          <div className="d-flex flex-column">
            <img src={poap.imageUrl} className="nft-img mb-4" />
            <P3 text={poap.year} className="text-primary-04" />
            <P2 text={poap.name} bold className="text-primary-04 mb-3" />
            <P3 text={poap.description} className="text-primary-04" />
          </div>
        </div>
      ))}
    </section>
  );
};

export default Poaps;
