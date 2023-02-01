import React from "react";
import { func, bool } from "prop-types";
import cx from "classnames";

const Slider = ({ onChange, checked, className }) => {
  return (
    <label className={cx("form-switch", className)}>
      <input type="checkbox" checked={checked} onChange={onChange} />
      <i />
    </label>
  );
};

Slider.defaultProps = {
  checked: false
};

Slider.propTypes = {
  onChange: func.isRequired,
  checked: bool
};

export default Slider;
