import React from "react";
import { string, number, bool, oneOfType, oneOf, node, object } from "prop-types";
import cx from "classnames";

const P2 = ({ bold, medium, mode, text, children, className, style }) => {
  return (
    <p className={cx("p2", bold ? "bold" : "", medium ? "medium" : "", mode, className)} style={style}>
      {text || children}
    </p>
  );
};

P2.defaultProps = {
  bold: false,
  medium: false,
  mode: "light",
  className: "",
  style: {},
  children: null
};

P2.propTypes = {
  bold: bool,
  medium: bool,
  mode: oneOf(["light", "dark"]),
  text: oneOfType([string, number]),
  children: node,
  className: string,
  style: object
};

export default P2;
