import React, { useEffect, useState } from "react";
import { H5, P2 } from "src/components/design_system/typography";
import TextInput from "src/components/design_system/fields/textinput";
import { emailRegex, emailRegexWithAliases } from "src/utils/regexes";
import { faSpinner, faCheck, faTimes } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { get } from "src/utils/requests";

const RegisterEmail = ({
  themePreference,
  email,
  changeEmail,
  changeStep,
  railsContext,
}) => {
  const [localEmail, setEmail] = useState(email);
  const [requestingEmail, setRequestingEmail] = useState(false);
  const [emailValidated, setEmailValidated] = useState(null);
  const [emailExists, setEmailExists] = useState(false);

  const validEmail = () => {
    if (railsContext.emailRegexWithoutAliases === "true") {
      return emailRegex.test(String(localEmail).toLowerCase());
    }

    return emailRegexWithAliases.test(String(localEmail).toLowerCase());
  };

  const submitEmailForm = (e) => {
    e.preventDefault();
    if (localEmail != "" && validEmail()) {
      changeEmail(localEmail);
      changeStep(4);
    }
  };

  const invalidForm = !validEmail() || !emailValidated || emailExists;

  useEffect(() => {
    if (localEmail.length === 0) {
      return;
    }

    const splitEmail = localEmail.split("@");

    if (splitEmail.length < 2) {
      return;
    }

    if (!splitEmail[1].includes(".")) {
      return;
    }

    if (!validEmail()) {
      setEmailValidated(false);
      return;
    }

    setRequestingEmail(true);
    const searchParams = new URLSearchParams({ email: localEmail });

    get(`/users?${searchParams}`)
      .then((response) => {
        if (response.error) {
          setRequestingEmail(false);
          setEmailExists(false);
          setEmailValidated(true);
        } else {
          setRequestingEmail(false);
          setEmailValidated(null);
          setEmailExists(true);
        }
      })
      .catch(() => {
        setRequestingEmail(false);
        setEmailExists(false);
        setEmailValidated(true);
      });
  }, [localEmail]);

  return (
    <div className="registration-items">
      <H5 text="What is your email?" bold />
      <P2
        className="text-black mb-5 mt-2"
        text="We'll need you to confirm your email"
        bold
      />
      <form onSubmit={submitEmailForm} className="d-flex flex-column w-100">
        <div className="form-group position-relative">
          <label htmlFor="inputEmail">
            <P2 className="text-black" text="Drop your email address" bold />
          </label>
          <TextInput
            mode={themePreference}
            type="email"
            id="inputEmail"
            ariaDescribedBy="emailHelp"
            value={localEmail}
            onChange={(e) => setEmail(e.target.value)}
          />
          {requestingEmail && (
            <FontAwesomeIcon
              icon={faSpinner}
              spin
              className="position-absolute"
              style={{ top: 42, right: 10 }}
            />
          )}
          {emailValidated && (
            <FontAwesomeIcon
              icon={faCheck}
              className="position-absolute text-success"
              style={{ top: 42, right: 10 }}
            />
          )}
          {emailValidated === false && (
            <FontAwesomeIcon
              icon={faTimes}
              className="position-absolute text-danger"
              style={{ top: 42, right: 10 }}
            />
          )}
          {emailValidated === false && (
            <small id="emailErrorHelp" className="form-text text-danger">
              This is not a valid email.
            </small>
          )}
          {emailExists && (
            <FontAwesomeIcon
              icon={faTimes}
              className="position-absolute text-danger"
              style={{ top: 42, right: 10 }}
            />
          )}
          {emailExists && (
            <small id="emailErrorHelp" className="form-text text-danger">
              We already have that email in the system.
            </small>
          )}
        </div>
        <button
          type="submit"
          disabled={invalidForm}
          className="btn btn-primary talent-button primary-default-button extra-big-size-button w-100 mt-6"
        >
          Create account
        </button>
      </form>
    </div>
  );
};

export default RegisterEmail;
