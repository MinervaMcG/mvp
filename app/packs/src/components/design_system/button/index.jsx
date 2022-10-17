import React from "react";
import { string, func, oneOf, bool, object } from "prop-types";
import cx from "classnames";

const Button = ({
  text,
  onClick,
  type,
  mode,
  size,
  disabled,
  className,
  children,
  Icon,
  style,
}) => {
  const typeClassName = `${type}-button`;

  return (
    <button
      className={cx(
        "talent-button",
        typeClassName,
        mode,
        `${size}-size-button`,
        className
      )}
      style={style}
      onClick={onClick}
      disabled={disabled}
    >
      {Icon}
      {text ? text : children}
    </button>
  );
};

Button.defaultProps = {
  text: null,
  mode: "light",
  size: "normal",
  className: "",
  disabled: false,
  type: "",
  style: {},
};

Button.propTypes = {
  text: string,
  onClick: func.isRequired,
  type: oneOf([
    "",
    "primary-default",
    "primary-outline",
    "primary-ghost",
    "primary-subtle",
    "danger-default",
    "danger-outline",
    "danger-ghost",
    "danger-subtle",
    "positive-default",
    "positive-outline",
    "positive-ghost",
    "positive-subtle",
    "white-default",
    "white-outline",
    "white-ghost",
    "white-subtle",
    "dark-mode-static-white-default",
  ]),
  mode: oneOf(["light", "dark"]),
  size: oneOf(["none", "icon", "normal", "big", "extra-big"]),
  className: string,
  disabled: bool,
  style: object,
};

export default Button;
