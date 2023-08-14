import React from "react";
import { Button } from "@talentprotocol/design-system";
import { ActionArea, RightActionZone } from "./styled";

export const CreateAccountFooter = ({ previousStep, openCaptchaModal, isNextDisabled }) => (
  <ActionArea>
    <RightActionZone>
      <Button size="medium" hierarchy="tertiary" text="Back" onClick={previousStep} />
      <Button size="medium" hierarchy="primary" text="Next" onClick={openCaptchaModal} isDisabled={isNextDisabled} />
    </RightActionZone>
  </ActionArea>
);
