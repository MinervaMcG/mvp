import React from "react";

import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import { H4, P1 } from "src/components/design_system/typography";
import { useWindowDimensionsHook } from "src/utils/window";
import { useTheme } from "src/contexts/ThemeContext";
import UserTags from "src/components/talent/UserTags";
import AboutImageLight from "images/about-image-light.png";
import AboutImageDark from "images/about-image-dark.png";

import cx from "classnames";

const About = ({ className, talent }) => {
  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();

  const imageSrc =
    talent.careerGoal.imageUrl ||
    (mode() == "light" ? AboutImageLight : AboutImageDark);

  return (
    <div className={cx(className, mobile ? "" : "d-flex")}>
      <div className={cx(mobile ? "col-12 mx-auto" : "col-6")}>
        <TalentProfilePicture
          className="mb-3 w-100"
          src={imageSrc}
          height={mobile ? 230 : 350}
          width={mobile ? 328 : 469}
          straight
          borderRadius={24}
          contained
        />
      </div>
      <div
        className={cx(
          mobile ? "col-12" : "col-6",
          "d-flex flex-column justify-content-center"
        )}
      >
        {talent.careerGoal.careerNeeds.length > 0 && (
          <div>
            <H4 className="mb-4" text="I'm open to" />
            <UserTags
              tags={talent.careerGoal.careerNeeds.map((need) => need.title)}
              className="mr-2 mb-4"
              clickable={false}
            />
          </div>
        )}
        <P1 text={talent.careerGoal.pitch} />
      </div>
    </div>
  );
};

export default About;
