import React, { useState } from "react";
import Modal from "react-bootstrap/Modal";
import Button from "src/components/design_system/button";
import TextArea from "src/components/design_system/fields/textarea";
import debounce from "lodash/debounce";
import { patch } from "src/utils/requests";

const RejectTalentModal = ({ show, setShow, mode, mobile, talent, setTalent }) => {
  const [note, setNote] = useState("");
  const [rejectingUser, setRejectingUser] = useState(false);

  const rejectUser = async () => {
    setRejectingUser(true);

    const params = {
      user: {
        id: talent.user.id,
        profile_type: "rejected",
        note: note
      }
    };

    const response = await patch(`/api/v1/talent/${talent.id}`, params).catch(() => {
      return false;
    });

    if (response && !response.error) {
      setTalent(prev => ({
        ...prev,
        user: { ...prev.user, profileType: "rejected" }
      }));

      setRejectingUser(false);
      setShow(false);
      return true;
    }
  };

  const debouncedRejectUser = debounce(() => rejectUser(), 200);

  return (
    <Modal
      scrollable={true}
      show={show}
      centered
      onHide={() => setShow(false)}
      dialogClassName={mobile ? "mw-100 mh-100 m-0" : "remove-background"}
      fullscreen={"md-down"}
    >
      <Modal.Header className="py-3 px-4" closeButton>
        Are you sure about rejecting this user?
      </Modal.Header>
      <Modal.Body className="show-grid pt-0 pb-4 px-4">
        <TextArea
          mode={mode}
          onChange={e => setNote(e.target.value)}
          placeholder="Share some feedback with the user"
          className="w-100"
          rows="5"
        />

        <Button
          type="primary-default"
          onClick={debouncedRejectUser}
          disabled={rejectingUser || !note}
          className="mt-3 float-right"
        >
          Reject
        </Button>
      </Modal.Body>
    </Modal>
  );
};

export default RejectTalentModal;
