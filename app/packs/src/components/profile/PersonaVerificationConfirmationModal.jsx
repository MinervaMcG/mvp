import React, { useState } from "react";
import Modal from "react-bootstrap/Modal";

import { patch } from "src/utils/requests";
import { snakeCaseObject, camelCaseObject } from "src/utils/transformObjects";

import { H5, P2 } from "src/components/design_system/typography";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";
import Divider from "src/components/design_system/other/Divider";
import LoadingButton from "src/components/button/LoadingButton";
import Button from "src/components/design_system/button";
import TextInput from "src/components/design_system/fields/textinput";
import { useWindowDimensionsHook } from "src/utils/window";

const PersonaVerificationConfirmationModal = ({ show, hide, talent, setTalent, railsContext, mode }) => {
  const { mobile } = useWindowDimensionsHook();
  const [editedTalent, setEditedTalent] = useState(talent);
  const [loading, setLoading] = useState(false);

  const changeUserAttribute = (attribute, value) => {
    setEditedTalent(prev => ({
      ...prev,
      user: {
        ...prev.user,
        [attribute]: value
      }
    }));
  };

  const verifyTalent = async () => {
    // eslint-disable-next-line no-undef
    const client = new Persona.Client({
      templateId: railsContext.withPersonaTemplateId,
      environment: railsContext.withPersonaEnvironment,
      onReady: () => {
        setLoading(false);
        client.open();
        hide();
      },
      onComplete: ({ inquiryId /*status, fields*/ }) => {
        const params = {
          talent: {
            with_persona_id: inquiryId
          },
          user: {
            id: talent.user.id
          }
        };
        patch(`/api/v1/talent/${talent.id}`, params)
          .then(response => {
            setTalent(prev => ({
              ...prev,
              withPersonaId: response.with_persona_id
            }));

            toast.success(<ToastBody heading="Success!" body={"You're being verified. It can take up to 24 hours"} />, {
              autoClose: 2500
            });
            return true;
          })
          .catch(() => {
            return false;
          });
      }
    });
  };

  const saveProfile = async () => {
    setLoading(true);

    const response = await patch(`/api/v1/talent/${talent.id}`, {
      user: {
        ...snakeCaseObject(editedTalent.user)
      },
      talent: {
        ...snakeCaseObject(editedTalent)
      }
    });

    if (response && !response.error) {
      setTalent(prev => ({
        ...prev,
        ...camelCaseObject(response)
      }));

      verifyTalent();
    } else {
      toast.error(<ToastBody heading="Error!" body={response?.error} mode={mode} />);
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
        <H5 bold text="Confirm your name" />
      </Modal.Header>
      <Divider />
      <Modal.Body>
        <P2 text="Make sure your name matches the name in the ID you provide." />
        <div className="w-100 mt-3 mb-5">
          <TextInput
            className="mb-2"
            title="First Name"
            onChange={e => changeUserAttribute("legalFirstName", e.target.value)}
            value={editedTalent.user.legalFirstName}
          />
          <P2 className="text-primary-04" text="Your legal first name that will be used when verifying your account" />
        </div>
        <div className="w-100 mb-5">
          <TextInput
            className="mb-2"
            title="Last Name"
            onChange={e => changeUserAttribute("legalLastName", e.target.value)}
            value={editedTalent.user.legalLastName}
          />
          <P2 className="text-primary-04" text="Your legal last name that will be used when verifying your account" />
        </div>
      </Modal.Body>
      <Modal.Footer className="px-6 py-3" style={{ borderTop: "none" }}>
        <Button className="mr-2" type="white-ghost" text="Cancel" onClick={hide} />
        <LoadingButton type="primary-default" loading={loading} onClick={saveProfile}>
          Continue
        </LoadingButton>
      </Modal.Footer>
    </Modal>
  );
};

export default PersonaVerificationConfirmationModal;
