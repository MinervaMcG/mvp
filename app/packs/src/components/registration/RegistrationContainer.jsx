import React from "react";
import { useWindowDimensionsHook } from "../../utils/window";
import ThemeContainer, { useTheme } from "../../contexts/ThemeContext";
import RegistrationStaticScreen from "./RegistrationStaticScreen";
import Button from "../design_system/button";
import { Sun, Moon, LogoWord } from "../icons";
import { darkPrimary } from "src/utils/colors";
import cx from "classnames";

const RegistrationContainer = ({ children }) => {
  const { mobile } = useWindowDimensionsHook();
  const { theme, simpleToggleTheme, mode } = useTheme();

  return (
    <div className="h-100">
      {!mobile && (
        <>
          <Button
            size="icon"
            type="white-ghost"
            mode={mode()}
            onClick={simpleToggleTheme}
            className="registration-theme z-index-1 text-black"
          >
            {theme === "light-body" ? <Moon color="currentColor" /> : <Sun color="currentColor" />}
          </Button>
        </>
      )}
      {mobile && (
        <div className="registration-mobile-menu position-fixed z-index-1 text-black w-100">
          <div className="d-flex justify-content-between px-4 pt-4 pb-2">
            <LogoWord logoFill={darkPrimary} textFill="currentColor" viewBox="0 0 250 20" />
            {theme === "light-body" && (
              <Button size="icon" type="white-ghost" mode={mode()} onClick={simpleToggleTheme} className="text-black">
                <Moon color="currentColor" />
              </Button>
            )}
            {theme === "dark-body" && (
              <Button size="icon" type="white-ghost" mode={mode()} onClick={simpleToggleTheme} className="text-black">
                <Sun color="currentColor" />
              </Button>
            )}
          </div>
          {/* <div className="url-verification-container">
            <Padlock size={16} color={darkPositive} />
            <P3 className="text-black mx-1" text="URL Verification:" bold />
            <P3 className="text-green-500" text="https://" />
            <P3 className="text-black" text="beta.talentprotocol.com" />
          </div> */}
        </div>
      )}
      <div className={cx("d-flex w-100 h-100 p-0", mobile && "registration-mobile")}>
        <RegistrationStaticScreen />
        {children}
      </div>
    </div>
  );
};

// eslint-disable-next-line no-unused-vars
export default (props, _railsContext) => (
  <ThemeContainer {...props}>
    <RegistrationContainer {...props} />
  </ThemeContainer>
);
