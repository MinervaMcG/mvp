import React, { useState } from "react";

import { P2, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";
import Form from "react-bootstrap/Form";

import {
  nationalityOptions,
  ethnicityOptions,
  genderOptions,
} from "../talent/Edit/dropdownValues";

const Identity = ({
  changeStep,
  gender,
  changeGender,
  ethnicity,
  changeEthnicity,
  nationality,
  changeNationality,
}) => {
  const [localGender, setLocalGender] = useState(gender);
  const [localEthnicity, setLocalEthnicity] = useState(ethnicity);
  const [localNationality, setLocalNationality] = useState(nationality);

  const invalidForm =
    localGender == "" || localEthnicity == "" || localNationality == "";

  const skipStep = (e) => {
    e.preventDefault();

    changeStep(6);
  };

  const submitIdentityForm = (e) => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }

    changeGender(localGender);
    changeEthnicity(localEthnicity);
    changeNationality(localNationality);
    changeStep(6);
  };

  return (
    <>
      <H5 text="A few quick things about yourself" bold />
      <P2 className="mb-5 mt-2">
        A network is only as strong as its capacity of creating meaningful
        connections. We would love to know more about you to help you grow
        professionally.
      </P2>
      <form onSubmit={submitIdentityForm} className="d-flex flex-column w-100">
        <div className="form-group position-relative">
          <label htmlFor="inputFirstName" className="mt-2">
            <P2 className="text-black" text="Gender" bold />
          </label>
          <Form.Control
            as="select"
            onChange={(e) => setLocalGender(e.target.value)}
            value={localGender}
            className="height-auto"
          >
            <option value=""></option>
            {genderOptions.map((gender) => (
              <option value={gender} key={gender}>
                {gender}
              </option>
            ))}
          </Form.Control>
          <p className="short-caption">What gender do you identify as?</p>
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputFirstName" className="mt-2">
            <P2 className="text-black" text="Ethnicity" bold />
          </label>
          <Form.Control
            as="select"
            onChange={(e) => setLocalEthnicity(e.target.value)}
            value={localEthnicity}
            className="height-auto"
          >
            <option value=""></option>
            {ethnicityOptions.map((ethnicity) => (
              <option value={ethnicity} key={ethnicity}>
                {ethnicity}
              </option>
            ))}
          </Form.Control>
          <p className="short-caption">What ethnicity do you identify as?</p>
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputFirstName" className="mt-2">
            <P2 className="text-black" text="Nationality" bold />
          </label>
          <Form.Control
            as="select"
            onChange={(e) => setLocalNationality(e.target.value)}
            value={localNationality}
            className="height-auto"
          >
            <option value=""></option>
            {nationalityOptions.map((nationality) => (
              <option value={nationality} key={nationality}>
                {nationality}
              </option>
            ))}
          </Form.Control>
        </div>
        <div className="d-flex flex-row justify-content-between mt-6">
          <button
            onClick={skipStep}
            className="btn btn-secondary talent-button primary-outline-button extra-big-size-button mt-6"
          >
            Skip
          </button>
          <button
            type="submit"
            disabled={invalidForm}
            className="btn btn-primary talent-button primary-default-button extra-big-size-button mt-6"
          >
            Continue
          </button>
        </div>
      </form>
    </>
  );
};

export default Identity;
