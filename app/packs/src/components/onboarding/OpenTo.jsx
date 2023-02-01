import React, { useState } from "react";
import { CAREER_NEEDS_OPTIONS } from "src/utils/constants";

import { P2, H5 } from "../design_system/typography";
import Checkbox from "../design_system/checkbox";

const OpenTo = ({ changeStep, careerNeeds, changeCareerNeeds, allSteps }) => {
  const [selectedCareerNeeds, setSelectedCareerNeeds] = useState(careerNeeds);

  const invalidForm = selectedCareerNeeds.length === 0;

  const submitOpenToForm = e => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }

    changeCareerNeeds(selectedCareerNeeds);
    changeStep(4);
  };

  const goBack = e => {
    e.preventDefault();
    changeStep(2);
  };

  const toogleCareerNeedOption = field => {
    if (selectedCareerNeeds.includes(field)) {
      const newCareerNeeds = selectedCareerNeeds.filter(item => item != field);
      setSelectedCareerNeeds(newCareerNeeds);
    } else {
      setSelectedCareerNeeds(prev => [...prev, field]);
    }
  };

  const availableForOptions = CAREER_NEEDS_OPTIONS.slice(0, 5);
  const interestedInOptions = CAREER_NEEDS_OPTIONS.slice(5, 10);
  const canHelpWithOptions = CAREER_NEEDS_OPTIONS.slice(10, 13);

  return (
    <div className="registration-items">
      <div className="d-flex flex-row justify-content-between mb-4">
        <P2 medium>
          Step {allSteps === 4 ? 2 : 3}
          <span className="text-primary-04">/{allSteps}</span>
        </P2>
      </div>
      <H5 text="How can the Talent Protocol community help you?" bold />
      <P2 className="mt-2 mb-4">
        There is a lot we can help you with. Choose the priority categories that are key for you to thrive
        professionally.
      </P2>
      <form onSubmit={submitOpenToForm} className="d-flex flex-column w-100">
        <P2 bold className="mb-2">
          I'm available for:
        </P2>
        {availableForOptions.map(item => (
          <Checkbox
            key={item}
            className="form-check-input mt-4"
            checked={selectedCareerNeeds.includes(item)}
            onChange={() => toogleCareerNeedOption(item)}
          >
            <div className="d-flex flex-wrap">
              <P2 className="ml-1" text={item} />
            </div>
          </Checkbox>
        ))}
        <P2 bold className="mb-2 mt-4">
          I'm interested in:
        </P2>
        {interestedInOptions.map(item => (
          <Checkbox
            key={item}
            className="form-check-input mt-4"
            checked={selectedCareerNeeds.includes(item)}
            onChange={() => toogleCareerNeedOption(item)}
          >
            <div className="d-flex flex-wrap">
              <P2 className="ml-1" text={item} />
            </div>
          </Checkbox>
        ))}
        <P2 bold className="mb-2 mt-4">
          I can help with:
        </P2>
        {canHelpWithOptions.map(item => (
          <Checkbox
            key={item}
            className="form-check-input mt-4"
            checked={selectedCareerNeeds.includes(item)}
            onChange={() => toogleCareerNeedOption(item)}
          >
            <div className="d-flex flex-wrap">
              <P2 className="ml-1" text={item} />
            </div>
          </Checkbox>
        ))}
        <div className="d-flex flex-row justify-content-end mt-6">
          <button
            onClick={goBack}
            className="btn btn-secondary talent-button primary-outline-button big-size-button mb-4 mr-2"
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

export default OpenTo;
