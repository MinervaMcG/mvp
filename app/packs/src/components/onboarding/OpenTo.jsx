import React, { useState } from "react";
import { CAREER_NEEDS_OPTIONS } from "src/utils/constants";

import { P2, H5 } from "../design_system/typography";
import Checkbox from "../design_system/checkbox";

const OpenTo = ({ changeStep, careerNeeds, changeCareerNeeds }) => {
  const [selectedCareerNeeds, setSelectedCareerNeeds] = useState(careerNeeds);

  const invalidForm = selectedCareerNeeds.length === 0;

  const submitOpenToForm = (e) => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }

    changeCareerNeeds(selectedCareerNeeds);
    changeStep(4);
  };

  const toogleCareerNeedOption = (field) => {
    if (selectedCareerNeeds.includes(field)) {
      const newCareerNeeds = selectedCareerNeeds.filter(
        (item) => item != field
      );
      setSelectedCareerNeeds(newCareerNeeds);
    } else {
      setSelectedCareerNeeds((prev) => [...prev, field]);
    }
  };

  const availableForOptions = CAREER_NEEDS_OPTIONS.slice(0, 5);
  const interestedInOptions = CAREER_NEEDS_OPTIONS.slice(5, 10);
  const canHelpWithOptions = CAREER_NEEDS_OPTIONS.slice(10, 13);

  return (
    <>
      <H5 text="How can the Talent Protocol community help you?" bold />
      <P2 className="mt-2">
        There is a lot we can help you with. Choose the priority categories that
        are key for you to thrive professionally.
      </P2>
      <P2 className="mb-5 mt-2">
        What do you need to take your career to the next level? You can always
        change this later. Talent Protocol also gives you access to an
        Opportunities Board where you can find what you are looking for or… be
        found!
      </P2>
      <form onSubmit={submitOpenToForm} className="d-flex flex-column w-100">
        <P2 bold className="mb-2">
          I'm available for:
        </P2>
        {availableForOptions.map((item) => (
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
        {interestedInOptions.map((item) => (
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
        {canHelpWithOptions.map((item) => (
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

export default OpenTo;
