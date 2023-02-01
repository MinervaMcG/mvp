import React, { useState } from "react";
import Welcome from "./Welcome";
import ProcessFlow from "./ProcessFlow";
import RegisterFirstAndLastName from "./RegisterFirstAndLastName";
import RegisterEmail from "./RegisterEmail";
import RegistrationContainer from "./RegistrationContainer";
import { useTheme } from "../../contexts/ThemeContext";
import { useWindowDimensionsHook } from "../../utils/window";
import cx from "classnames";

const renderCurrentStep = currentStep => {
  switch (currentStep) {
    case 1:
      return Welcome;
    case 2:
      return RegisterFirstAndLastName;
    case 3:
      return RegisterEmail;
    case 4:
      return ProcessFlow;
    default:
      return Welcome;
  }
};

const RegistrationFlow = props => {
  const { width } = useWindowDimensionsHook();
  const mobile = width < 992;
  const { mode } = useTheme();
  const url = new URL(document.location);

  const [currentStep, setCurrentSet] = useState(props.step ? props.step : 1);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [username, setUsername] = useState(url.searchParams.get("handle") || "");
  const [code, setCode] = useState("");
  const [captcha, setCaptcha] = useState("");

  const Component = renderCurrentStep(currentStep);

  return (
    <div
      className={cx(
        "d-flex flex-column",
        mobile ? "align-self-center p-4 justify-content-start w-100 h-100" : "p-0 registration-box w-100",
        currentStep === 4 && "justify-content-center"
      )}
    >
      <Component
        changeStep={setCurrentSet}
        changeEmail={setEmail}
        changePassword={setPassword}
        email={email}
        password={password}
        username={username}
        changeUsername={setUsername}
        code={code}
        changeCode={setCode}
        captcha={captcha}
        setCaptcha={setCaptcha}
        captchaKey={props.captchaKey}
        themePreference={mode()}
        changeFirstName={setFirstName}
        changeLastName={setLastName}
        firstName={firstName}
        lastName={lastName}
        {...props}
      />
    </div>
  );
};

export default (props, railsContext) => {
  return () => (
    <RegistrationContainer {...props}>
      <RegistrationFlow {...props} railsContext={railsContext} />
    </RegistrationContainer>
  );
};
