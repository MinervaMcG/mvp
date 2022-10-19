import React, { useState } from "react";

import { P2, H5 } from "../design_system/typography";
import Link from "src/components/design_system/link";
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
  allSteps,
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

  const goBack = (e) => {
    e.preventDefault();

    changeStep(4);
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
    <div className="registration-items">
      <div className="d-flex flex-row justify-content-between mb-4">
        <P2 medium>
          Step {allSteps === 4 ? 4 : 5}
          <span className="text-primary-04">/{allSteps}</span>
        </P2>
        <Link onClick={skipStep}>
          <P2 className="" bold text={"Skip"} />
        </Link>
      </div>
      <H5 text="A few quick things about yourself" bold />
      <P2 className="mb-5 mt-2">
        Talent Protocol is committed to building a diverse community. These next
        questions help us stay accountable to this goal. Your responses won't be
        made public. Your response will only be used by Talent Protocol to gain
        an understanding of the aggregate diversity of our talent pool.
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
            onClick={goBack}
            className="btn btn-secondary talent-button primary-outline-button big-size-button mb-4"
          >
            Back
          </button>
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

export default Identity;
