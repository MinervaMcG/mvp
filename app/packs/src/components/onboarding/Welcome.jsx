import React, { useState } from "react";

import { P2, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";

const Welcome = ({
  changeStep,
  firstName,
  changeFirstName,
  lastName,
  changeLastName,
  allSteps,
}) => {
  const [localFirstName, setLocalFirstName] = useState(firstName);
  const [localLastName, setLocalLastName] = useState(lastName);

  const submitWelcomeForm = (e) => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }

    changeFirstName(localFirstName);
    changeLastName(localLastName);
    changeStep(2);
  };

  const invalidForm = localFirstName == "" || localLastName == "";

  return (
    <div className="registration-items">
      <div className="d-flex flex-row justify-content-between mb-4">
        <P2 medium>
          Step 1<span className="text-primary-04">/{allSteps}</span>
        </P2>
      </div>
      <H5 text={`Welcome back!`} bold />
      <P2 className="mb-5 mt-2">
        A lot has changed since you last saw us! Take advantage of this quick
        onboarding to make sure relevant information is up to date and that new
        information is filled in. Let's get started!
      </P2>
      <form onSubmit={submitWelcomeForm} className="d-flex flex-column w-100">
        <div className="form-group position-relative">
          <label htmlFor="inputFirstName" className="mt-2">
            <P2 className="text-black" text="First Name" bold />
          </label>
          <TextInput
            type="text"
            id="inputFirstName"
            value={localFirstName}
            onChange={(e) => setLocalFirstName(e.target.value)}
          />
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputLastName" className="mt-2">
            <P2 className="text-black" text="Last Name" bold />
          </label>
          <TextInput
            type="text"
            id="inputLastName"
            value={localLastName}
            onChange={(e) => setLocalLastName(e.target.value)}
          />
        </div>
        <div className="d-flex flex-row justify-content-end mt-6">
          <button
            type="submit"
            disabled={invalidForm}
            className="btn btn-primary talent-button primary-default-button big-size-button mb-4"
          >
            Continue
          </button>
        </div>
      </form>
    </div>
  );
};

export default Welcome;
