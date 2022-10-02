import React, { useState } from "react";
import Modal from "react-bootstrap/Modal";
import Button from "src/components/design_system/button";
import { P1, P2 } from "src/components/design_system/typography";
import { TALENT_GUIDE } from "src/utils/constants";
import { useWindowDimensionsHook } from "src/utils/window";

import { patch } from "src/utils/requests";

const TalentContent = () => (
  <>
    <Modal.Header closeButton className="mt-2 mx-2 mb-0 pb-0">
      <P1 text="🎉 Welcome to Talent Protocol!" bold />
    </Modal.Header>
    <Modal.Body className="d-flex flex-column justify-content-between mx-2 mb-2">
      <div>
        <P2 className="mb-1">
          Read this onboarding guide that will help you complete your profile,
          launch your token, and find your first supporters.
        </P2>
        <P2 className="mb-1">
          We're still in early beta, but already live on the Celo blockchain.
          Beta users like you have access to the $TAL token at a discounted
          price, and will be able to start earning rewards.
        </P2>
        <P2 className="mb-2">
          Thank you for being an early believer in the project.
        </P2>
      </div>
      <a className="button-link" target="self" href={TALENT_GUIDE}>
        <Button
          size="big"
          className="w-100 mt-6"
          type="primary-default"
          text="Check the Talent Guide"
          onClick={() => null}
        />
      </a>
    </Modal.Body>
  </>
);

const SupporterContent = () => (
  <>
    <Modal.Header closeButton>
      <Modal.Title className="px-3">💎 Welcome!</Modal.Title>
    </Modal.Header>
    <Modal.Body>
      <div className="d-flex flex-column w-100 p-3">
        <p>
          You're officially part of Talent Protocol, a platform where talent can
          launch a token and where supporters can back them.
        </p>
        <p>
          Read this onboarding guide that will help you set up your account,
          explore the platform and buy your first Talent Tokens.
        </p>
        <p>
          We're still in early beta, but already live on the Celo blockchain.
          Beta users like you have access to the $TAL token at a discounted
          price, and will be able to earn a high amount of rewards.
        </p>
        <p>Thank you for being an early believer in the project.</p>
        <a
          className="btn btn-primary"
          href="https://talentprotocol.notion.site/Supporter-Onboarding-Guide-1b9a378cb8224ba89ea5aff69cbf5735"
          target="self"
        >
          Check the Supporter Guide
        </a>
      </div>
    </Modal.Body>
  </>
);

const WelcomePopup = ({ talent, user_id }) => {
  const { mobile } = useWindowDimensionsHook();

  const [show, setShow] = useState(true);

  const onClose = () => {
    patch(`/api/v1/users/${user_id}`, {
      welcome_pop_up: true,
    });

    setShow(false);
  };

  return (
    <Modal
      scrollable={true}
      show={show}
      onHide={onClose}
      centered
      dialogClassName={mobile ? "mw-100 mh-100 m-0" : "remove-background"}
      contentClassName={mobile ? "h-100" : ""}
      fullscreen="true"
    >
      {talent ? <TalentContent /> : <SupporterContent />}
    </Modal>
  );
};

export default WelcomePopup;
