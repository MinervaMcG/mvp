import React, { useState } from "react";
import { useWindowDimensionsHook } from "../../../utils/window";
import Modal from "react-bootstrap/Modal";
import { P1 } from "src/components/design_system/typography";
import TextInput from "src/components/design_system/fields/textinput";

const ChangeStakeWalletModal = ({
  show,
  setShow,
  handleStakeChange,
  loadingStakeChange,
}) => {
  const { width } = useWindowDimensionsHook();
  const mobile = width < 992;

  const [newOwnerWallet, setNewOwnerWallet] = useState("");

  return (
    <Modal
      scrollable={true}
      show={show}
      centered={mobile ? false : true}
      onHide={() => setShow(false)}
      dialogClassName={
        mobile ? "mw-100 mh-100 m-0" : "remove-background rewards-modal"
      }
      fullscreen={"md-down"}
    >
      <>
        <Modal.Header closeButton className="pt-4 px-4 pb-0">
          {mobile && (
            <button
              onClick={() => setShow(false)}
              className="text-black remove-background remove-border mr-3"
            >
              <ArrowLeft color="currentColor" />
            </button>
          )}
          <P1 className="text-black" text="Change Stake Wallet" bold />
        </Modal.Header>
        <Modal.Body className="show-grid px-4 pb-4 d-flex flex-column justify-content-between">
          <TextInput
            placeholder="New Owner Address"
            inputClassName="pl-5"
            className="w-100"
            onChange={(e) => setNewOwnerWallet(e.target.value)}
          />
          <button
            onClick={() => handleStakeChange(newOwnerWallet)}
            disabled={loadingStakeChange}
            className="btn btn-primary talent-button primary-default-button bold extra-big-size-button w-100 mt-6"
          >
            Continue
          </button>
        </Modal.Body>
      </>
    </Modal>
  );
};

export default ChangeStakeWalletModal;
