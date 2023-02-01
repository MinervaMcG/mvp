import React, { useState } from "react";
import dayjs from "dayjs";
import cx from "classnames";

import Container from "../registration/RegistrationContainer";
import Welcome from "./Welcome";
import Occupation from "./Occupation";
import OpenTo from "./OpenTo";
import Position from "./Position";
import Identity from "./Identity";
import ProcessFlow from "./ProcessFlow";

import { useWindowDimensionsHook } from "../../utils/window";

const renderCurrentStep = currentStep => {
  window.scrollTo(0, 0);

  switch (currentStep) {
    case 1:
      return Welcome;
    case 2:
      return Occupation;
    case 3:
      return OpenTo;
    case 4:
      return Position;
    case 5:
      return Identity;
    case 6:
      return ProcessFlow;
    default:
      return Welcome;
  }
};

const OnboardingFlow = props => {
  const { width } = useWindowDimensionsHook();
  const mobile = width < 992;
  const nameComplete = !!props.user.legalFirstName && !!props.user.legalLastName;

  const [currentStep, setCurrentStep] = useState(nameComplete ? 2 : 1);
  const allSteps = nameComplete ? 4 : 5;

  const [localUsername, setUsername] = useState(props.user.username);

  const [localFirstName, setLocalFirstName] = useState(props.user.legalFirstName || "");
  const [localLastName, setLocalLastName] = useState(props.user.legalLastName || "");
  const [localOccupation, setLocalOccupation] = useState(props.talent.occupation || "");
  const [localExperienceLevel, setLocalExperienceLevel] = useState(props.talent.experienceLevel || 0);
  const [localCareerNeeds, setLocalCareerNeeds] = useState(props.talent.careerNeeds);
  const [localPosition, setLocalPosition] = useState(
    props.talent.lastPosition
      ? {
          ...props.talent.lastPosition,
          start_date: props.talent.lastPosition.start_date
            ? dayjs(props.talent.lastPosition.start_date).format("DD-MM-YYYY")
            : ""
        }
      : {
          title: "",
          institution: "",
          description: "",
          start_date: "",
          link: ""
        }
  );

  const [localGender, setLocalGender] = useState(props.talent.gender || "");
  const [localEthnicity, setLocalEthnicity] = useState(props.talent.ethnicity || "");
  const [localNationality, setLocalNationality] = useState(props.talent.nationality || "");

  const Component = renderCurrentStep(currentStep);

  return (
    <div
      className={cx(
        mobile
          ? "p-4 d-flex flex-column align-self-center justify-content-start w-100 h-100"
          : "justify-content-center registration-box"
      )}
    >
      <Component
        userId={props.user.id}
        firstName={localFirstName}
        lastName={localLastName}
        username={localUsername}
        changeFirstName={setLocalFirstName}
        changeLastName={setLocalLastName}
        changeUsername={setUsername}
        occupation={localOccupation}
        changeOccupation={setLocalOccupation}
        experienceLevel={localExperienceLevel}
        changeExperienceLevel={setLocalExperienceLevel}
        careerNeeds={localCareerNeeds}
        changeCareerNeeds={setLocalCareerNeeds}
        position={localPosition}
        changePosition={setLocalPosition}
        gender={localGender}
        changeGender={setLocalGender}
        ethnicity={localEthnicity}
        changeEthnicity={setLocalEthnicity}
        nationality={localNationality}
        changeNationality={setLocalNationality}
        changeStep={setCurrentStep}
        allSteps={allSteps}
      />
    </div>
  );
};

export default (props, railsContext) => {
  return () => (
    <Container {...props}>
      <OnboardingFlow {...props} railsContext={railsContext} />
    </Container>
  );
};
