import React, { useState } from "react";
import Modal from "react-bootstrap/Modal";
import ThemedButton from "src/components/design_system/button";
import TextInput from "src/components/design_system/fields/textinput";
import { destroy, patch } from "src/utils/requests";
import debounce from "lodash/debounce";
import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";

const EditPerkModal = ({
  talentId,
  talentToken,
  perk,
  show,
  closeModal,
  mergePerk,
  removePerk,
  mobile,
  mode,
}) => {
  const [attributes, setAttributes] = useState(perk);
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

  const updatePerk = async () => {
    const errors = perkValid();

    if (Object.keys(errors).length == 0) {
      const response = await patch(
        `/api/v1/talent/${talentId}/perks/${perk.id}`,
        {
          perk: {
            ...attributes,
          },
        }
      );

      if (response && !response.error) {
        // update local state
        mergePerk(response);

        closeModal();

        toast.success(
          <ToastBody
            heading="Success!"
            body={"Perk updated successfully."}
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

  const destroyPerk = async () => {
    const response = await destroy(
      `/api/v1/talent/${talentId}/perks/${perk.id}`
    );

    if (response) {
      // update local state
      removePerk(perk);

      closeModal();

      toast.success(
        <ToastBody
          heading="Success!"
          body={"Perk deleted successfully."}
          mode={mode}
        />,
        { autoClose: 1500 }
      );
    }
  };

  const debouncedUpdatePerk = debounce(() => updatePerk(), 400);

  const debouncedDestroyPerk = debounce(() => destroyPerk(), 400);

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
        <Modal.Title>Edit Perk</Modal.Title>
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
            title={`Amount ${talentToken.ticker || ""}`}
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
          onClick={() => debouncedDestroyPerk()}
          type="danger-outline"
          className="mr-auto cursor-pointer"
        >
          Delete Perk
        </ThemedButton>
        <ThemedButton
          onClick={() => closeModal()}
          type="white-ghost"
          className="mr-2"
        >
          Cancel
        </ThemedButton>
        <ThemedButton
          onClick={() => debouncedUpdatePerk()}
          type="primary-default"
          className="ml-2"
        >
          Save
        </ThemedButton>
      </Modal.Footer>
    </Modal>
  );
};

export default EditPerkModal;
