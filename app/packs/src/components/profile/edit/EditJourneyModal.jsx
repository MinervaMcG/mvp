import React, { useState } from "react";
import dayjs from "dayjs";
import debounce from "lodash/debounce";
import { toast } from "react-toastify";
import Modal from "react-bootstrap/Modal";

import { post, patch, destroy } from "src/utils/requests";
import { snakeCaseObject, camelCaseObject } from "src/utils/transformObjects";
import { useTheme } from "src/contexts/ThemeContext";

import Checkbox from "src/components/design_system/checkbox";
import TextInput from "src/components/design_system/fields/textinput";
import TextArea from "src/components/design_system/fields/textarea";
import Divider from "src/components/design_system/other/Divider";
import Button from "src/components/design_system/button";
import { ToastBody } from "src/components/design_system/toasts";
import { Rocket, Toolbox, Bulb, Learn } from "src/components/icons";
import { H5, P2, P3 } from "src/components/design_system/typography";

import { useWindowDimensionsHook } from "src/utils/window";

import cx from "classnames";

const SelectExperienceType = ({ mobile, goToNextStep }) => {
  return (
    <>
      <Modal.Header closeButton className="px-5">
        <H5 bold text="Select the experience type" />
      </Modal.Header>
      <Divider />
      <Modal.Body
        className={cx(
          "d-flex flex-column align-items-center justify-content-between",
          mobile ? "px-4 pt-4 pb-7" : "px-6 pt-5 pb-6"
        )}
        style={{
          maxHeight: mobile ? "" : "700px",
          overflowY: "overlay",
        }}
      >
        <div className="text-center mb-5">
          <Button
            className={cx(mobile ? "col-12 mb-4" : "col-5 mb-4 mr-4")}
            type="white-subtle"
            size="extra-big"
            onClick={() => goToNextStep("Career Goal")}
          >
            <Rocket size={24} pathClassName="light-primary" color="#7857ED" />
            <P2 medium text="Career Goal" />
          </Button>
          <Button
            className={cx(mobile ? "col-12 mb-4" : "col-5 mb-4")}
            type="white-subtle"
            size="extra-big"
            onClick={() => goToNextStep("Position")}
          >
            <Toolbox size={24} pathClassName="light-primary" color="#328AFF" />
            <P2 medium text="Position" />
          </Button>
          <Button
            className={cx(mobile ? "col-12 mb-4" : "col-5 mr-4")}
            type="white-subtle"
            size="extra-big"
            onClick={() => goToNextStep("Education")}
          >
            <Learn size={24} />
            <P2 medium text="Education" />
          </Button>
          <Button
            className={cx(mobile ? "col-12" : "col-5")}
            type="white-subtle"
            size="extra-big"
            onClick={() => goToNextStep("Other")}
          >
            <Bulb size={24} />
            <P2 medium text="Other" />
          </Button>
        </div>
      </Modal.Body>
      <Divider />
    </>
  );
};

