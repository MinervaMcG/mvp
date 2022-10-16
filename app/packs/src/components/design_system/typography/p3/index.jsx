import React from "react";
import { string, number, bool, oneOfType, oneOf, node } from "prop-types";
import cx from "classnames";

const P3 = ({ bold, mode, text, medium, children, className }) => {
  return (
    <p
      className={cx(
        "p3",
        bold ? "bold" : "",
        medium ? "medium" : "",
        mode,
        className
      )}
    >
      {text || children}
    </p>
  );
};

P3.defaultProps = {
  bold: false,
  medium: false,
  mode: "light",
  className: "",
  text: "",
  children: null,
};

P3.propTypes = {
  bold: bool,
  medium: bool,
  mode: oneOf(["light", "dark"]),
  text: oneOfType([string, number]),
  children: node,
  className: string,
};

export default P3;
