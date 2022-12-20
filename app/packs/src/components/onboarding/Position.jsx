import React, { useEffect, useState } from "react";
import dayjs from "dayjs";
import customParseFormat from "dayjs/plugin/customParseFormat";
import Form from "react-bootstrap/Form";

import { P2, H5 } from "../design_system/typography";
import TextInput from "../design_system/fields/textinput";
import TextArea from "../design_system/fields/textarea";
import Link from "src/components/design_system/link";

dayjs.extend(customParseFormat);

const returnYear = (date) => {
  if (date) {
    return dayjs(date).format("YYYY");
  } else {
    return "";
  }
};

const returnMonth = (date) => {
  if (date) {
    return dayjs(date).format("MMMM");
  } else {
    return "";
  }
};

const Position = ({ changeStep, position, changePosition, allSteps }) => {
  const [localPosition, setLocalPosition] = useState({ ...position });
  const [localMonth, setLocalMonth] = useState(
    returnMonth(position.start_date)
  );
  const [localYear, setLocalYear] = useState(returnYear(position.start_date));

  const submitPositionForm = (e) => {
    e.preventDefault();
    if (invalidForm) {
      return;
    }
    changePosition(localPosition);
    changeStep(5);
  };

  const goBack = (e) => {
    e.preventDefault();
    changeStep(3);
  };

  const skipStep = (e) => {
    e.preventDefault();
    changeStep(5);
  };

  const invalidForm =
    localPosition.title == "" ||
    localPosition.institution == "" ||
    localPosition.description == "" ||
    localPosition.start_date == "" ||
    localMonth == "" ||
    localYear == "";

  const monthOptions = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  const yearOptions = (() => {
    const max = new Date().getFullYear();
    const min = 1970;

    const years = [];
    for (let i = max; i >= min; i--) {
      years.push(i);
    }
    return years;
  })();

  useEffect(() => {
    if (localYear != "" && localMonth != "") {
      setLocalPosition((prev) => ({
        ...prev,
        start_date: dayjs(`${localMonth}/${localYear}`, "MMMM/YYYY").format(
          "DD-MM-YYYY"
        ),
      }));
    }
  }, [localYear, localMonth]);

  return (
    <div className="registration-items">
      <div className="d-flex flex-row justify-content-between mb-4">
        <P2 medium>
          Step {allSteps === 4 ? 3 : 4}
          <span className="text-primary-04">/{allSteps}</span>
        </P2>
        <Link onClick={skipStep}>
          <P2 className="" bold text={"Skip"} />
        </Link>
      </div>
      <H5 text="What’s your main position?" bold />
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
          <label htmlFor="inputMonth" className="mt-2">
            <P2 className="text-black" text="Select date" bold />
          </label>
          <div className="d-flex flex-row justify-content-between">
            <Form.Control
              as="select"
              onChange={(e) => setLocalMonth(e.target.value)}
              value={localMonth}
              placeholder="Month"
              className="height-auto mr-2"
            >
              <option value=""></option>
              {monthOptions.map((month) => (
                <option value={month} key={month}>
                  {month}
                </option>
              ))}
            </Form.Control>
            <Form.Control
              as="select"
              onChange={(e) => setLocalYear(e.target.value)}
              value={localYear}
              placeholder="Year"
              className="height-auto ml-2"
            >
              <option value=""></option>
              {yearOptions.map((year) => (
                <option value={year} key={year}>
                  {year}
                </option>
              ))}
            </Form.Control>
          </div>
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

export default Position;
