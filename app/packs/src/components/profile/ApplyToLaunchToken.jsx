import React from "react";

import { patch } from "src/utils/requests";
import { H3, P2 } from "src/components/design_system/typography";
import Button from "src/components/design_system/button";
import { useWindowDimensionsHook } from "src/utils/window";
import { useTheme } from "src/contexts/ThemeContext";
import { ArrowRight } from "src/components/icons";

import { white, lightTextPrimary01 } from "src/utils/colors.js";

import cx from "classnames";

const ApplyToLaunchToken = ({
  talent,
  waitingApproval,
  setLocalTalent,
  canUpdate,
}) => {
  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();

  const apply = async () => {
    let params = {
      user: {
        id: talent.user.id,
        profile_type: "waiting_for_approval",
      },
    };

    const response = await patch(`/api/v1/talent/${talent.id}`, params).catch(
      () => {
        return false;
      }
    );

    if (response && !response.error) {
      setLocalTalent((prev) => ({
        ...prev,
        user: { ...prev.user, profileType: response.user.profile_type },
      }));

      return true;
    }
  };

  if (!canUpdate) {
    return <></>;
  }

  return (
    <>
      <section
        className={cx(
          "d-flex flex-column mx-4 apply-to-launch-token-section",
          mobile ? "p-3" : "p-5 pt-6"
        )}
      >
        <div className="row">
          <div className={cx("col-12 col-lg-6", mobile ? "mb-6" : "mt-7")}>
            <H3 className="inverted-text-primary-01 mb-0">
              Apply to launch a{" "}
              <span className="highlight-word">Talent Token</span> and unlock
              benefits for{" "}
              <span className="highlight-word">your supporters</span>.
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
                disabled={waitingApproval}
                className={cx(
                  "d-flex justify-content-center align-items-center inverted-button",
                  mobile ? "w-75" : "ml-auto"
                )}
                type="white-default"
                onClick={() => apply()}
              >
                <P2
                  bold
                  text={waitingApproval ? "Waiting Approval" : "Apply"}
                />
                {!waitingApproval && (
                  <ArrowRight
                    color={mode() == "dark" ? white : lightTextPrimary01}
                    className="ml-2"
                    size={16}
                  />
                )}
              </Button>
            </div>
          </div>
        </div>
      </section>
    </>
  );
};

export default ApplyToLaunchToken;
