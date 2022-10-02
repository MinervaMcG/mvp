import React, { useEffect, useContext, useState } from "react";

import Divider from "src/components/design_system/other/Divider";

import ThemeContainer, { ThemeContext } from "src/contexts/ThemeContext";
import { camelCaseObject } from "src/utils/transformObjects";
import { useWindowDimensionsHook } from "src/utils/window";
import Button from "src/components/design_system/button";
import Poaps from "./web3/poaps";
import Nfts from "./web3/nfts";
import Tokens from "./web3/tokens";
import Overview from "./Overview";
import About from "./About";
import Journey from "./Journey";

const Show = ({ talent, railsContext, currentUserId }) => {
  const localTalent = camelCaseObject(talent);
  const canUpdate = talent.user.id == currentUserId;
  const url = new URL(window.location);
  const [selectedSection, setSelectedSection] = useState(window.location.hash);

  const { mobile } = useWindowDimensionsHook();
  const theme = useContext(ThemeContext);

  const changeSection = (newSection) => {
    setSelectedSection(newSection);
  };

  const buttonType = (section) => {
    if (section == selectedSection) {
      return "white-default";
    } else {
      return "white-ghost";
    }
  };

  useEffect(() => {
    if (selectedSection) {
      const scrollDiv = document.getElementById(selectedSection).offsetTop;
      window.scrollTo({ top: scrollDiv - 70, behavior: "smooth" });
      window.history.replaceState(
        {},
        document.title,
        `${localTalent.user.username}${selectedSection}`
      );
    }
  }, [selectedSection]);

  return (
    <div className="d-flex flex-column lg-h-100 p-0 mt-7">
      <Overview
        className="mb-6"
        talent={localTalent}
        currentUserId={currentUserId}
        railsContext={railsContext}
      />
      <Divider className="my-6" />
      <div className="mt-3">
        <div className="d-flex justify-content-center overflow-x-scroll mx-4">
          <Button
            className="mr-2"
            type={buttonType("#About")}
            text="About"
            onClick={() => changeSection("#About")}
          />
          <Button
            className="mr-2"
            type={buttonType("#Journey")}
            text="Journey"
            onClick={() => changeSection("#Journey")}
          />
          <Button
            className="mr-2"
            type={buttonType(`#${localTalent.token.ticker}`)}
            text={localTalent.token.ticker}
            onClick={() => changeSection(`#${localTalent.token.ticker}`)}
          />
          <Button
            className="mr-2"
            type={buttonType("#Community")}
            text="Community"
            onClick={() => changeSection("#Community")}
          />
          <Button
            type={buttonType("#DigitalCollectibles")}
            text="Digital Collectibles"
            onClick={() => changeSection("#DigitalCollectibles")}
          />
        </div>
      </div>
      <div className="my-7 w-100" id="#About">
        <About talent={localTalent} />
      </div>
      {mobile && <Divider />}
      <div className="my-7 w-100" id="#Journey">
        <Journey talent={localTalent} />
      </div>
      <div className="my-7 w-100" id={`#${localTalent.token.ticker}`}></div>
      <div className="my-7 w-100" id="#Community"></div>
      <div className="my-7 w-100" id="#DigitalCollectibles">
        <Poaps userId={talent.user.id} canUpdate={canUpdate} />
        <Nfts userId={talent.user.id} canUpdate={canUpdate} />
        <Tokens userId={talent.user.id} canUpdate={canUpdate} />
      </div>
    </div>
  );
};

export default (props, railsContext) => {
  return () => (
    <ThemeContainer>
      <Show {...props} railsContext={railsContext} />
    </ThemeContainer>
  );
};
