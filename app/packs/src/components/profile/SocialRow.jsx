import React from "react";
import { faGlobeEurope } from "@fortawesome/free-solid-svg-icons";
import {
  faGithub,
  faTwitter,
  faLinkedin,
  faDiscord,
  faTelegram,
} from "@fortawesome/free-brands-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import Button from "src/components/design_system/button";

import cx from "classnames";

const SocialRow = ({ profile, className }) => {
  const telegramLink = () => {
    if (profile.telegram.length > 0 && profile.telegram[0] == "@") {
      const link = "https://t.me/" + profile.telegram.substring(1);
      return link;
    } else if (
      profile.telegram.length > 0 &&
      profile.telegram.includes("t.me")
    ) {
      return profile.telegram;
    } else {
      return "https://t.me/" + profile.telegram;
    }
  };

  const discordLink = () => {
    if (
      profile.discord.length > 0 &&
      profile.discord.includes("discordapp.com")
    ) {
      return profile.discord;
    } else {
      return `https://discordapp.com/users/${profile.discord}`;
    }
  };

  return (
    <div
      className={cx(
        "d-flex flex-row flex-wrap text-primary-03",
        className ? className : "mt-3 mt-lg-0 ml-lg-4"
      )}
    >
      {profile.website && (
        <a className="button-link" href={profile.website} target="self">
          <Button
            type="white-outline"
            size="big-icon"
            className="d-flex justify-content-center align-items-center mr-2"
          >
            <FontAwesomeIcon icon={faGlobeEurope} />
          </Button>
        </a>
      )}
      {profile.github && (
        <a className="button-link" href={profile.github} target="self">
          <Button
            type="white-outline"
            size="big-icon"
            className="d-flex justify-content-center align-items-center mr-2"
          >
            <FontAwesomeIcon icon={faGithub} />
          </Button>
        </a>
      )}
      {profile.linkedin && (
        <a className="button-link" href={profile.linkedin} target="self">
          <Button
            type="white-outline"
            size="big-icon"
            className="d-flex justify-content-center align-items-center mr-2"
          >
            <FontAwesomeIcon icon={faLinkedin} />
          </Button>
        </a>
      )}
      {profile.twitter && (
        <a className="button-link" href={profile.twitter} target="self">
          <Button
            type="white-outline"
            size="big-icon"
            className="d-flex justify-content-center align-items-center mr-2"
          >
            <FontAwesomeIcon icon={faTwitter} />
          </Button>
        </a>
      )}
      {profile.telegram && (
        <a className="button-link" href={telegramLink()} target="self">
          <Button
            type="white-outline"
            size="big-icon"
            className="d-flex justify-content-center align-items-center mr-2"
          >
            <FontAwesomeIcon icon={faTelegram} />
          </Button>
        </a>
      )}
      {profile.discord && (
        <a className="button-link" href={discordLink()} target="self">
          <Button
            type="white-outline"
            size="big-icon"
            className="d-flex justify-content-center align-items-center mr-2"
          >
            <FontAwesomeIcon icon={faDiscord} />
          </Button>
        </a>
      )}
    </div>
  );
};

export default SocialRow;
