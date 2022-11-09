import React, { useState } from "react";

import { post, destroy } from "src/utils/requests";
import { useWindowDimensionsHook } from "src/utils/window";

import HighlightsCard from "src/components/design_system/highlights_card";
import DiscoveryBanners from "src/components/design_system/banners/DiscoveryBanners";

import DiscoveryRow from "./discovery_row";
import DiscoveryMarketingArticles from "./discovery_marketing_articles";

import cx from "classnames";

const Discovery = ({
  discoveryRows,
  marketingArticles,
  user,
  railsContext,
}) => {
  const { mobile } = useWindowDimensionsHook();
  const [localDiscoveryRows, setLocalDiscoveryRows] = useState(discoveryRows);

  return (
    <div className="d-flex flex-column">
      {!mobile && <DiscoveryBanners user={user} />}
      <div
        className={cx(
          "w-100 d-flex flex-wrap mt-6 mb-6",
          mobile ? "justify-content-center" : "justify-content-between"
        )}
      >
        <HighlightsCard
          className="mt-2"
          title="Trending"
          link="/talent?status=Trending"
        />
        <HighlightsCard
          className="mt-2"
          title="Latest Added"
          link="/talent?status=Latest+added"
        />
        <HighlightsCard
          className="mt-2"
          title="Launching Soon"
          link="/talent?status=Launching+soon"
        />
      </div>
      {localDiscoveryRows.map((discoveryRow) => (
        <DiscoveryRow
          discoveryRow={discoveryRow}
          env={railsContext.contractsEnv}
        />
      ))}
      {marketingArticles.length > 0 && (
        <div className="mt-3 mb-4">
          <DiscoveryMarketingArticles marketingArticles={marketingArticles} />
        </div>
      )}
    </div>
  );
};

export default (props, railsContext) => {
  return () => <Discovery {...props} railsContext={railsContext} />;
};
