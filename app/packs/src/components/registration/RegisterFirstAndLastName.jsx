import React, { useState } from "react";
import { P2, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";

const RegisterFirstAndLastName = ({ themePreference, changeFirstName, changeLastName, changeStep }) => {
  const [localFirstName, setLocalFirstName] = useState("");
  const [localLastName, setLocalLastName] = useState("");

  const invalidForm = localFirstName.length == 0 || localLastName.length == 0;

  const submitRegisterNameForm = e => {
    e.preventDefault();
    if (localFirstName != "" && localLastName != "") {
      changeFirstName(localFirstName);
      changeLastName(localLastName);
      changeStep(3);
    }
  };

  return (
    <div className="registration-items">
      <H5 text="What is your legal name?" bold />
      <P2 className="mb-5 mt-2">
        At Talent Protocol we're building the professional network for high-potential builders. Tell us who you are.
      </P2>
      <form onSubmit={submitRegisterNameForm} className="d-flex flex-column w-100">
        <div className="form-group position-relative">
          <label htmlFor="inputFirstName" className="mt-2">
            <P2 className="text-black" text="First Name" bold />
          </label>
          <TextInput
            mode={themePreference}
            type="text"
            id="inputFirstName"
            value={localFirstName}
            onChange={e => setLocalFirstName(e.target.value)}
          />
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputLastName" className="mt-2">
            <P2 className="text-black" text="Last Name" bold />
          </label>
          <TextInput
            mode={themePreference}
            type="text"
            id="inputLastName"
            value={localLastName}
            onChange={e => setLocalLastName(e.target.value)}
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
    </div>
  );
};

export default RegisterFirstAndLastName;
