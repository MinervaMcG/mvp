import React from "react";
import Modal from "react-bootstrap/Modal";

import { patch } from "src/utils/requests";

import { H5, P2 } from "src/components/design_system/typography";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";
import Divider from "src/components/design_system/other/Divider";
import Button from "src/components/design_system/button";
import { useWindowDimensionsHook } from "src/utils/window";

const ApprovalConfirmationModal = ({ show, hide, talent, setTalent }) => {
  const { mobile } = useWindowDimensionsHook();

  const approveUser = async () => {
    const params = {
      user: {
        id: talent.user.id,
        profile_type: "approved"
      }
    };

    const response = await patch(`/api/v1/talent/${talent.id}`, params).catch(() => {
      return false;
    });

    if (response && !response.error) {
      setTalent(prev => ({
        ...prev,
        user: { ...prev.user, profileType: "approved" }
      }));

      toast.success(<ToastBody heading="Success!" body={"User approved successfully."} />, { autoClose: 1500 });

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
        <H5 bold text="Confirm approval" />
      </Modal.Header>
      <Divider />
      <Modal.Body>
        <P2 text={`Are you sure you want to approve ${talent.user.name || talent.user.username}?`} />
      </Modal.Body>
      <Modal.Footer className="px-6 py-3" style={{ borderTop: "none" }}>
        <Button className="mr-2" type="white-ghost" text="Cancel" onClick={hide} />
        <Button type="primary-default" text="Approve" onClick={approveUser} />
      </Modal.Footer>
    </Modal>
  );
};

export default ApprovalConfirmationModal;
