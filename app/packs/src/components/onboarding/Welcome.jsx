import React, { useState } from "react";

import { P2, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";

const Welcome = ({
  changeStep,
  firstName,
  changeFirstName,
  lastName,
  changeLastName,
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
    <>
      <H5 text="Welcome back!" bold />
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
        <button
          type="submit"
          disabled={invalidForm}
          className="btn btn-primary talent-button primary-default-button extra-big-size-button w-100 mt-6"
        >
          Continue
        </button>
      </form>
    </>
  );
};

export default Welcome;
