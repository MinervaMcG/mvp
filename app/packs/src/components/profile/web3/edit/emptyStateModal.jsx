import React from "react";
import Modal from "react-bootstrap/Modal";
import ThemedButton from "src/components/design_system/button";
import { P1 } from "src/components/design_system/typography";

const EmptyStateModal = ({
  emptyStateHeader,
  emptyStateClickAction,
  emptyStateActionTitle,
  emptyStateMessage,
  closeModal,
}) => (
  <>
    <Modal.Header className="py-3 px-4 modal-border" closeButton>
      <Modal.Title>{emptyStateHeader}</Modal.Title>
    </Modal.Header>
    <Modal.Body className="show-grid p-5">
      <div className="d-flex flex-column justify-content-between align-items-center">
        <P1 text={emptyStateMessage} className="text-primary-01 mb-5" />
        <ThemedButton
          onClick={() => emptyStateClickAction()}
          type="primary-default"
          className="mx-auto"
        >
          {emptyStateActionTitle}
        </ThemedButton>
      </div>
    </Modal.Body>
    <Modal.Footer>
      <a onClick={() => closeModal()} className="mr-3">
        Cancel
      </a>
    </Modal.Footer>
  </>
);

export default EmptyStateModal;
