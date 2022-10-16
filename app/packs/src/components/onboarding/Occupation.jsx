import React, { useState } from "react";
import { P2, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";
import Form from "react-bootstrap/Form";

const Occupation = ({
  changeStep,
  occupation,
  changeOccupation,
  experienceLevel,
  changeExperienceLevel,
}) => {
  const [localOccupation, setLocalOccupation] = useState(occupation);
  const [localExperienceLevel, setLocalExperienceLevel] =
    useState(experienceLevel);

  const invalidForm = localOccupation == "" || localExperienceLevel === 0;

  const submitOccupationForm = (e) => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }

    changeOccupation(localOccupation);
    changeExperienceLevel(localExperienceLevel);
    changeStep(3);
  };

  return (
    <>
      <H5 text="What do you do?" bold />
      <P2 className="mt-2">
        Talent Protocol is a community for builders: those who are passionate,
        entrepreneurial, tech-savvy and curious.
      </P2>
      <P2 className="mb-5 mt-2">
        Tell us which type of builder would best fit you (ex:{" "}
        <strong>
          operator, writer, founder, marketer, designer, developer, builder, etc
        </strong>
        ).
      </P2>
      <form
        onSubmit={submitOccupationForm}
        className="d-flex flex-column w-100"
      >
        <div className="form-group position-relative">
          <label htmlFor="inputOccupation" className="mt-2">
            <P2 className="text-black" text="Occupation" bold />
          </label>
          <TextInput
            type="text"
            id="inputOccupation"
            value={localOccupation}
            onChange={(e) => setLocalOccupation(e.target.value)}
          />
        </div>
        <div className="d-flex flex-column">
          <P2 className="text-black mb-3" text="Experience Level" bold />
          <Form.Check
            type={"radio"}
            id={"entry-radio"}
            name="experience-radio-group"
            label={"Entry Level (New Grad)"}
            onClick={() => setLocalExperienceLevel(1)}
            defaultChecked={localExperienceLevel === 1}
            className="mb-2"
          />
          <Form.Check
            type={"radio"}
            id={"junior-radio"}
            name="experience-radio-group"
            label={"Junior (1-2 years)"}
            onClick={() => setLocalExperienceLevel(2)}
            defaultChecked={localExperienceLevel === 2}
            className="mb-2"
          />
          <Form.Check
            type={"radio"}
            id={"mid-radio"}
            name="experience-radio-group"
            label={"Mid-level (3-4 years)"}
            onClick={() => setLocalExperienceLevel(3)}
            defaultChecked={localExperienceLevel === 3}
            className="mb-2"
          />
          <Form.Check
            type={"radio"}
            id={"senior-radio"}
            name="experience-radio-group"
            label={"Senior (5-8 years)"}
            onClick={() => setLocalExperienceLevel(4)}
            defaultChecked={localExperienceLevel === 4}
            className="mb-2"
          />
          <Form.Check
            type={"radio"}
            id={"expert-radio"}
            name="experience-radio-group"
            label={"Expert & Leadership (9+ years)"}
            defaultChecked={localExperienceLevel === 5}
            onClick={() => setLocalExperienceLevel(5)}
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

export default Occupation;
