import React, { useState } from "react";
import Modal from "react-bootstrap/Modal";
import ThemedButton from "src/components/design_system/button";
import TextInput from "src/components/design_system/fields/textinput";
import { post } from "src/utils/requests";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";

const CreatePerkModal = ({
  talentId,
  token,
  show,
  closeModal,
  appendPerk,
  mobile,
  mode,
}) => {
  const [attributes, setAttributes] = useState({
    price: 0,
    title: "",
  });
  const [validationErrors, setValidationErrors] = useState({});

  const changeAttribute = (attribute, value) => {
    if (Object.keys(validationErrors).length > 0) {
      setValidationErrors({});
    }

    setAttributes((prev) => ({
      ...prev,
      [attribute]: value,
    }));
  };

  const perkValid = () => {
    const errors = {};
    if (attributes.title == "") {
      errors["title"] = true;
    }
    if (attributes.price == "") {
      errors["price"] = true;
    }

    return errors;
  };

  const createPerk = async () => {
    const errors = perkValid();

    if (Object.keys(errors).length == 0) {
      const response = await post(`/api/v1/talent/${talentId}/perks`, {
        perk: {
          ...attributes,
        },
      });

      if (response && !response.error) {
        // update local state
        appendPerk(response);

        closeModal();

        toast.success(
          <ToastBody
            heading="Success!"
            body={"New perk added successfully."}
            mode={mode}
          />,
          { autoClose: 1500 }
        );
      } else {
        toast.error(
          <ToastBody heading="Error!" body={response?.error} mode={mode} />
        );
      }
    } else {
      setValidationErrors(errors);
    }
  };

  return (
    <Modal
      scrollable={true}
      centered
      show={show}
      onHide={() => closeModal()}
      dialogClassName={
        mobile ? "mw-100 mh-100 m-0" : "modal-lg remove-background"
      }
      fullscreen={"md-down"}
    >
      <Modal.Header className="py-3 px-4 modal-border" closeButton>
        <Modal.Title>Add new Perk</Modal.Title>
      </Modal.Header>
      <Modal.Body className="show-grid p-4">
        <TextInput
          title={"Title"}
          mode={mode}
          shortCaption="What's your perk"
          onChange={(e) => changeAttribute("title", e.target.value)}
          value={attributes.title}
          className="edit-profile-input"
          required={true}
          error={validationErrors?.title}
        />
        <div className="d-flex flex-row justify-content-between mt-4 flex-wrap">
          <TextInput
            title={`Amount ${token.ticker || ""}`}
            type="number"
            mode={mode}
            placeholder={"0,000.00"}
            shortCaption={
              "Amount of talent tokens the supporter must hold to redeem this perk."
            }
            onChange={(e) => changeAttribute("price", e.target.value)}
            value={attributes.price}
            className="edit-profile-input"
            required={true}
            error={validationErrors?.price}
          />
        </div>
      </Modal.Body>
      <Modal.Footer className="px-4 py-3">
        <ThemedButton
          onClick={() => closeModal()}
          type="white-ghost"
          className="mr-auto"
        >
          Cancel
        </ThemedButton>
        <ThemedButton
          onClick={() => createPerk()}
          type="primary-default"
          className="ml-2"
        >
          Save
        </ThemedButton>
      </Modal.Footer>
    </Modal>
  );
};

export default CreatePerkModal;
