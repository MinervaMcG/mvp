import React from "react";
import Modal from "react-bootstrap/Modal";

import { patch } from "src/utils/requests";

import { H5, P2 } from "src/components/design_system/typography";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";
import Divider from "src/components/design_system/other/Divider";
import Button from "src/components/design_system/button";
import { useWindowDimensionsHook } from "src/utils/window";

const AdminVerificationConfirmationModal = ({
  show,
  hide,
  talent,
  setTalent,
}) => {
  const { mobile } = useWindowDimensionsHook();

  const verifyTalent = async () => {
    const params = {
      talent: {
        verified: true,
      },
      user: {
        id: talent.user.id,
      },
    };

    const response = await patch(`/api/v1/talent/${talent.id}`, params).catch(
      () => {
        return false;
      }
    );

    if (response && !response.error) {
      setTalent((prev) => ({
        ...prev,
        verified: true,
      }));

      toast.success(
        <ToastBody heading="Success!" body={"User verified successfully."} />,
        { autoClose: 1500 }
      );

      hide();
      return true;
    }
  };

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
        <H5 bold text="Confirm Verification" />
      </Modal.Header>
      <Divider />
      <Modal.Body>
        <P2
          text={`Are you sure you want to verify ${
            talent.user.name || talent.user.username
          }?`}
        />
      </Modal.Body>
      <Modal.Footer className="px-6 py-3" style={{ borderTop: "none" }}>
        <Button
          className="mr-2"
          type="white-ghost"
          text="Cancel"
          onClick={hide}
        />
        <Button type="primary-default" text="Verify" onClick={verifyTalent} />
      </Modal.Footer>
    </Modal>
  );
};

export default AdminVerificationConfirmationModal;
