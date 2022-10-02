import React, { useState } from "react";
import Modal from "react-bootstrap/Modal";
import Button from "src/components/design_system/button";
import { patch } from "src/utils/requests";
import { useWindowDimensionsHook } from "src/utils/window";
import { P1, P2 } from "src/components/design_system/typography";

import cx from "classnames";

const FirstQuestPopup = ({ userId }) => {
  const { mobile } = useWindowDimensionsHook();

  const [show, setShow] = useState(true);

  const onClick = () => {
    patch(`/api/v1/users/${userId}`, {
      first_quest_popup: true,
    }).then(() => {
      window.location.replace("/earn?tab=quests");
    });
  };

  const markAsRead = () => {
    patch(`/api/v1/users/${userId}`, {
      first_quest_popup: true,
    }).then(() => setShow(false));
  };

  return (
    <Modal
      scrollable={true}
      show={show}
      onHide={markAsRead}
      centered
      dialogClassName={mobile ? "mw-100 mh-100 m-0" : "remove-background"}
      contentClassName={mobile ? "h-100" : ""}
      fullscreen="true"
    >
      <Modal.Header closeButton className="mt-2 mx-2 mb-0 pb-0">
        <P1 className="text-black mb-2 text-center" bold text="Earn rewards" />
      </Modal.Header>
      <Modal.Body className="d-flex flex-column justify-content-between mx-2 mb-2">
        {mobile && <div></div>}
        <div>
          <P2
            className="text-primary-03"
            text="Now that you're set, it's time for your first quest. Complete the 'About' section
                  on your profile and connect your wallet to earn your first reward."
          />
        </div>
        <div className="d-flex mt-6 w-100">
          <Button
            className="mr-2 w-50"
            onClick={markAsRead}
            text="Cancel"
            type="white-subtle"
            size="big"
          />
          <Button
            className="w-50"
            size="big"
            type="primary-default"
            text="See all quests"
            onClick={onClick}
          />
        </div>
      </Modal.Body>
    </Modal>
  );
};

export default FirstQuestPopup;
