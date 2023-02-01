import React, { useState } from "react";
import TextInput from "src/components/design_system/fields/textinput";
import RegistrationContainer from "src/components/registration/RegistrationContainer";
import Link from "src/components/design_system/link";
import UnstoppableDomainsSignInButton from "src/components/button/UnstoppableDomainsSignInButton";
import LinkedinSignInButton from "src/components/button/LinkedinSignInButton";
import { useTheme } from "src/contexts/ThemeContext";
import { useWindowDimensionsHook } from "src/utils/window";
import { H5, P2, P3 } from "src/components/design_system/typography";
import { USER_GUIDE } from "src/utils/constants";
import { post } from "src/utils/requests";

import cx from "classnames";

const Login = props => {
  const { linkedinClientId, linkedinRedirectUri, unstoppableDomainsClientId, unstoppableDomainsRedirectUri } = props;

  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState({ email: false, password: false });

  const submitLoginForm = e => {
    e.preventDefault();
    setErrors({ email: false, password: false });

    post("/session", { session: { email, password } }).then(res => {
      if (res.error) {
        setErrors(prev => ({ ...prev, email: true, password: true }));
      } else {
        window.location.replace("/");
      }
    });
  };

  return (
    <div
      className={cx(
        "d-flex flex-column",
        mobile ? "p-4 justify-content-between align-self-center w-100 h-100" : "p-0 registration-box w-100"
      )}
    >
      <div>
        <H5 className="mb-6" text="Login" bold />
        <form onSubmit={submitLoginForm} className="d-flex flex-column w-100">
          <label htmlFor="inputEmail">
            <P2 className="text-black" text="Email Address" bold />
          </label>
          <TextInput
            mode={mode()}
            type="email"
            id="inputEmail"
            ariaDescribedBy="emailHelp"
            value={email}
            onChange={e => setEmail(e.target.value)}
          />
          <div className="d-flex justify-content-between mt-4">
            <label htmlFor="inputPassword">
              <P2 className="text-black" text="Password" bold />
            </label>
            <Link text="Forgot Password?" href="/passwords/new" bold />
          </div>
          <TextInput
            mode={mode()}
            type="password"
            id="inputPassword"
            ariaDescribedBy="passwordHelp"
            value={password}
            onChange={e => setPassword(e.target.value)}
          />
          {errors["password"] && <P3 className="mt-2 text-danger" text="Wrong password or email" />}
          <button
            type="submit"
            className="btn btn-primary talent-button primary-default-button extra-big-size-button bold w-100 mt-6"
          >
            Login
          </button>
        </form>
      </div>
      <LinkedinSignInButton className="mt-3" clientId={linkedinClientId} redirectUri={linkedinRedirectUri} />
      <UnstoppableDomainsSignInButton
        className="mt-3"
        clientId={unstoppableDomainsClientId}
        redirectUri={unstoppableDomainsRedirectUri}
      />
      <div className={cx("mt-6 pb-4", mobile && "align-self-center")}>
        <div className="d-flex mb-2">
          <P2 className="text-black mr-1" text="Don't have an account yet?" />
          <Link bold href="/join" text="Sign up here" />
        </div>
        <div className="d-flex">
          <P2 className="text-black mr-1" text="Want more info?" />
          <Link bold href={USER_GUIDE} target="_blank" text="Check our user guide" />
        </div>
      </div>
    </div>
  );
};

// eslint-disable-next-line no-unused-vars
export default (props, _railsContext) => {
  return () => (
    <RegistrationContainer {...props}>
      <Login {...props} />
    </RegistrationContainer>
  );
};
