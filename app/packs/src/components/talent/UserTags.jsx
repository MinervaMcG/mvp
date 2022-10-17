import React from "react";

import Tag from "src/components/design_system/tag";
import P2 from "src/components/design_system/typography/p2";

import cx from "classnames";

const UserTags = ({
  tags,
  talent_id,
  className,
  mode,
  tagsSelected,
  clickable = true,
  onClick = null,
}) => {
  const validTags = tags.filter((item) => item != "");

  if (validTags && validTags.length > 0) {
    return (
      <div
        className={`d-flex flex-row flex-wrap align-items-center ${
          className || ""
        }`}
      >
        {validTags.map((tag) => (
          <Tag
            className={cx(
              "mr-2 mt-2",
              tagsSelected?.includes(tag) ? "tag-selected" : ""
            )}
            key={`${talent_id}_${tag}`}
          >
            {onClick ? (
              <button className="button-link" onClick={() => onClick(tag)}>
                <P2
                  className={cx(
                    tagsSelected?.includes(tag) ? "bg-01" : "text-primary-01"
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

export default UserTags;
