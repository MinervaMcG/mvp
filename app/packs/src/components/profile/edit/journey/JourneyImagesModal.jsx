import React from "react";
import Modal from "react-bootstrap/Modal";

import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import Divider from "src/components/design_system/other/Divider";
import { H5 } from "src/components/design_system/typography";

import { useWindowDimensionsHook } from "src/utils/window";

import cx from "classnames";

const JourneyImagesModal = ({ show, hide, journeyItem }) => {
  const { mobile } = useWindowDimensionsHook();

  return (
    <Modal
      scrollable={true}
      show={show}
      onHide={hide}
      centered
      dialogClassName={mobile ? "mw-100 mh-100 m-0" : "remove-background"}
      contentClassName={mobile ? "h-100" : ""}
      fullscreen="true"
      className="edit-modal"
    >
      <Modal.Header closeButton className="px-5">
        <H5 bold text="All images" />
      </Modal.Header>
      <Divider />
      <Modal.Body
        className={cx(
          "d-flex flex-wrap align-items-center justify-content-center",
          mobile ? "px-4 pt-4 pb-7" : "px-6 pt-5 pb-6"
        )}
        style={{ maxHeight: mobile ? "" : "700px", overflowY: "overlay" }}
      >
        {journeyItem.images.map((image) => (
          <div className="d-flex" key={image.imageUrl}>
            <TalentProfilePicture
              className="mr-2 mt-2"
              style={{ borderRadius: "24px" }}
              src={image.imageUrl}
              straight
              height={176}
              width={225}
            />
          </div>
        ))}
      </Modal.Body>
    </Modal>
  );
};

export default JourneyImagesModal;
