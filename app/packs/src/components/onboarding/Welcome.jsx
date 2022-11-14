import React, { useState, useEffect } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner, faCheck, faTimes } from "@fortawesome/free-solid-svg-icons";

import { get } from "src/utils/requests";

import { P2, P3, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";

const Welcome = ({
  changeStep,
  firstName,
  changeFirstName,
  lastName,
  changeLastName,
  username,
  changeUsername,
  allSteps,
}) => {
  const [localFirstName, setLocalFirstName] = useState(firstName);
  const [localLastName, setLocalLastName] = useState(lastName);
  const [localUsername, setLocalUsername] = useState(username);
  const [usernameError, setUsernameError] = useState("");
  const [validatingUsername, setValidatingUsername] = useState("");
  const [usernameValidated, setUsernameValidated] = useState(false);

  const submitWelcomeForm = (e) => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }

    changeFirstName(localFirstName);
    changeLastName(localLastName);
    changeUsername(localUsername);
    changeStep(2);
  };

  useEffect(() => {
    setValidatingUsername(true);
    setUsernameValidated(false);
    const validateUsername = setTimeout(() => {
      if (localUsername == "") {
        setValidatingUsername(false);
        return;
      }

      get(`api/v1/username/valid?username=${localUsername}`).then(
        (response) => {
          if (response.error == "") {
            setUsernameValidated(true);
          } else {
            setUsernameValidated(false);
          }
          setUsernameError(response.error);
          setValidatingUsername(false);
        }
      );
    }, 300);

    return () => clearTimeout(validateUsername);
  }, [localUsername]);

  const invalidForm =
    localFirstName == "" || localLastName == "" || localUsername == "";

  return (
    <div className="registration-items">
      <div className="d-flex flex-row justify-content-between mb-4">
        <P2 medium>
          Step 1<span className="text-primary-04">/{allSteps}</span>
        </P2>
      </div>
      <H5 text={`Welcome back!`} bold />
      <P2 className="mb-5 mt-2">
        A lot has changed since you last saw us! Take advantage of this quick
        onboarding to make sure relevant information is up to date and that new
        information is filled in. Let's get started!
      </P2>
      <form onSubmit={submitWelcomeForm} className="d-flex flex-column w-100">
        <div className="form-group position-relative">
          <label htmlFor="inputUsername" className="mt-2">
            <P2 className="text-black" text="Username" bold />
          </label>
          <TextInput
            type="text"
            id="inputUsername"
            value={localUsername}
            onChange={(e) => setLocalUsername(e.target.value)}
            shortCaption={
              !usernameError && `Your Talent Protocol URL: /u/${localUsername}`
            }
            error={usernameError}
          />
          {validatingUsername && (
            <FontAwesomeIcon
              icon={faSpinner}
              spin
              className="position-absolute"
              style={{ top: 48, right: 10 }}
            />
          )}
          {usernameValidated && (
            <FontAwesomeIcon
              icon={faCheck}
              className="position-absolute text-success"
              style={{ top: 48, right: 10 }}
            />
          )}
          {usernameError && (
            <FontAwesomeIcon
              icon={faTimes}
              className="position-absolute text-danger"
              style={{ top: 48, right: 10 }}
            />
          )}
          {usernameError && (
            <P3 className="mt-1 text-danger" text={usernameError} />
          )}
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputFirstName" className="mt-2">
            <P2 className="text-black" text="First Name" bold />
          </label>
          <TextInput
            type="text"
            id="inputFirstName"
            value={localFirstName}
            onChange={(e) => setLocalFirstName(e.target.value)}
          />
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputLastName" className="mt-2">
            <P2 className="text-black" text="Last Name" bold />
          </label>
          <TextInput
            type="text"
            id="inputLastName"
            value={localLastName}
            onChange={(e) => setLocalLastName(e.target.value)}
          />
        </div>
        <div className="d-flex flex-row justify-content-end mt-6">
          <button
            type="submit"
            disabled={invalidForm}
            className="btn btn-primary talent-button primary-default-button big-size-button mb-4"
          >
            Continue
          </button>
        </div>
      </form>
    </div>
  );
};

export default Welcome;
