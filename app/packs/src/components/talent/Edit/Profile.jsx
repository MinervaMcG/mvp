import React, { useState, useContext, useEffect } from "react";

import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";
import { useWindowDimensionsHook } from "src/utils/window";
import { railsContextStore } from "src/contexts/state";

import Settings from "./Settings";

const Profile = (props) => {
  const theme = useContext(ThemeContext);
  const { mobile } = useWindowDimensionsHook();
  const [sharedState, setSharedState] = useState({ ...props });

  const railsContext = props.railsContext;
  const setRailsContext = railsContextStore((state) => state.setRailsContext);

  useEffect(() => {
    setRailsContext(props.railsContext);
  }, []);

  return (
    <div className="d-flex flex-column align-items-center mt-5">
      <div className="d-flex flex-column edit-profile-content w-100">
        <Settings
          {...sharedState}
          mode={theme.mode()}
          mobile={mobile}
          changeSharedState={setSharedState}
          etherscanApiKey={railsContext.etherscanApiKey}
          env={railsContext.contractsEnv}
          talBaseDomain={railsContext.talBaseDomain}
        />
      </div>
    </div>
  );
};

export default (props, railsContext) => {
  return () => (
    <ThemeContainer>
      <Profile {...props} railsContext={railsContext} />
    </ThemeContainer>
  );
};
