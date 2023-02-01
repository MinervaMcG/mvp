import React from "react";

import Tag from "src/components/design_system/tag";
import { P2, P3 } from "src/components/design_system/typography";

import cx from "classnames";

const TextInput = ({
  title,
  shortCaption,
  placeholder,
  disabled,
  value,
  onChange,
  onBlur,
  className,
  inputClassName,
  maxLength,
  required,
  tag,
  error,
  id,
  ariaDescribedBy,
  topCaption,
  type = "text",
  maxLengthText = false
}) => {
  return (
    <div className={cx("d-flex flex-column", className)}>
      <div className="d-flex flex-row justify-content-between align-items-end">
        {title ? (
          <P2
            bold
            className="text-primary-01 mb-2 d-flex flex-row justify-content-center align-items-center"
          >
            {title} {required && <span className="text-danger">*</span>}
            {tag && (
              <Tag className="tag-available ml-2" size="small">
                <P3 className="text-primary-01" bold text={tag} />
              </Tag>
            )}
          </P2>
        ) : null}
        {maxLengthText ? <P2 className="mb-2" text={`${value.length}/${maxLength}`} /> : null}
        {topCaption ? <P3 className="mb-2" text={topCaption} /> : null}
      </div>

      <input
        id={id}
        type={type}
        className={cx("form-control", inputClassName, error && "border-danger")}
        aria-describedby={ariaDescribedBy}
        placeholder={placeholder}
        disabled={disabled}
        value={value}
        onChange={onChange}
        onBlur={onBlur}
        maxLength={maxLength}
      />

      {shortCaption ? <p className="short-caption">{shortCaption}</p> : null}
    </div>
  );
};

export default TextInput;
