import React, { useState } from "react";
import dayjs from "dayjs";

import { P2, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";
import TextArea from "../design_system/fields/textarea";

const Position = ({ changeStep, position, changePosition }) => {
  const [localPosition, setLocalPosition] = useState({
    ...position,
    start_date:
      position.start_date != ""
        ? dayjs(position.start_date).format("YYYY-MM")
        : "",
  });

  const submitPositionForm = (e) => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }

    changePosition(localPosition);
    changeStep(5);
  };

  const skipStep = (e) => {
    e.preventDefault();
    changeStep(5);
  };

  const invalidForm =
    localPosition.title == "" ||
    localPosition.institution == "" ||
    localPosition.description == "" ||
    localPosition.start_date == "";

  return (
    <>
      <H5 text="What’s your most recent position?" bold />
      <P2 className="mb-5 mt-2">
        Tell us what have you been doing lately. Later on you'll be able to add
        your education, career goals and past achievements.
      </P2>
      <form onSubmit={submitPositionForm} className="d-flex flex-column w-100">
        <div className="form-group position-relative">
          <label htmlFor="inputTitle" className="mt-2">
            <P2 className="text-black" text="Title" bold />
          </label>
          <TextInput
            id={"inputTitle"}
            type="text"
            onChange={(e) =>
              setLocalPosition((prev) => ({ ...prev, title: e.target.value }))
            }
            value={localPosition.title}
          />
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputinstitution" className="mt-2">
            <P2 className="text-black" text="Company" bold />
          </label>
          <TextInput
            id={"inputinstitution"}
            type="text"
            onChange={(e) =>
              setLocalPosition((prev) => ({
                ...prev,
                institution: e.target.value,
              }))
            }
            value={localPosition.institution}
          />
        </div>
        <div className="form-group position-relative">
          <TextArea
            title={"Description"}
            onChange={(e) =>
              setLocalPosition((prev) => ({
                ...prev,
                description: e.target.value,
              }))
            }
            value={localPosition.description}
            id="inputDescription"
            shortCaption="Describe what you did"
            maxLength="175"
            rows={3}
          />
        </div>
        <div className="form-group position-relative">
          <label htmlFor="inputlink" className="mt-2">
            <P2 className="text-black" text="URL" bold />
          </label>
          <TextInput
            id={"inputlink"}
            type="text"
            onChange={(e) =>
              setLocalPosition((prev) => ({ ...prev, link: e.target.value }))
            }
            value={localPosition.link}
          />
        </div>
        <div className="form-group position-relative">
          <label>
            <P2 className="text-black" bold>
              Start Date
            </P2>
          </label>
          <input
            className={"form-control"}
            placeholder={"Select date"}
            type="month"
            value={localPosition.start_date}
            onChange={(e) =>
              setLocalPosition((prev) => ({
                ...prev,
                start_date: e.target.value,
              }))
            }
          />
          <p className="short-caption">YYYY-MM</p>
        </div>
        <div className="d-flex flex-row justify-content-between mt-6">
          <button
            onClick={skipStep}
            className="btn btn-secondary talent-button primary-outline-button extra-big-size-button mt-6"
          >
            I'm a student
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

export default Position;
