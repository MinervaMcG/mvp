import React from "react";
import { P2 } from "src/components/design_system/typography";
import ParagraphLink from "src/components/design_system/link/ParagraphLink";
import Tooltip from "src/components/design_system/tooltip";
import { Help } from "src/components/icons";
import { lightTextPrimary03 } from "src/utils/colors";
import { TOP_UP_YOUR_ACCOUNT, BUY_TALENT_TOKENS } from "src/utils/constants";

import cx from "classnames";

export const questDescription = (type) => {
  switch (type) {
    case "Quests::User":
      return "Complete your 'About' section and connect your wallet";
    case "Quests::Supporter":
      return "Add 3 talent to your Watchlist and buy at least 1 Talent Token";
    case "Quests::TalentProfile":
      return "Complete the mandatory fields of your profile and share it with your network.";
    case "Quests::VerifiedProfile":
      return "Click on the Verify button in your profile and get verified";
    case "Quests::TalentToken":
      return "Complete the mandatory fields of your profile and apply to be verified.";
    default:
      return "";
  }
};

export const taskDescription = (type) => {
  switch (type) {
    case "Tasks::FillInAbout":
      return (
        <>
          <P2
            className="text-primary-03"
            text="Go to your profile and fill in your basic information (first two sections)."
          />
          <P2
            className="text-primary-03"
            text="You'll need a profile picture, a headline, atleast one tag and filling in your 'About'."
          />
        </>
      );
    case "Tasks::ConnectWallet":
      return (
        <P2
          className="text-primary-03"
          text="Connect your wallent in the top menu."
        />
      );
    case "Tasks::Watchlist":
      return (
        <P2
          className="text-primary-03"
          text="Use the watchlist feature (the little star in each talent profile) to save your favourite people for later."
        />
      );
    case "Tasks::BuyTalentToken":
      return (
        <P2 className="text-primary-03">
          <ParagraphLink
            text="Top up your account"
            href={TOP_UP_YOUR_ACCOUNT}
            target="_blank"
          />{" "}
          and{" "}
          <ParagraphLink
            text="buy at least 1 Talent Token."
            href={BUY_TALENT_TOKENS}
            target="_blank"
          />
        </P2>
      );
    case "Tasks::LaunchToken":
      return (
        <P2
          className="text-primary-03"
          text="Launch your token so people can start investing in you"
        />
      );
    case "Tasks::Highlights":
      return (
        <P2
          className="text-primary-03"
          text="Fill in your journey with highlights and positions."
        />
      );
    case "Tasks::Goals":
      return (
        <P2
          className="text-primary-03"
          text="Add career goals to your profile."
        />
      );
    case "Tasks::ApplyTokenLaunch":
      return (
        <P2
          className="text-primary-03"
          text="Apply to launch your Talent Token"
        />
      );
    case "Tasks::Perks":
      return (
        <P2 className="text-primary-03" text="Add perks to your profile." />
      );
    case "Tasks::Verified":
      return (
        <div className="d-flex align-items-center">
          <P2 className="text-primary-03">
            Click on the Verify button in your profile and get verified.
            <Tooltip
              body={
                "In order to verify your account your profile must be complete and we must match the legal name you provided with the ID provided"
              }
              popOverAccessibilityId={"verify_tooltip"}
              placement="top"
            >
              <Help
                className="cursor-pointer ml-1"
                color={lightTextPrimary03}
              />
            </Tooltip>
          </P2>
        </div>
      );
    default:
      return "";
  }
};

export const taskReward = (type, disabled) => {
  switch (type) {
    case "Tasks::BuyTalentToken":
      return (
        <ParagraphLink
          text="Talent Mate 'Token Holder' skin unlock"
          href={"https://mates.talentprotocol.com/"}
          target="_blank"
          disabled={disabled}
        />
      );
    case "Tasks::LaunchToken":
      return (
        <P2
          className={cx(disabled ? "text-primary-04" : "text-black")}
          text="2,000 Talent Tokens (worth $200)"
        />
      );
    default:
      return "";
  }
};

export const questRewards = (type, disabled) => {
  switch (type) {
    case "Quests::User":
      return [
        <ParagraphLink
          text="Talent Hunt"
          href={"/earn?tab=talent"}
          disabled={disabled}
        />,
      ];
    case "Quests::TalentProfile":
      return [
        <P2
          className={cx(disabled ? "text-primary-04" : "text-black")}
          text="50 TAL"
        />,
        <P2
          className={cx(disabled ? "text-primary-04" : "text-black")}
          text="Unlock verification process"
        />,
        <P2
          className={cx(disabled ? "text-primary-04" : "text-black")}
          text="Unlock token launch process"
        />,
      ];
    case "Quests::TalentToken":
      return [
        <ParagraphLink
          text="Talent Mate 'Talent' skin unlock"
          href={"https://mates.talentprotocol.com/"}
          target="_blank"
          disabled={disabled}
        />,
      ];
    case "Quests::VerifiedProfile":
      return [
        <P2
          className={cx(disabled ? "text-primary-04" : "text-black")}
          text="Verified badge"
        />,
        <ParagraphLink
          text="Talent Mate basic skin unlock"
          href={"https://mates.talentprotocol.com/"}
          target="_blank"
          disabled={disabled}
        />,
      ];
    default:
      return null;
  }
};
