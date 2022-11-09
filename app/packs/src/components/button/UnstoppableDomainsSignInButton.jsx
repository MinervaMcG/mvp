import React from "react";
import Button from "src/components/design_system/button";

import Web3Modal from "web3modal";

import * as UAuthWeb3Modal from "@uauth/web3modal";
import UAuthSPA from "@uauth/js";

import cx from "classnames";

import UnstoppableDomainsLogo from "images/unstoppable-domains-logo.png";

import { toast } from "react-toastify";
import { ToastBody } from "src/components/design_system/toasts";

import { post } from "src/utils/requests";

const UnstoppableDomainsSignInButton = ({
  className,
  clientId,
  redirectUri,
}) => {
  const uauthOptions = {
    clientID: clientId,
    redirectUri: redirectUri,

    // Must include both the openid and wallet scopes.
    scope: "openid wallet email profile social:twitter",
  };

  const providerOptions = {
    // Currently the package isn't inside the web3modal library. For now,
    // users must use this libary to create a custom web3modal provider.

    // All custom `web3modal` providers must be registered using the "custom-"
    // prefix.
    "custom-uauth": {
      // The UI Assets
      display: UAuthWeb3Modal.display,

      // The Connector
      connector: UAuthWeb3Modal.connector,

      // The SPA libary
      package: UAuthSPA,

      // The SPA libary options
      options: uauthOptions,
    },
  };

  async function handleLogin() {
    const w3m = new Web3Modal({
      cacheProvider: true,
      disableInjectedProvider: true,
      providerOptions,
    });

    const web3Modal = await w3m.connect();
    UAuthWeb3Modal.registerWeb3Modal(web3Modal);

    const uAuth = UAuthWeb3Modal.getUAuth(UAuthSPA, uauthOptions);
    const auth = await uAuth.authorization();

    login(auth.idToken, w3m);
  }

  const login = (authData, web3Modal) => {
    post(`/auth/unstoppable_domains/login`, authData).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
      } else {
        toast.success(
          <ToastBody heading="Success" body={"Welcome to Talent Protocol!"} />
        );
        web3Modal.clearCachedProvider();
        window.location.href = `/u/${response.username}`;
      }
    });
  };

  return (
    <Button
      className={cx(
        className,
        "d-flex align-items-center justify-content-center"
      )}
      onClick={handleLogin}
      type="white-outline"
      size="extra-big"
      text="Sign in with Unstoppable"
      style={{ backgroundColor: "#0D67FE", color: "white", border: 0 }}
      Icon={<img className="mr-2" height={24} src={UnstoppableDomainsLogo} />}
    ></Button>
  );
};

export default UnstoppableDomainsSignInButton;
