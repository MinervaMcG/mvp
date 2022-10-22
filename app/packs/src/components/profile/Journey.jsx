import React, { useState, useEffect } from "react";
import dayjs from "dayjs";

import { H4, H5, P1, P2, P3 } from "src/components/design_system/typography";
import { useWindowDimensionsHook } from "src/utils/window";
import { compareDates } from "src/utils/compareHelpers";
import { Rocket, Toolbox, Bulb, Learn } from "src/components/icons";
import Divider from "src/components/design_system/other/Divider";
import Button from "src/components/design_system/button";
import EditJourneyModal from "./edit/EditJourneyModal";

import cx from "classnames";
import customParseFormat from "dayjs/plugin/customParseFormat";
dayjs.extend(customParseFormat);

const Journey = ({ className, talent, setTalent, canUpdate }) => {
  const { mobile } = useWindowDimensionsHook();
  const [journeyItems, setJourneyItems] = useState([]);
  const [filteredJourneyItems, setFilteredJourneyItems] = useState([]);
  const [activeFilter, setActiveFilter] = useState("All");
  const [editMode, setEditMode] = useState(false);
  const [editType, setEditType] = useState("");
  const [journeyItemInEditing, setJourneyItemInEditing] = useState(null);

  useEffect(() => {
    const allItems = mergeAndSortJourney(
      talent.milestones,
      talent.careerGoal.goals
    );
    setJourneyItems(allItems);

    setFilteredJourneyItems(applyCategoryFilter(allItems));
  }, [talent.milestones, talent.careerGoal.goals, activeFilter]);

  const compareEndData = (milestone1, milestone2) =>
    compareDates(milestone2.startDate, milestone1.startDate);

  const currentDate = dayjs();

  const mergeAndSortJourney = (milestones, goals) => {
    const allElements = [].concat(
      goals.map((goal) => ({
        ...goal,
        category: "Goal",
        startDate: goal.dueDate,
      })),
      milestones
    );

    const sortedElements = allElements.sort(compareEndData);

    return sortedElements;
  };

  const cssForBorder = (journeyItem, index, arrayLength) => {
    if (dayjs(journeyItem.startDate).isAfter(currentDate)) {
      if (index === arrayLength - 1) {
        return "";
      } else {
        return "left-dashed-border-black";
      }
    } else {
      if (index === arrayLength - 1) {
        return "";
      } else {
        return "left-solid-border-black";
      }
    }
  };

  const useDashedLine = (journeyItem) => {
    return dayjs(journeyItem.startDate).isAfter(currentDate);
  };

  const iconForItem = (item, addSpacing = false) => {
    if (item.category == "Other") {
      return <Bulb className={`h-100${addSpacing ? " mr-1" : ""}`} size={16} />;
    } else if (item.category == "Education") {
      return (
        <Learn className={`h-100${addSpacing ? " mr-1" : ""}`} size={16} />
      );
    } else if (item.category == "Goal") {
      return (
        <Rocket
          className={`h-100${addSpacing ? " mr-1" : ""}`}
          size={16}
          pathClassName="light-primary"
          color="#7857ED"
        />
      );
    } else {
      return (
        <Toolbox
          className={`h-100${addSpacing ? " mr-1" : ""}`}
          size={16}
          pathClassName="light-primary"
          color="#328AFF"
        />
      );
    }
  };

  const displayYear = (index) => {
    const currentJourneyItem = journeyItems[index];
    const previousJourneyItem = index == 0 ? null : journeyItems[index - 1];

    if (previousJourneyItem) {
      return !dayjs(currentJourneyItem.startDate).isSame(
        previousJourneyItem.startDate,
        "year"
      );
    } else {
      return true;
    }
  };

  const categoryCount = (category) => {
    return `(${
      journeyItems.filter((item) => item.category == category).length
    })`;
  };

  const applyCategoryFilter = (items) => {
    if (activeFilter == "All") {
      return items;
    }

    return items.filter((item) => item.category == activeFilter);
  };

  return (
    <>
      {(talent.careerGoal.goals.length > 0 || talent.milestones.length > 0) && (
        <div className={cx(className)}>
          <div className="d-flex w-100 mb-7">
            <div className="d-flex flex-column align-items-center w-100">
              <H4 className="text-center" text="Journey" />
              <P1
                className="text-center lg-w-50 lg-mx-0 mx-4"
                text="Here is where you can see what I'm doing at the moment,
                what I've done and where I want to be!"
              />
              <div className="w-100 my-6 px-4 d-flex flex-row overflow-x-scroll justify-content-lg-center">
                <button
                  type="button"
                  className={`mr-2 btn text-nowrap all-journey-button${
                    activeFilter == "All" ? " active" : ""
                  }`}
                  onClick={() => setActiveFilter("All")}
                >
                  All ({journeyItems.length})
                </button>
                <button
                  type="button"
                  className={`mr-2 btn text-nowrap all-journey-button goal-journey-button${
                    activeFilter == "Goal" ? " active" : ""
                  }`}
                  onClick={() => setActiveFilter("Goal")}
                >
                  {iconForItem({ category: "Goal" }, true)} Goal{" "}
                  {categoryCount("Goal")}
                </button>
                <button
                  type="button"
                  className={`mr-2 btn text-nowrap all-journey-button position-journey-button${
                    activeFilter == "Position" ? " active" : ""
                  }`}
                  onClick={() => setActiveFilter("Position")}
                >
                  {iconForItem({ category: "Position" }, true)} Position{" "}
                  {categoryCount("Position")}
                </button>
                <button
                  type="button"
                  className={`mr-2 btn text-nowrap all-journey-button education-journey-button${
                    activeFilter == "Education" ? " active" : ""
                  }`}
                  onClick={() => setActiveFilter("Education")}
                >
                  {iconForItem({ category: "Education" }, true)} Education{" "}
                  {categoryCount("Education")}
                </button>
                <button
                  type="button"
                  className={`btn all-journey-button text-nowrap other-journey-button${
                    activeFilter == "Other" ? " active" : ""
                  }`}
                  onClick={() => setActiveFilter("Other")}
                >
                  {iconForItem({ category: "Other" }, true)} Other{" "}
                  {categoryCount("Other")}
                </button>
              </div>
              {canUpdate && (
                <Button
                  className="align-self-end"
                  type="primary-default"
                  size="big"
                  text="Add Experience"
                  onClick={() => {
                    setEditType("Add");
                    setEditMode(true);
                  }}
                />
              )}
            </div>
          </div>
          <div className="d-flex flex-column">
            {filteredJourneyItems.map((journeyItem, index) => (
              <div className="d-flex flex-row" key={`journey-item-${index}`}>
                <H5
                  className="col-1 text-primary-01"
                  text={
                    displayYear(index) && !mobile
                      ? dayjs(journeyItem.startDate).year()
                      : ""
                  }
                />
                <div className="d-flex col-11 pr-0">
                  {!mobile && (
                    <P3
                      className="text-primary-04 col-3 text-right pr-6 pt-1"
                      bold
                    >
                      {dayjs(journeyItem.startDate, "YYYY-MM-DD").format(
                        "MMM YYYY"
                      )}
                      {journeyItem.inProgress && " - Today"}
                      {journeyItem.endDate && !journeyItem.inProgress
                        ? ` - ${dayjs(journeyItem.endDate, "YYYY-MM-DD").format(
                            "MMM YYYY"
                          )}`
                        : ""}
                    </P3>
                  )}
                  <div
                    className={cx(
                      mobile
                        ? `col-9 pl-6 ${cssForBorder(
                            journeyItem,
                            index,
                            filteredJourneyItems.length
                          )} position-relative`
                        : `col-9 pl-7 pr-0 ${cssForBorder(
                            journeyItem,
                            index,
                            filteredJourneyItems.length
                          )} position-relative`
                    )}
                  >
                    {mobile && (
                      <P3 className="text-primary-04 mb-4" bold>
                        {dayjs(journeyItem.startDate, "YYYY-MM-DD").format(
                          "MMM YYYY"
                        )}
                        {journeyItem.endDate
                          ? ` - ${dayjs(
                              journeyItem.endDate,
                              "YYYY-MM-DD"
                            ).format("MMM YYYY")}`
                          : ""}
                      </P3>
                    )}
                    <div className="d-flex justify-content-between">
                      <P1
                        className="text-primary-01 medium mb-1"
                        text={journeyItem.title}
                      />
                      {canUpdate && (
                        <Button
                          type="primary-outline"
                          text="Edit"
                          onClick={() => {
                            setJourneyItemInEditing(journeyItem);
                            setEditType("Edit");
                            setEditMode(true);
                          }}
                        />
                      )}
                    </div>
                    <P2
                      className="text-primary-01 mb-3"
                      text={journeyItem.institution}
                    />
                    <P2
                      className="text-primary-03"
                      text={journeyItem.description}
                    />
                    <div className="rocket-position-absolute">
                      <div
                        className={
                          useDashedLine(journeyItem)
                            ? "journey-dashed-border"
                            : "journey-border"
                        }
                      >
                        {iconForItem(journeyItem)}
                      </div>
                    </div>
                    <Divider className="my-5" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
      {editMode && (
        <EditJourneyModal
          show={editMode}
          hide={() => setEditMode(false)}
          talent={talent}
          setTalent={setTalent}
          editType={editType}
          journeyItem={journeyItemInEditing}
          setJourneyItem={setJourneyItemInEditing}
        />
      )}
    </>
  );
};

export default Journey;