const MilestoneExperience = ({
  mobile,
  changeAttribute,
  currentJourneyItem,
  goToPreviousStep,
  hide,
  saveMilestone,
  updateMilestone,
  deleteMilestone,
  mode,
  editType,
  validationErrors,
}) => {
  return (
    <>
      <Modal.Header closeButton className="px-5">
        <H5 bold text={`${editType} ${currentJourneyItem.category}`} />
      </Modal.Header>
      <Divider />
      <Modal.Body
        className={cx(
          "d-flex flex-column align-items-center justify-content-between",
          mobile ? "px-4 pt-4 pb-7" : "px-6 pt-5 pb-6"
        )}
        style={{
          maxHeight: mobile ? "" : "700px",
          overflowY: "overlay",
        }}
      >
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="Title" />
          <TextInput
            onChange={(e) => changeAttribute("title", e.target.value)}
            value={currentJourneyItem.title}
            placeholder="Ex: Senior Product Designer"
            required={true}
            error={validationErrors?.title}
          />
        </div>
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="Organization" />
          <TextInput
            onChange={(e) => changeAttribute("institution", e.target.value)}
            value={currentJourneyItem.institution}
            placeholder="Ex: Talent Protocol"
            required={true}
            error={validationErrors?.institution}
          />
        </div>
        <div className="w-100 mb-5">
          <div className="mb-2 d-flex justify-content-between align-items-center">
            <P2 className="text-primary-01" bold text="Description" />
            <div className="d-flex">
              <P3
                className="text-primary-01"
                bold
                text={currentJourneyItem.description.length || "0"}
              />
              <P3 className="text-primary-04" bold text="/240" />
            </div>
          </div>
          <TextArea
            onChange={(e) => changeAttribute("description", e.target.value)}
            value={currentJourneyItem.description}
            maxLength={240}
            rows={3}
            required={true}
            error={validationErrors?.description}
          />
        </div>
        <div className="align-self-start mb-5">
          <Checkbox
            className="form-check-input"
            checked={currentJourneyItem.inProgress}
            onChange={() =>
              changeAttribute("inProgress", !currentJourneyItem.inProgress)
            }
          >
            <P2 className="mr-1" text="I am currently working on this role" />
          </Checkbox>
        </div>
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="Start date" />
          <input
            className={cx(
              "form-control",
              mode(),
              validationErrors?.startDate && "border-danger"
            )}
            placeholder={"Select date"}
            type="month"
            value={currentJourneyItem.startDate}
            onChange={(e) => changeAttribute("startDate", e.target.value)}
            required={true}
          />
        </div>
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="End date" />
          <input
            className={cx("form-control", mode())}
            placeholder={"Select date"}
            type="month"
            value={currentJourneyItem.endDate}
            onChange={(e) => changeAttribute("endDate", e.target.value)}
            disabled={currentJourneyItem.inProgress}
          />
        </div>
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="Link" />
          <TextInput
            onChange={(e) => changeAttribute("link", e.target.value)}
            value={currentJourneyItem.link}
          />
        </div>
      </Modal.Body>
      <Divider />
      <Modal.Footer
        className="px-6 py-3 justify-content-between"
        style={{ borderTop: "none" }}
      >
        {editType === "Add" ? (
          <Button
            type="primary-outline"
            text="Back"
            onClick={goToPreviousStep}
          />
        ) : (
          <Button
            type="danger-outline"
            text="Delete experience"
            onClick={deleteMilestone}
          />
        )}
        <div>
          <Button
            className="mr-2"
            type="white-ghost"
            text="Cancel"
            onClick={hide}
          />
          <Button
            type="primary-default"
            text="Save"
            onClick={editType === "Add" ? saveMilestone : updateMilestone}
          />
        </div>
      </Modal.Footer>
    </>
  );
};

const GoalExperience = ({
  mobile,
  changeAttribute,
  currentJourneyItem,
  goToPreviousStep,
  hide,
  saveGoal,
  updateGoal,
  deleteGoal,
  mode,
  editType,
  validationErrors,
}) => {
  return (
    <>
      <Modal.Header closeButton className="px-5">
        <H5 bold text={`${editType} ${currentJourneyItem.category}`} />
      </Modal.Header>
      <Divider />
      <Modal.Body
        className={cx(
          "d-flex flex-column align-items-center justify-content-between",
          mobile ? "px-4 pt-4 pb-7" : "px-6 pt-5 pb-6"
        )}
        style={{
          maxHeight: mobile ? "" : "700px",
          overflowY: "overlay",
        }}
      >
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="Title" />
          <TextInput
            onChange={(e) => changeAttribute("title", e.target.value)}
            value={currentJourneyItem.title}
            placeholder="Ex: Finding a co-founder for my startup"
            required={true}
            error={validationErrors?.title}
          />
        </div>
        <div className="w-100 mb-5">
          <div className="mb-2 d-flex justify-content-between align-items-center">
            <P2 className="text-primary-01" bold text="Description" />
            <div className="d-flex">
              <P3
                className="text-primary-01"
                bold
                text={currentJourneyItem.description.length || "0"}
              />
              <P3 className="text-primary-04" bold text="/240" />
            </div>
          </div>
          <TextArea
            onChange={(e) => changeAttribute("description", e.target.value)}
            value={currentJourneyItem.description}
            maxLength={240}
            rows={3}
            required={true}
            error={validationErrors?.description}
          />
        </div>
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="Due date" />
          <input
            className={cx(
              "form-control",
              mode(),
              validationErrors?.dueDate && "border-danger"
            )}
            placeholder={"Select date"}
            type="month"
            value={currentJourneyItem.dueDate}
            onChange={(e) => changeAttribute("dueDate", e.target.value)}
            required={true}
          />
        </div>
        <div className="w-100 mb-5">
          <P2 className="mb-2 text-primary-01" bold text="Link" />
          <TextInput
            onChange={(e) => changeAttribute("link", e.target.value)}
            value={currentJourneyItem.link}
          />
        </div>
      </Modal.Body>
      <Divider />
      <Modal.Footer
        className="px-6 py-3 justify-content-between"
        style={{ borderTop: "none" }}
      >
        {editType === "Add" ? (
          <Button
            type="primary-outline"
            text="Back"
            onClick={goToPreviousStep}
          />
        ) : (
          <Button
            type="danger-outline"
            text="Delete experience"
            onClick={deleteGoal}
          />
        )}
        <div>
          <Button
            className="mr-2"
            type="white-ghost"
            text="Cancel"
            onClick={hide}
          />
          <Button
            type="primary-default"
            text="Save"
            onClick={editType === "Add" ? saveGoal : updateGoal}
          />
        </div>
      </Modal.Footer>
    </>
  );
};

