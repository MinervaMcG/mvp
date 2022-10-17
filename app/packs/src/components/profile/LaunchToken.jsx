import React, { useState } from "react";

import { H3, P3, P2 } from "src/components/design_system/typography";
import Button from "src/components/design_system/button";
import { useWindowDimensionsHook } from "src/utils/window";
import { useTheme } from "src/contexts/ThemeContext";
import { ArrowRight } from "src/components/icons";

import { missingFields } from "src/components/talent/utils/talent";

import cx from "classnames";

import LaunchTokenModals from "../talent/Edit/LaunchTokenModals";

const LaunchToken = ({ talent, railsContext, setLocalTalent }) => {
  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();
  const token = talent.token;
  const user = talent.user;
  const [ticker, setTicker] = useState(token.ticker || "");
  const [show, setShow] = useState(false);
  const requiredFields = missingFields({
    talent: talent,
    profilePictureUrl: talent.profilePictureUrl,
    careerGoal: talent.careerGoal,
  });

  return (
    <>
      {show && (
        <LaunchTokenModals
          show={show}
          setShow={setShow}
          changeSharedState={setLocalTalent}
          mode={mode()}
          talent={talent}
          token={token}
          user={user}
          railsContext={railsContext}
          setContractId={() => {}}
          ticker={ticker}
          changeTicker={setTicker}
        />
      )}
      <section
        className={cx(
          "d-flex flex-column mx-4 launch-token-section",
          mobile ? "p-3" : "p-5 pt-6"
        )}
      >
        <div className="row">
          <div className={cx("col-12 col-lg-6", mobile ? "mb-6" : "mt-7")}>
            <H3 className="inverted-text-primary-01 mb-0">
              Launch a <span className="highlight-word">Talent Token</span> and
              unlock benefits for{" "}
              <span className="highlight-word">your supporters.</span>
            </H3>
          </div>
          <div
            className={cx(
              "col-12 col-lg-6",
              !mobile && "d-flex flex-column justify-content-end"
            )}
          >
            <div className="d-flex mt-6">
              <Button
                disabled={requiredFields.length > 0}
                className={cx(
                  "d-flex justify-content-center align-items-center inverted-button",
                  mobile ? "w-75" : "ml-auto"
                )}
                type="white-default"
                onClick={() => setShow(true)}
              >
                <P2
                  bold
                  text={
                    requiredFields.length > 0
                      ? "Profile Incomplete"
                      : "Launch my token"
                  }
                />
                {requiredFields.length == 0 && (
                  <ArrowRight className="ml-2" size={16} />
                )}
              </Button>
            </div>
          </div>
        </div>
      </section>
    </>
  );
};

export default LaunchToken;
