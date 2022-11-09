import React from "react";
import { number, string, arrayOf, bool, func } from "prop-types";
import Tag from "src/components/design_system/tag";
import P2 from "src/components/design_system/typography/p2";

import cx from "classnames";

const TagsWithIndex = ({
  tags,
  className,
  tagsIndexSelected,
  clickable,
  onClick,
}) => {
  if (tags && tags.length > 0) {
    return (
      <div
        className={`d-flex flex-row flex-wrap align-items-center ${
          className || ""
        }`}
      >
        {tags.map((tag, index) => (
          <Tag
            className={cx(
              "mr-2 mt-2",
              tagsIndexSelected?.includes(index) ? "tag-selected" : ""
            )}
            key={`${tag}_${index}`}
          >
            {onClick ? (
              <button className="button-link" onClick={() => onClick(index)}>
                <P2
                  className={cx(
                    tagsIndexSelected?.includes(index)
                      ? "bg-01"
                      : "text-primary-01"
                  )}
                  text={tag}
                  medium
                  role="button"
                />
              </button>
            ) : (
              <a
                href={clickable ? `/talent?keyword=${tag}` : null}
                className="text-decoration-none"
              >
                <P2
                  className="text-primary-01"
                  text={tag}
                  medium
                  role="button"
                />
              </a>
            )}
          </Tag>
        ))}
      </div>
    );
  } else {
    return null;
  }
};

TagsWithIndex.defaultProps = {
  tags: [],
  className: string,
  tagsIndexSelected: [],
  clickable: true,
  onClick: null,
};

TagsWithIndex.propTypes = {
  tags: arrayOf(string),
  className: string,
  tagsIndexSelected: arrayOf(number),
  clickable: bool,
  onClick: func,
};

export default TagsWithIndex;
