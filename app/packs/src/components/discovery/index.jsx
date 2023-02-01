import React from "react";

import { useWindowDimensionsHook } from "src/utils/window";

import HighlightsCard from "src/components/design_system/highlights_card";
import DiscoveryBanners from "src/components/design_system/banners/DiscoveryBanners";

import DiscoveryRow from "./discovery_row";

import cx from "classnames";

const Discovery = ({
  discoveryRows,
  /*marketingArticles,*/
  user,
  railsContext
}) => {
  const { mobile } = useWindowDimensionsHook();

  return (
    <div className="d-flex flex-column">
      {!mobile && <DiscoveryBanners user={user} />}
      <div
        className={cx(
          "w-100 d-flex flex-wrap mt-6 mb-6",
          mobile ? "justify-content-center" : "justify-content-between"
        )}
      >
        <HighlightsCard className="mt-2" title="Trending" link="/talent?status=Trending" />
        <HighlightsCard className="mt-2" title="Latest Added" link="/talent?status=Latest+added" />
        <HighlightsCard className="mt-2" title="Launching Soon" link="/talent?status=Launching+soon" />
      </div>
      {discoveryRows.map(discoveryRow => (
        <DiscoveryRow discoveryRow={discoveryRow} env={railsContext.contractsEnv} />
      ))}
    </div>
  );
};

export default (props, railsContext) => {
  return () => <Discovery {...props} railsContext={railsContext} />;
};
