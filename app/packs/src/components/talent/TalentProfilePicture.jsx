import React from "react";
import { string, number, oneOfType, bool } from "prop-types";
import ThemeContainer, { useTheme } from "src/contexts/ThemeContext";
import DefaultBannerLight from "images/default-banner-light.png";
import DefaultBannerDark from "images/default-banner-dark.png";

const TalentProfilePicture = ({
  src,
  height,
  width,
  greyscale,
  className,
  straight,
  blur,
  border,
  link,
  style,
  contained,
  userId
}) => {
  const { mode } = useTheme();

  const imgSrc = () => {
    if (src) {
      return src;
    } else if (!straight) {
      // eslint-disable-next-line no-undef
      return require(`images/default-profile-icon-${Math.floor((userId || 0 ) % 5)}.png`);
    } else if (mode() === "light" && straight) {
      return DefaultBannerLight;
    } else if (mode() === "dark" && straight) {
      return DefaultBannerDark;
    }
  };

  const grey = greyscale ? " image-greyscale " : "";
  const roundPhoto = straight ? "" : "rounded-circle ";
  const blurPhoto = !blur ? "" : "blur-photo ";
  const borderPhoto = !border ? "" : "border-photo ";
  const imageContained = !contained ? "image-fit" : "image-contain";

  const WithLink = ({ link, children }) =>
    link ? <a href={link}>{children}</a> : children;

  return (
    <WithLink link={link}>
      <img
        className={`${roundPhoto}${grey}${blurPhoto}${borderPhoto} ${
          className || ""
        } ${imageContained}`}
        src={imgSrc()}
        width={width || height}
        height={height}
        alt="Profile Picture"
        style={style}
      />
    </WithLink>
  );
};

TalentProfilePicture.defaultProps = {
  src: null,
  height: 24,
  width: null,
  greyscale: null,
  className: null,
  straight: null,
  blur: null,
  border: null,
  link: null,
  userId: 0
};

TalentProfilePicture.propTypes = {
  src: string,
  height: oneOfType([number, string]),
  width: oneOfType([number, string]),
  greyscale: bool,
  className: string,
  straight: bool,
  blur: bool,
  border: bool,
  link: string,
};

// eslint-disable-next-line no-unused-vars
export default (props, _railsContext) => (
  <ThemeContainer>
    <TalentProfilePicture {...props} />
  </ThemeContainer>
);