const EditJourneyModal = ({
  show,
  hide,
  talent,
  setTalent,
  editType,
  setJourneyItem,
  journeyItem = {},
}) => {
  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();
  const [currentStep, setCurrentStep] = useState(1);
  const [currentJourneyItem, setCurrentJourneyItem] = useState({
    id: journeyItem?.id || "",
    title: journeyItem?.title || "",
    startDate:
      dayjs(journeyItem?.startDate, "YYYY-MM-DD").format("YYYY-MM") || "",
    endDate: dayjs(journeyItem?.endDate, "YYYY-MM-DD").format("YYYY-MM") || "",
    dueDate: dayjs(journeyItem?.dueDate, "YYYY-MM-DD").format("YYYY-MM") || "",
    description: journeyItem?.description || "",
    link: journeyItem?.link || "",
    institution: journeyItem?.institution || "",
    inProgress: false,
    category: journeyItem?.category || "",
  });
  const [validationErrors, setValidationErrors] = useState({
    title: false,
    startDate: false,
    dueDate: false,
    description: false,
    institution: false,
  });

  const milestoneErrors = () => {
    const errors = {};
    if (currentJourneyItem.title == "") {
      errors.title = true;
    }
    if (currentJourneyItem.startDate == "") {
      errors.startDate = true;
    }
    if (currentJourneyItem.description == "") {
      errors.description = true;
    }
    if (currentJourneyItem.institution == "") {
      errors.institution = true;
    }

    return errors;
  };

  const goalErrors = () => {
    const errors = {};
    if (currentJourneyItem.title == "") {
      errors.title = true;
    }
    if (currentJourneyItem.dueDate == "") {
      errors.dueDate = true;
    }
    if (currentJourneyItem.description == "") {
      errors.description = true;
    }

    return errors;
  };

  const saveMilestone = async () => {
    const errors = milestoneErrors();

    if (Object.keys(errors).length > 0) {
      return setValidationErrors(errors);
    }

    const response = await post(`/api/v1/talent/${talent.id}/milestones`, {
      milestone: {
        ...snakeCaseObject(currentJourneyItem),
      },
    });

    if (response && !response.error) {
      setTalent((prev) => ({
        ...prev,
        milestones: [...prev.milestones, camelCaseObject(response)],
      }));

      toast.success(
        <ToastBody
          heading="Success!"
          body={"Milestone created successfully."}
          mode={mode}
        />,
        { autoClose: 1500 }
      );
    } else {
      toast.error(
        <ToastBody heading="Error!" body={response?.error} mode={mode} />
      );
    }

    exitModal();
  };

  const updateMilestone = async () => {
    const errors = milestoneErrors();

    if (Object.keys(errors).length > 0) {
      return setValidationErrors(errors);
    }

    const response = await patch(
      `/api/v1/talent/${talent.id}/milestones/${currentJourneyItem.id}`,
      {
        milestone: snakeCaseObject(currentJourneyItem),
      }
    );

    if (response && !response.error) {
      const newMilestones = talent.milestones.map((milestone) => {
        if (milestone.id === response.id) {
          return { ...milestone, ...response };
        }
        return { ...milestone };
      });

      setTalent((prev) => ({
        ...prev,
        milestones: newMilestones,
      }));

      toast.success(
        <ToastBody
          heading="Success!"
          body={"Milestone updated successfully."}
          mode={mode}
        />,
        { autoClose: 1500 }
      );
    } else {
      toast.error(
        <ToastBody heading="Error!" body={response?.error} mode={mode} />
      );
    }

    exitModal();
  };

  const deleteMilestone = async () => {
    const response = await destroy(
      `/api/v1/talent/${talent.id}/milestones/${currentJourneyItem.id}`
    );

    if (response) {
      const index = talent.milestones.findIndex(
        (milestone) => milestone.id === response.id
      );
      const newMilestones = [
        ...talent.milestones.slice(0, index),
        ...talent.milestones.slice(index + 1),
      ];

      setTalent((prev) => ({
        ...prev,
        milestones: newMilestones,
      }));

      toast.success(
        <ToastBody
          heading="Success!"
          body={"Milestone deleted successfully."}
          mode={mode}
        />,
        { autoClose: 1500 }
      );
    }

    exitModal();
  };

  const saveGoal = async () => {
    const errors = goalErrors();

    if (Object.keys(errors).length > 0) {
      return setValidationErrors(errors);
    }

    const response = await post(
      `/api/v1/career_goals/${talent.careerGoal.id}/goals`,
      {
        goal: snakeCaseObject(currentJourneyItem),
      }
    );

    if (response && !response.error) {
      setTalent((prev) => ({
        ...prev,
        careerGoal: {
          ...prev.careerGoal,
          goals: [...prev.careerGoal.goals, camelCaseObject(response)],
        },
      }));

      toast.success(
        <ToastBody
          heading="Success!"
          body={"Goal created successfully."}
          mode={mode}
        />,
        { autoClose: 1500 }
      );
    } else {
      toast.error(
        <ToastBody heading="Error!" body={response?.error} mode={mode} />
      );
    }

    exitModal();
  };

  const updateGoal = async () => {
    const errors = goalErrors();

    if (Object.keys(errors).length > 0) {
      return setValidationErrors(errors);
    }

    const response = await patch(
      `/api/v1/career_goals/${talent.careerGoal.id}/goals/${currentJourneyItem.id}`,
      {
        goal: snakeCaseObject(currentJourneyItem),
      }
    );

    if (response && !response.error) {
      const newGoals = talent.careerGoal.goals.map((goal) => {
        if (goal.id === response.id) {
          return { ...goal, ...response };
        }
        return { ...goal };
      });

      setTalent((prev) => ({
        ...prev,
        careerGoal: {
          ...prev.careerGoal,
          goals: newGoals,
        },
      }));

      toast.success(
        <ToastBody
          heading="Success!"
          body={"Goal updated successfully."}
          mode={mode}
        />,
        { autoClose: 1500 }
      );
    } else {
      toast.error(
        <ToastBody heading="Error!" body={response?.error} mode={mode} />
      );
    }

    exitModal();
  };

  const deleteGoal = async () => {
    const response = await destroy(
      `/api/v1/career_goals/${talent.careerGoal.id}/goals/${currentJourneyItem.id}`
    );

    if (response) {
      const index = talent.careerGoal.goals.findIndex(
        (goal) => goal.id === response.id
      );
      const newGoals = [
        ...talent.careerGoal.goals.slice(0, index),
        ...talent.careerGoal.goals.slice(index + 1),
      ];

      setTalent((prev) => ({
        ...prev,
        careerGoal: {
          ...prev.careerGoal,
          goals: newGoals,
        },
      }));

      toast.success(
        <ToastBody
          heading="Success!"
          body={"Goal deleted successfully."}
          mode={mode}
        />,
        { autoClose: 1500 }
      );
    }

    exitModal();
  };

  const goToNextStep = (newExperienceType) => {
    setCurrentJourneyItem((prev) => ({ ...prev, category: newExperienceType }));
    setCurrentStep(2);
  };

  const goToPreviousStep = () => {
    setCurrentJourneyItem({
      id: "",
      title: "",
      startDate: "",
      endDate: "",
      dueDate: "",
      description: "",
      link: "",
      institution: "",
      inProgress: false,
      category: "",
    });
    setCurrentStep(1);
  };

  const changeAttribute = (attribute, value) => {
    setValidationErrors((prev) => ({ ...prev, [attribute]: false }));
    setCurrentJourneyItem((prev) => ({ ...prev, [attribute]: value }));
  };

  const exitModal = () => {
    setCurrentJourneyItem({
      id: "",
      title: "",
      startDate: "",
      endDate: "",
      dueDate: "",
      description: "",
      link: "",
      institution: "",
      inProgress: false,
      category: "",
    });
    setJourneyItem(null);
    hide();
  };

  const debouncedSaveMilestone = debounce(() => saveMilestone(), 400);
  const debouncedUpdateMilestone = debounce(() => updateMilestone(), 400);
  const debouncedDeleteMilestone = debounce(() => deleteMilestone(), 400);
  const debouncedSaveGoal = debounce(() => saveGoal(), 400);
  const debouncedUpdateGoal = debounce(() => updateGoal(), 400);
  const debouncedDeleteGoal = debounce(() => deleteGoal(), 400);

  return (
    <Modal
      scrollable={true}
      show={show}
      onHide={exitModal}
      centered
      dialogClassName={mobile ? "mw-100 mh-100 m-0" : "remove-background"}
      contentClassName={mobile ? "h-100" : ""}
      fullscreen="true"
      className="edit-modal"
    >
      {editType === "Add" ? (
        <>
          {currentStep === 1 && (
            <SelectExperienceType mobile={mobile} goToNextStep={goToNextStep} />
          )}
          {currentStep === 2 &&
            currentJourneyItem.category !== "Career Goal" && (
              <MilestoneExperience
                mobile={mobile}
                changeAttribute={changeAttribute}
                currentJourneyItem={currentJourneyItem}
                goToPreviousStep={goToPreviousStep}
                hide={exitModal}
                saveMilestone={debouncedSaveMilestone}
                mode={mode}
                editType={editType}
                validationErrors={validationErrors}
              />
            )}
          {currentStep === 2 &&
            currentJourneyItem.category === "Career Goal" && (
              <GoalExperience
                mobile={mobile}
                changeAttribute={changeAttribute}
                currentJourneyItem={currentJourneyItem}
                goToPreviousStep={goToPreviousStep}
                hide={exitModal}
                saveGoal={debouncedSaveGoal}
                mode={mode}
                editType={editType}
                validationErrors={validationErrors}
              />
            )}
        </>
      ) : (
        <>
          {currentJourneyItem.category !== "Goal" ? (
            <MilestoneExperience
              mobile={mobile}
              changeAttribute={changeAttribute}
              currentJourneyItem={currentJourneyItem}
              goToPreviousStep={goToPreviousStep}
              hide={exitModal}
              saveMilestone={debouncedSaveMilestone}
              updateMilestone={debouncedUpdateMilestone}
              deleteMilestone={debouncedDeleteMilestone}
              mode={mode}
              editType={editType}
              validationErrors={validationErrors}
            />
          ) : (
            <GoalExperience
              mobile={mobile}
              changeAttribute={changeAttribute}
              currentJourneyItem={currentJourneyItem}
              goToPreviousStep={goToPreviousStep}
              hide={exitModal}
              saveGoal={debouncedSaveGoal}
              updateGoal={debouncedUpdateGoal}
              deleteGoal={debouncedDeleteGoal}
              mode={mode}
              editType={editType}
              validationErrors={validationErrors}
            />
          )}
        </>
      )}
    </Modal>
  );
};

export default EditJourneyModal;
