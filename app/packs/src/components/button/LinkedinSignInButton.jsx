import React from "react";
import Linkedin from "images/linkedin.png";
import Button from "src/components/design_system/button";

import cx from "classnames";

const LinkedinSignInButton = ({ className, clientId, redirectUri }) => {
  const baseAuthorizationUri = "https://www.linkedin.com/oauth/v2/authorization";
  const scope = "r_liteprofile%20r_emailaddress";

  const onClick = () => {
    window.location.href = `${baseAuthorizationUri}?response_type=code&client_id=${clientId}&redirect_uri=${redirectUri}&scope=${scope}`;
  };

  return (
    <Button
      className={cx(className, "d-flex align-items-center justify-content-center")}
      onClick={onClick}
      type="white-outline"
      size="extra-big"
      text="Sign in with LinkedIn"
      Icon={<img className="mr-2" height={16} src={Linkedin} />}
    ></Button>
  );
};

export default LinkedinSignInButton;
