import React, { useEffect, useState } from "react";
import { faTimes } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { Spinner, Check } from "src/components/icons";
import { H5, P2 } from "src/components/design_system/typography";

import { post } from "src/utils/requests";

import { lightPrimary, darkPrimary } from "src/utils/colors.js";
import { useTheme } from "src/contexts/ThemeContext";

const ProcessingUser = () => (
  <>
    <Spinner />
    <H5 className="mb-1 mt-6" text="Setting up your profile" bold />
    <P2>
      Get ready to start building your community. Find supporters and start
      supporting other high-potential builders.
    </P2>
  </>
);

const UserSaved = ({ mode }) => (
  <>
    <H5 className="mb-1" text="Welcome to Talent Protocol!" bold />
    <P2
      className="mb-6 text-center"
      text="We're a community where talent can launch a token and where supporters can back them. Build your profile, connect your wallet and grow your potential."
    />
    <Check color={mode() == "dark" ? darkPrimary : lightPrimary} size={64} />
    <button
      type="button"
      onClick={() => window.location.reload()}
      className="btn btn-primary talent-button primary-default-button big-size-button w-100 mt-6"
    >
      Explore
    </button>
  </>
);

const UserFailed = ({ error }) => (
  <div className="d-flex flex-column text-danger align-items-center">
    <div className="d-flex flex-row align-items-center">
      <FontAwesomeIcon icon={faTimes} />
      <p className="ml-2 mb-0">We had an issue updating your user.</p>
    </div>
    <p className="ml-2 mb-0">{error}</p>
  </div>
);

const ProcessFlow = ({
  firstName,
  lastName,
  occupation,
  experienceLevel,
  careerNeeds,
  position,
  gender,
  ethnicity,
  nationality,
}) => {
  const { mode } = useTheme();

  const [userSaved, setUserSaved] = useState(false);
  const [requesting, setRequesting] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    setRequesting(true);
    post("/finish", {
      occupation,
      experienceLevel,
      careerNeeds,
      position,
      gender,
      ethnicity,
      nationality,
      legal_first_name: firstName,
      legal_last_name: lastName,
    })
      .then((response) => {
        if (response.success) {
          setUserSaved(true);
          setRequesting(false);
        } else {
          setError("Unable to save your profile.");
          setRequesting(false);
        }
      })
      .catch(() => {
        setError("Please reach out to us if this persists.");
        setRequesting(false);
      });
  }, []);

  return (
    <div className="d-flex flex-column align-items-center registration-items">
      {error != "" && <UserFailed error={error} />}
      {!userSaved && requesting && <ProcessingUser />}
      {userSaved && <UserSaved mode={mode} />}
    </div>
  );
};

export default ProcessFlow;
