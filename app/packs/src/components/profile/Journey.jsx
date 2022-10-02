import React from "react";
import dayjs from "dayjs";

import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import { H4, H5, P1, P2, P3 } from "src/components/design_system/typography";
import { useWindowDimensionsHook } from "src/utils/window";
import { useTheme } from "src/contexts/ThemeContext";
import { compareDates } from "src/utils/compareHelpers";
import UserTags from "src/components/talent/UserTags";
import { Rocket, Toolbox } from "src/components/icons";
import Divider from "src/components/design_system/other/Divider";

import cx from "classnames";

const Journey = ({ className, talent }) => {
  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();

  const compareDueData = (goal1, goal2) =>
    compareDates(goal1.dueDate, goal2.dueDate);
  const compareEndData = (milestone1, milestone2) =>
    compareDates(milestone1.startDate, milestone2.startDate);

  const sortedGoals = talent.careerGoal.goals.sort(compareDueData).reverse();
  const formatedLastGoalDueDate = dayjs(
    sortedGoals[0]?.dueDate,
    "YYYY-MM-DD"
  ).format("YYYY");

  const sortedMilestones = talent.milestones.sort(compareEndData).reverse();
  const formatedLastMilestoneDueDate = dayjs(
    sortedMilestones[0]?.dueDate,
    "YYYY-MM-DD"
  ).format("YYYY");

  return (
    <>
      {(sortedGoals.length > 0 || sortedMilestones.length > 0) && (
        <div className={cx(className, mobile ? "" : "")}>
          <div className="d-flex w-100 mb-7">
            {!mobile && <div className="col-3"></div>}
            <div className="d-flex flex-column align-items-center w-100">
              <H4 className="text-center" text="Journey" />
              <P1
                className="text-center"
                text="Here is where you can see what I'm doing at the moment,
                what I've done and where I want to be!"
              />
            </div>
            {!mobile && <div className="col-3"></div>}
          </div>
          <div className="w-100 d-flex col-12">
            {!mobile && sortedGoals.length > 0 && (
              <H5
                className="col-1 text-primary-01"
                text={formatedLastGoalDueDate}
              />
            )}
            <div className="d-flex flex-column col-11">
              {sortedGoals.map((goal) => (
                <div className="d-flex">
                  {!mobile && (
                    <P3
                      className="text-primary-04 col-2 text-right pt-2"
                      bold
                      text={dayjs(goal.dueDate, "YYYY-MM-DD").format(
                        "MMM-YYYY"
                      )}
                    />
                  )}
                  <div className={cx(mobile ? "col-2" : "col-1")}>
                    <div className="journey-dashed-border">
                      <Rocket
                        className="h-100"
                        size={16}
                        pathClassName="light-primary"
                        color="currentColor"
                      />
                    </div>
                  </div>
                  <div className={cx(mobile ? "col-10 pt-2" : "col-9 pt-1")}>
                    {mobile && (
                      <P3
                        className="text-primary-04 mb-4"
                        bold
                        text={dayjs(goal.dueDate, "YYYY-MM-DD").format(
                          "MMM-YYYY"
                        )}
                      />
                    )}
                    <P1
                      className="text-primary-01 mb-3"
                      bold
                      text={goal.title}
                    />
                    <P2 className="text-primary-03" text={goal.description} />
                    <Divider className="my-5" />
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div className="w-100 d-flex col-12">
            {!mobile && sortedMilestones.length > 0 && (
              <H5
                className="col-1 text-primary-01"
                text={formatedLastMilestoneDueDate}
              />
            )}
            <div className="d-flex flex-column col-11">
              {sortedMilestones.map((milestone) => (
                <div className="d-flex">
                  {!mobile && (
                    <P3
                      className="text-primary-04 col-2 text-right pt-2"
                      bold
                      text={dayjs(milestone.startDate, "YYYY-MM-DD").format(
                        "MMM-YYYY"
                      )}
                    />
                  )}
                  <div className={cx(mobile ? "col-2" : "col-1")}>
                    <div className="journey-border">
                      <Toolbox
                        className="h-100"
                        size={16}
                        pathClassName="light-primary"
                        color="currentColor"
                      />
                    </div>
                  </div>
                  <div className={cx(mobile ? "col-10 pt-2" : "col-9 pt-1")}>
                    {mobile && (
                      <P3
                        className="text-primary-04 mb-4"
                        bold
                        text={dayjs(milestone.startDate, "YYYY-MM-DD").format(
                          "MMM-YYYY"
                        )}
                      />
                    )}
                    <P1
                      className="text-primary-01 mb-1"
                      bold
                      text={milestone.title}
                    />
                    <P2
                      className="text-primary-01 mb-3"
                      text={milestone.institution}
                    />
                    <P2
                      className="text-primary-03"
                      text={milestone.description}
                    />
                    <Divider className="my-5" />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Journey;
