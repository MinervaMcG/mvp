import React, { useEffect, useState } from "react";
import Modal from "react-bootstrap/Modal";
import { faTimes } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { Spinner, Check } from "src/components/icons";
import { H5, P2 } from "src/components/design_system/typography";

import { post } from "src/utils/requests";
import Button from "src/components/design_system/button";
import Link from "src/components/design_system/link";

import { lightPrimary, darkPrimary } from "src/utils/colors.js";
import { useTheme } from "src/contexts/ThemeContext";

const ProcessingUser = ({ themePreference }) => (
  <>
    <Spinner />
    <H5 className="mb-1 mt-6" text="Setting up your account" bold mode={themePreference} />
    <P2 text="We're checking the guest list" mode={themePreference} />
  </>
);

const UserCreated = ({ themePreference, sendConfirmationEmail, mode, email }) => (
  <>
    <H5 className="mb-1" text="Confirm your email" bold mode={themePreference} />
    <P2 className="mb-6 text-center" text={`We've just sent a confirmation email to ${email}`} />
    <Check color={mode() == "dark" ? darkPrimary : lightPrimary} size={64} />
    <p className="p2 text-black mt-6">
      Didn't received an email?{" "}
      <button className="button-link text-primary" onClick={sendConfirmationEmail}>
        <Link text="Resend" />
      </button>
    </p>
  </>
);

const UserFailed = ({ error }) => (
  <div className="d-flex flex-column text-danger align-items-center">
    <div className="d-flex flex-row align-items-center">
      <FontAwesomeIcon icon={faTimes} />
      <p className="ml-2 mb-0">We had an issue creating your user.</p>
    </div>
    <p className="ml-2 mb-0">{error}</p>
  </div>
);

const ConfirmationEmailModal = ({ show, setShow, themePreference }) => (
  <Modal show={show} centered onHide={() => setShow(false)} dialogClassName="remove-background">
    <Modal.Body className="show-grid p-4">
      <H5 className="mb-2" text="Email Verification" bold mode={themePreference} />
      <P2 text="We’ve just sent you another confirmation email" />
      <Button
        type="primary-default"
        size="extra-big"
        className="w-100 mt-6"
        text="I Understand"
        onClick={() => setShow(false)}
      />
    </Modal.Body>
  </Modal>
);

const ProcessFlow = ({ email, username, firstName, lastName, password, code, captcha, themePreference }) => {
  const { mode } = useTheme();

  const [userCreated, setUserCreated] = useState(false);
  const [userId, setUserId] = useState(null);
  const [requesting, setRequesting] = useState(false);
  const [error, setError] = useState("");
  const [showConfirmationEmailModal, setShowConfirmationEmailModal] = useState(false);

  const sendConfirmationEmail = () => {
    post(`users/${userId}/send_confirmation_email.json`).then(() => {
      setShowConfirmationEmailModal(true);
    });
  };

  useEffect(() => {
    setRequesting(true);
    post("/users.json", {
      email,
      username,
      password,
      code,
      captcha,
      legal_first_name: firstName,
      legal_last_name: lastName,
      theme_preference: themePreference
    })
      .then(response => {
        if (response.error) {
          setError(response.error);
          setRequesting(false);
        } else {
          setUserCreated(true);
          setRequesting(false);
          setUserId(response.id);
        }
      })
      .catch(() => {
        setError("Please reach out to us if this persists.");
        setRequesting(false);
      });
  }, [email]);

  return (
    <div className="d-flex flex-column align-items-center registration-items">
      {error != "" && <UserFailed error={error} />}
      {!userCreated && requesting && <ProcessingUser themePreference={themePreference} />}
      {userCreated && (
        <UserCreated
          themePreference={themePreference}
          sendConfirmationEmail={sendConfirmationEmail}
          email={email}
          mode={mode}
        />
      )}
      <ConfirmationEmailModal
        show={showConfirmationEmailModal}
        setShow={setShowConfirmationEmailModal}
        themePreference={themePreference}
      />
    </div>
  );
};

export default ProcessFlow;
