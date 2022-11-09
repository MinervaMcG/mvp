import React, { useEffect, useState, useCallback } from "react";
import { faSpinner, faCheck, faTimes } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import ReCAPTCHA from "react-google-recaptcha";
import { H5, P2, P3 } from "src/components/design_system/typography";
import TextInput from "src/components/design_system/fields/textinput";
import Checkbox from "src/components/design_system/checkbox";
import Link from "src/components/design_system/link";
import debounce from "lodash/debounce";
import { passwordMatchesRequirements } from "src/utils/passwordRequirements";
import Tag from "src/components/design_system/tag";

import { get } from "src/utils/requests";
import { TERMS_HREF, PRIVACY_HREF, USER_GUIDE } from "src/utils/constants";
import { useWindowDimensionsHook } from "src/utils/window";
import TalentProfilePicture from "src/components/talent/TalentProfilePicture";

import cx from "classnames";

const Welcome = ({
  themePreference,
  changeStep,
  changeCode,
  setCaptcha,
  captchaKey,
  inviteCode,
  name,
  profilePictureUrl,
  changeUsername,
  username,
  changePassword,
}) => {
  const { width } = useWindowDimensionsHook();
  const mobile = width < 992;

  const [localCaptcha, setLocalCaptcha] = useState(null);

  const [acceptedTerms, setAcceptedTerms] = useState(false);
  const [localCode, setCode] = useState(inviteCode || "");
  const [localUsername, setUsername] = useState(username);
  const [requestingUsername, setRequestingUsername] = useState(false);
  const [usernameError, setUsernameError] = useState("");
  const [localPassword, setLocalPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [samePassword, setSamePassword] = useState(true);
  const {
    valid: validPassword,
    errors,
    tags,
  } = passwordMatchesRequirements(localPassword);

  const invalidForm =
    !acceptedTerms ||
    !localCaptcha ||
    usernameError ||
    localPassword.length < 8 ||
    passwordConfirmation.length < 8 ||
    !validPassword ||
    !samePassword;

  const submitWelcomeForm = (e) => {
    e.preventDefault();
    if (localCaptcha && localUsername != "" && localPassword != "") {
      if (localCode.length > 0) {
        changeCode(localCode);
      }
      setCaptcha(localCaptcha);
      changePassword(localPassword);
      changeUsername(localUsername);
      changeStep(2);
    }
  };

  const updateUsername = (newUsername) => {
    setRequestingUsername(true);
    get(`api/v1/username/valid?username=${newUsername}`).then((response) => {
      setUsernameError(response.error);

      setUsername(newUsername);
      setRequestingUsername(false);
    });
  };

  const debouncedUpdateUsername = debounce(
    (newUsername) => updateUsername(newUsername),
    200
  );

  useEffect(() => {
    if (localPassword.length > 7 && passwordConfirmation.length > 7) {
      if (localPassword === passwordConfirmation) {
        setSamePassword(true);
      } else {
        setSamePassword(false);
      }
    } else {
      setSamePassword(true);
    }
  }, [localPassword, passwordConfirmation]);

  const recaptchaSubmition = (value) => {
    setLocalCaptcha(value);
  };

  const shouldRenderInvitedBy = inviteCode !== "" && !!name;

  return (
    <div className="registration-items">
      <div className="mb-6">
        {!shouldRenderInvitedBy && (
          <>
            <H5 text="Welcome to Talent Protocol!" bold />
            <P2
              className="text-primary-03"
              text="Sign up to build your web3 on-chain resume that gives you priority access to scholarships, opportunities, mentors and more."
            />
          </>
        )}
        {shouldRenderInvitedBy && (
          <div className="d-flex flex-row align-items-center">
            <TalentProfilePicture src={profilePictureUrl} height={120} />
            <div className="d-flex flex-column ml-3">
              <H5
                text={`${name} is inviting you to join Talent Protocol!`}
                bold
              />
              <P2
                className="text-primary-03"
                text="Sign up to build your web3 on-chain resume that gives you priority access to scholarships, opportunities, mentors and more."
              />
            </div>
          </div>
        )}
      </div>
      <form onSubmit={submitWelcomeForm} className="d-flex flex-column w-100">
        <div className="form-group position-relative">
          <label htmlFor="inputUsername" className="mt-2">
            <P2 className="text-black" text="Choose your handle" bold />
          </label>
          <TextInput
            mode={themePreference}
            type="text"
            id="inputUsername"
            value={localUsername}
            onChange={(e) => debouncedUpdateUsername(e.target.value)}
            error={usernameError}
          />
          <P2
            className="form-text text-primary-04 mt-1"
            text="This will be your Talent Protocol handle. We only accept lowercase letters and numbers."
          />
          {requestingUsername && (
            <FontAwesomeIcon
              icon={faSpinner}
              spin
              className="position-absolute"
              style={{ top: 48, right: 10 }}
            />
          )}
          {!usernameError && (
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
            <small id="usernameErrorHelp" className="form-text text-danger">
              {usernameError}
            </small>
          )}
          <label htmlFor="inputPassword">
            <P2 className="text-black mt-4" text="Choose Password" bold />
          </label>
          <TextInput
            mode={themePreference}
            type="password"
            id="inputPassword"
            ariaDescribedBy="passwordHelp"
            value={localPassword}
            onChange={(e) => setLocalPassword(e.target.value)}
          />
          <div className="d-flex flex-wrap">
            {tags.map((tag) => (
              <Tag
                className={`mr-2 mt-2${errors[tag] ? "" : " bg-success"}`}
                key={tag}
              >
                <P3
                  mode={themePreference}
                  text={tag}
                  bold
                  className={errors[tag] ? "" : "permanent-text-white"}
                />
              </Tag>
            ))}
          </div>
          <label htmlFor="inputPasswordConfirmation" className="mt-4">
            <P2 className="text-black" text="Confirm Password" bold />
          </label>
          <TextInput
            mode={themePreference}
            type="password"
            id="inputPasswordConfirmation"
            ariaDescribedBy="passwordConfirmationHelp"
            value={passwordConfirmation}
            onChange={(e) => setPasswordConfirmation(e.target.value)}
          />
          {!samePassword && (
            <P3
              className="mt-2 text-danger"
              mode={themePreference}
              text="The password does not match"
            />
          )}
        </div>
        <div className="form-group position-relative">
          <div className="d-flex flex-row w-100 mt-4">
            <ReCAPTCHA sitekey={captchaKey} onChange={recaptchaSubmition} />
          </div>
          <div className="form-group mt-4">
            <Checkbox
              className="form-check-input"
              htmlFor="termsAndConditions"
              id="termsAndConditions"
              checked={acceptedTerms}
              onChange={() => setAcceptedTerms((prev) => !prev)}
            >
              <div className="d-flex flex-wrap">
                <P2 className="mr-1" text="I have read and agree to the" />
                <Link
                  className="mr-1"
                  text="Terms & Conditions"
                  href={TERMS_HREF}
                  target="_blank"
                />
                <P2 className="mr-1" text="and " />
                <Link
                  text="Privacy Policy"
                  href={PRIVACY_HREF}
                  target="_blank"
                />
                <P2 text="." />
              </div>
            </Checkbox>
          </div>
        </div>
        <button
          type="submit"
          disabled={invalidForm}
          className="btn btn-primary talent-button primary-default-button extra-big-size-button w-100"
        >
          Continue
        </button>
      </form>
      <div
        className={cx("d-flex w-100 mt-6", mobile && "justify-content-center")}
      >
        <P2 className="text-black mr-1" text="Already have an account?" />
        <Link text="Login." href="/" bold />
      </div>
      <div
        className={cx(
          "d-flex w-100 mt-2",
          mobile && "justify-content-center pb-4"
        )}
      >
        <P2 className="text-black mr-1" text="Want more info?" />
        <Link
          bold
          href={USER_GUIDE}
          target="_blank"
          text="Check the user guide."
        />
      </div>
    </div>
  );
};

export default Welcome;
