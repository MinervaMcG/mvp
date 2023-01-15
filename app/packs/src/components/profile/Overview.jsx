import React, { useState, useEffect, useMemo } from "react";
import dayjs from "dayjs";

import { ethers } from "ethers";
import { patch, getAuthToken, post, destroy } from "src/utils/requests";
import { toast } from "react-toastify";

import Uppy from "@uppy/core";
import AwsS3Multipart from "@uppy/aws-s3-multipart";

import { snakeCaseObject, camelCaseObject } from "src/utils/transformObjects";

import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import { H4, H5, P2 } from "src/components/design_system/typography";
import CameraButton from "images/camera-button.png";
import DeleteButton from "images/delete-button.png";
import TalentBanner from "images/overview.gif";
import { useWindowDimensionsHook } from "src/utils/window";
import { useTheme } from "src/contexts/ThemeContext";
import { ToastBody } from "src/components/design_system/toasts";
import UserTags from "src/components/talent/UserTags";
import Button from "src/components/design_system/button";
import StakeModal from "src/components/token/StakeModal";
import Tooltip from "src/components/design_system/tooltip";
import { Globe, Calendar, Envelope, Spinner, Help } from "src/components/icons";
import { lightTextPrimary03, lightTextPrimary04 } from "src/utils/colors";

import { formatNumberWithSymbol, verifiedIcon } from "src/utils/viewHelpers";
import EditOverviewModal from "src/components/profile/edit/EditOverviewModal";
import RejectTalentModal from "./RejectTalentModal";
import ApprovalConfirmationModal from "./ApprovalConfirmationModal";
import SocialRow from "./SocialRow";
import AdminVerificationConfirmationModal from "./AdminVerificationConfirmationModal";
import PersonaVerificationConfirmationModal from "./PersonaVerificationConfirmationModal";

import cx from "classnames";
import customParseFormat from "dayjs/plugin/customParseFormat";
dayjs.extend(customParseFormat);

const Overview = ({
  className,
  talent,
  setTalent,
  talentTokenPrice,
  currentUserId,
  currentUserAdmin,
  currentUserModerator,
  railsContext,
  changeSection,
  canUpdate,
  previewMode,
  setPreviewMode,
  isCurrentUserImpersonated,
  withPersonaRequest,
}) => {
  const joinedAt = dayjs(talent.user.createdAt).format("MMMM YYYY");

  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();
  const [showStakeModal, setShowStakeModal] = useState(false);
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [showApprovalConfirmationModal, setShowApprovalConfirmationModal] =
    useState(false);
  const [
    showAdminVerificationConfirmationModal,
    setShowAdminVerificationConfirmationModal,
  ] = useState(false);
  const [
    showPersonaVerificationConfirmationModal,
    setShowPersonaVerificationConfirmationModal,
  ] = useState(false);
  const [isUploadingProfile, setIsUploadingProfile] = useState(false);
  const [isUploadingBanner, setIsUploadingBanner] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [overviewProfileFileInput, setOverviewProfileFileInput] =
    useState(null);
  const [overviewBannerFileInput, setOverviewBannerFileInput] = useState(null);

  const uppyProfile = new Uppy({
    meta: { type: "avatar" },
    restrictions: {
      maxFileSize: 5120000,
      allowedFileTypes: [".jpg", ".png", ".jpeg"],
    },
    autoProceed: true,
  });

  const uppyBanner = new Uppy({
    meta: { type: "avatar" },
    restrictions: {
      maxFileSize: 5120000,
      allowedFileTypes: [".jpg", ".png", ".jpeg", ".gif"],
    },
    autoProceed: true,
  });

  uppyProfile.use(AwsS3Multipart, {
    limit: 4,
    companionUrl: "/",
    companionHeaders: {
      "X-CSRF-Token": getAuthToken(),
    },
  });

  uppyBanner.use(AwsS3Multipart, {
    limit: 4,
    companionUrl: "/",
    companionHeaders: {
      "X-CSRF-Token": getAuthToken(),
    },
  });

  overviewProfileFileInput?.addEventListener("change", (event) => {
    setIsUploadingProfile(true);
    const files = Array.from(event.target.files);
    files.forEach((file) => {
      try {
        uppyProfile.addFile({
          source: "file input",
          name: file.name,
          type: file.type,
          data: file,
        });
      } catch (err) {
        setIsUploadingProfile(false);
        if (err.isRestriction) {
          // handle restrictions
          console.log("Restriction error:", err);
        } else {
          // handle other errors
          console.error(err);
        }
      }
    });
  });

  overviewBannerFileInput?.addEventListener("change", (event) => {
    setIsUploadingBanner(true);
    const files = Array.from(event.target.files);
    files.forEach((file) => {
      try {
        uppyBanner.addFile({
          source: "file input",
          name: file.name,
          type: file.type,
          data: file,
        });
      } catch (err) {
        setIsUploadingBanner(false);
        if (err.isRestriction) {
          // handle restrictions
          console.log("Restriction error:", err);
        } else {
          // handle other errors
          console.error(err);
        }
      }
    });
  });

  const saveProfile = async (updatedTalent) => {
    const response = await patch(`/api/v1/talent/${talent.id}`, {
      user: {
        ...snakeCaseObject(updatedTalent.user),
      },
      talent: {
        ...snakeCaseObject(updatedTalent),
      },
    });

    if (response) {
      setTalent((prev) => ({
        ...prev,
        ...camelCaseObject(response),
      }));
    }
  };

  const deleteBannerImg = () => {
    saveProfile({
      ...talent,
      bannerUrl: null,
      bannerData: null,
    });
  };

  useEffect(() => {
    uppyProfile.on("restriction-failed", () => {
      uppyProfile.reset();
    });
    uppyProfile.on("upload-success", (file, response) => {
      setIsUploadingProfile(false);
      setIsUploadingBanner(false);
      saveProfile({
        ...talent,
        profilePictureUrl: response.uploadURL,
        profilePictureData: {
          id: response.uploadURL.match(/\/cache\/([^\?]+)/)[1], // extract key without prefix
          storage: "cache",
          metadata: {
            size: file.size,
            filename: file.name,
            mime_type: file.type,
          },
        },
      });
    });
    uppyProfile.on("upload", () => {});
  }, [uppyProfile]);

  useEffect(() => {
    uppyBanner.on("restriction-failed", () => {
      uppyBanner.reset();
    });
    uppyBanner.on("upload-success", (file, response) => {
      setIsUploadingProfile(false);
      setIsUploadingBanner(false);
      saveProfile({
        ...talent,
        bannerUrl: response.uploadURL,
        bannerData: {
          id: response.uploadURL.match(/\/cache\/([^\?]+)/)[1], // extract key without prefix
          storage: "cache",
          metadata: {
            size: file.size,
            filename: file.name,
            mime_type: file.type,
          },
        },
      });
    });
    uppyBanner.on("upload", () => {});
  }, [uppyBanner]);

  useEffect(() => {
    setOverviewProfileFileInput(
      document.getElementById("overviewProfileFileInput")
    );
    setOverviewBannerFileInput(
      document.getElementById("overviewBannerFileInput")
    );
  }, []);

  const impersonateUser = async () => {
    const params = {
      username: talent.user.username,
    };

    const response = await post(`/api/v1/impersonations`, params).catch(() => {
      return false;
    });

    if (response && !response.error) {
      toast.success(
        <ToastBody
          heading="Success!"
          body="Impersonation started successfully!"
        />
      );
      window.location.reload();
    }
  };

  const updateFollow = async () => {
    let response;
    if (talent.isFollowing) {
      response = await destroy(`/api/v1/follows?user_id=${talent.user.id}`);
    } else {
      response = await post(`/api/v1/follows`, {
        user_id: talent.user.id,
      });
    }

    if (response.success) {
      setTalent((prev) => ({
        ...prev,
        isFollowing: !talent.isFollowing,
      }));
    } else {
      toast.error(
        <ToastBody heading="Unable to update follow" body={response?.error} />
      );
    }
  };

  const showFollowButton = () => {
    return currentUserId && talent.user.id != currentUserId;
  };

  const headlineArray = useMemo(() => {
    return talent.profile.headline?.split(" ");
  }, [talent.profile.headline]);

  const verifyTooltipBody = () => {
    if (talent.withPersonaId) {
      return "Your verification is being processed";
    } else if (
      withPersonaRequest.requests_counter >
      railsContext.withPersonaVerificationsLimit
    ) {
      return "The number of verifications we can do is limited. Please check back later to verify your account";
    } else {
      return "In order to verify your account your profile must be complete and we must match the legal name you provided with the ID provided";
    }
  };

  return (
    <div className={cx(className)}>
      <div className={cx(mobile ? "" : "d-flex mb-7")}>
        <div className={cx(mobile ? "col-12" : "col-6")}>
          {mobile ? (
            <div className="d-flex flex-column">
              {previewMode || !canUpdate ? (
                <>
                  <TalentProfilePicture
                    className="align-self-end pull-bottom-content-70"
                    style={{ borderRadius: "24px" }}
                    src={talent.bannerUrl || TalentBanner}
                    straight
                    height={213}
                    width={272}
                  />
                  <TalentProfilePicture
                    className="mb-3"
                    src={talent.profilePictureUrl}
                    height={120}
                    border
                  />
                </>
              ) : (
                <>
                  <div
                    className="position-relative pull-bottom-content-70 align-self-end"
                    style={{ width: "272px", height: "213px" }}
                  >
                    {isUploadingProfile ? (
                      <div class="h-100 d-flex justify-content-center align-items-center">
                        <Spinner className="mx-4" width={50} />
                      </div>
                    ) : (
                      <>
                        <TalentProfilePicture
                          style={{ borderRadius: "24px" }}
                          src={talent.bannerUrl || TalentBanner}
                          straight
                          height={213}
                          width={272}
                        />
                        <div
                          className="edit-image"
                          style={{
                            borderRadius: "24px",
                            height: "213px",
                            width: "272px",
                          }}
                        ></div>
                        <label htmlFor="overviewBannerFileInput">
                          <TalentProfilePicture
                            className="position-absolute cursor-pointer"
                            style={{
                              top: mobile ? "90px" : "155px",
                              left: mobile ? "95px" : "185px",
                            }}
                            src={CameraButton}
                            height={40}
                          />
                        </label>
                        <input
                          id="overviewBannerFileInput"
                          className="d-none"
                          type="file"
                          accept=".jpg,.png,.jpeg,.gif"
                        ></input>
                        <button
                          className="button-link position-absolute"
                          style={{
                            top: mobile ? "90px" : "155px",
                            left: mobile ? "145px" : "240px",
                          }}
                          onClick={deleteBannerImg}
                        >
                          <TalentProfilePicture
                            className="cursor-pointer"
                            src={DeleteButton}
                            height={40}
                          />
                        </button>
                      </>
                    )}
                    {isUploadingBanner ? (
                      <div class="h-100 d-flex justify-content-center align-items-center">
                        <Spinner className="mx-4" width={50} />
                      </div>
                    ) : (
                      <>
                        <label htmlFor="overviewBannerFileInput">
                          <TalentProfilePicture
                            className="position-absolute cursor-pointer"
                            style={{
                              top: mobile ? "90px" : "155px",
                              left: mobile ? "95px" : "185px",
                            }}
                            src={CameraButton}
                            height={40}
                          />
                        </label>
                        <input
                          id="overviewBannerFileInput"
                          className="d-none"
                          type="file"
                          accept=".jpg,.png,.jpeg,.gif"
                        ></input>
                        <button
                          className="button-link position-absolute"
                          style={{
                            top: mobile ? "90px" : "155px",
                            left: mobile ? "145px" : "240px",
                          }}
                          onClick={deleteBannerImg}
                        >
                          <TalentProfilePicture
                            className="cursor-pointer"
                            src={DeleteButton}
                            height={40}
                          />
                        </button>
                      </>
                    )}
                  </div>
                  <div
                    className="position-relative"
                    style={{ width: "120px", height: "120px" }}
                  >
                    {isUploadingProfile ? (
                      <div class="h-100 d-flex justify-content-center align-items-center">
                        <Spinner className="mx-4" width={50} />
                      </div>
                    ) : (
                      <>
                        <TalentProfilePicture
                          className="position-relative"
                          src={talent.profilePictureUrl}
                          height={120}
                          border
                        />
                        <label htmlFor="overviewProfileFileInput">
                          <TalentProfilePicture
                            className="position-absolute cursor-pointer"
                            style={{ top: "40px", left: "40px" }}
                            src={CameraButton}
                            height={40}
                          />
                        </label>
                        <input
                          id="overviewProfileFileInput"
                          className="d-none"
                          type="file"
                          accept=".jpg,.png,.jpeg"
                        ></input>
                      </>
                    )}
                  </div>
                </>
              )}
            </div>
          ) : (
            <>
              {previewMode || !canUpdate ? (
                <TalentProfilePicture
                  className="mb-3"
                  src={talent.profilePictureUrl}
                  height={120}
                />
              ) : (
                <div
                  className="position-relative mb-3"
                  style={{ width: "112px", height: "112px" }}
                >
                  {isUploadingProfile ? (
                    <div class="h-100 d-flex justify-content-center align-items-center">
                      <Spinner className="mx-4" width={50} />
                    </div>
                  ) : (
                    <>
                      <TalentProfilePicture
                        className="position-relative"
                        src={talent.profilePictureUrl}
                        height={112}
                      />
                      <div className="rounded-circle edit-image"></div>
                      <label htmlFor="overviewProfileFileInput">
                        <TalentProfilePicture
                          className="position-absolute cursor-pointer"
                          style={{ top: "36px", left: "36px" }}
                          src={CameraButton}
                          height={40}
                        />
                      </label>
                      <input
                        id="overviewProfileFileInput"
                        className="d-none"
                        type="file"
                        accept=".jpg,.png,.jpeg"
                      ></input>
                    </>
                  )}
                </div>
              )}
            </>
          )}
          <div className="d-flex align-items-center mb-1">
            <H4 className="medium mr-2 mb-0" text={talent.user.name} />
            {talent.talentToken.contractId && (
              <P2
                className="medium mr-2"
                text={`$${talent.talentToken.ticker}`}
              />
            )}
            {talent.verified && (
              <img
                src={verifiedIcon(mode())}
                style={{ width: "22px", height: "22px" }}
              />
            )}
          </div>
          <P2 className="text-primary-03 mb-4" text={talent.occupation} />
          {mobile && (
            <>
              <div className="d-flex align-items-center mb-4">
                {previewMode ? (
                  <Button
                    type="primary-default"
                    text="Back to edit profile"
                    onClick={() => setPreviewMode(false)}
                  />
                ) : (
                  <>
                    {canUpdate ? (
                      <>
                        {!talent.verified && (
                          <Button
                            className="mr-2"
                            type="primary-default"
                            onClick={() =>
                              setShowPersonaVerificationConfirmationModal(true)
                            }
                            disabled={
                              !talent.user.profileCompleted ||
                              talent.withPersonaId ||
                              withPersonaRequest.requests_counter >
                                railsContext.withPersonaVerificationsLimit
                            }
                          >
                            <div className="d-flex align-items-center">
                              Verify
                              <Tooltip
                                body={verifyTooltipBody()}
                                popOverAccessibilityId={"verify_tooltip"}
                                placement="top"
                              >
                                <Help
                                  className="cursor-pointer ml-1"
                                  color={lightTextPrimary03}
                                />
                              </Tooltip>
                            </div>
                          </Button>
                        )}
                        <Button
                          className="mr-2"
                          type="primary-default"
                          text="Edit"
                          onClick={() => setEditMode(true)}
                        />
                        {talent.talentToken.contractId && (
                          <Button
                            className="mr-2"
                            type="primary-default"
                            text={`Buy ${talent.talentToken.ticker}`}
                            onClick={() => setShowStakeModal(true)}
                          />
                        )}
                        <Button
                          className="mr-2"
                          type="white-outline"
                          text="Preview"
                          onClick={() => setPreviewMode(true)}
                        />
                      </>
                    ) : (
                      <>
                        <a
                          href={`/messages?user=${talent.user.id}`}
                          className="button-link"
                        >
                          <Button
                            className="mr-2"
                            type="white-outline"
                            size="big-icon"
                            onClick={() => null}
                          >
                            <Envelope
                              className="h-100"
                              color="currentColor"
                              size={16}
                              viewBox="0 0 24 24"
                            />
                          </Button>
                        </a>
                        {showFollowButton() && (
                          <Button
                            className="mr-2"
                            type="white-outline"
                            size="big"
                            text={talent.isFollowing ? "Unfollow" : "Follow"}
                            onClick={() => updateFollow()}
                          />
                        )}
                        {talent.talentToken.contractId && (
                          <Button
                            type="primary-default"
                            size="big"
                            text="Support"
                            onClick={() => setShowStakeModal(true)}
                          />
                        )}
                      </>
                    )}
                  </>
                )}
              </div>
              {(currentUserAdmin || currentUserModerator) && (
                <div className="d-flex flex-column mb-4">
                  {!talent.verified && (
                    <Button
                      className="mb-5"
                      type="primary-default"
                      size="big"
                      text="Verify"
                      onClick={() =>
                        setShowAdminVerificationConfirmationModal(true)
                      }
                    />
                  )}
                  {talent.user.profileType == "waiting_for_approval" && (
                    <>
                      <Button
                        className="mb-2"
                        type="primary-default"
                        size="big"
                        text={"Approve"}
                        onClick={() => setShowApprovalConfirmationModal(true)}
                      />
                      <Button
                        onClick={() => setShowRejectModal(true)}
                        type="white-subtle"
                        className="mb-5"
                      >
                        Reject
                      </Button>
                    </>
                  )}
                  {!isCurrentUserImpersonated && (
                    <Button
                      type="white-outline"
                      size="big"
                      text="Impersonate"
                      onClick={() => impersonateUser()}
                    />
                  )}
                </div>
              )}
            </>
          )}
          {talent.profile.headline && (
            <div className="d-flex flex-wrap mb-4">
              {talent.profile.highlightedHeadlineWordsIndex ? (
                <>
                  <H5 className="text-primary-01 mr-1" text="--E" />
                  {headlineArray.map((word, index) => {
                    if (
                      talent.profile.highlightedHeadlineWordsIndex.includes(
                        index
                      )
                    ) {
                      return <H5 className="text-primary mr-1" text={word} />;
                    } else {
                      return (
                        <H5 className="text-primary-01 mr-1" text={word} />
                      );
                    }
                  })}
                </>
              ) : (
                <H5
                  className="text-primary-01"
                  text={`--E ${talent.profile.headline}`}
                />
              )}
            </div>
          )}
          <UserTags
            tags={talent.tags.map((tag) => tag.description)}
            className="mr-2 mb-3"
          />
          <div className="mb-4 d-flex flex-wrap">
            <Button
              className="d-flex mr-2 mt-2 button-link p-0"
              onClick={() => changeSection("#token")}
            >
              <P2
                className="text-primary-01 mr-1"
                bold
                text={
                  talent.totalSupply
                    ? formatNumberWithSymbol(
                        ethers.utils.formatUnits(talent.totalSupply) *
                          talentTokenPrice
                      )
                    : "-"
                }
              />
              <P2 className="text-primary-04" text="Market Value" />
            </Button>
            <Button
              className="d-flex mr-2 mt-2 button-link p-0"
              onClick={() => changeSection("#community")}
            >
              <P2
                className="text-primary-01 mr-1"
                bold
                text={talent.supportersCount || "0"}
              />
              <P2 className="text-primary-04" text="Supporters" />
            </Button>
            <Button
              className="d-flex mr-2 mt-2 button-link p-0"
              onClick={() => changeSection("#community")}
            >
              <P2
                className="text-primary-01 mr-1"
                bold
                text={talent.supportingCount || "0"}
              />
              <P2 className="text-primary-04" text="Supporting" />
            </Button>
            <Button
              className="d-flex mr-2 mt-2 button-link p-0"
              onClick={() => changeSection("#community")}
            >
              <P2
                className="text-primary-01 mr-1"
                bold
                text={talent.followersCount || "0"}
              />
              <P2 className="text-primary-04" text="Followers" />
            </Button>
          </div>
          <div className="d-flex align-items-center mb-4">
            <div className="mr-4 d-flex align-items-center">
              <Globe className="mr-2" size={16} color={lightTextPrimary04} />
              <P2 className="text-primary-03" text={talent.profile.location} />
            </div>
            <div className="mr-4 d-flex align-items-center">
              <Calendar className="mr-2" size={16} color={lightTextPrimary04} />
              <P2 className="text-primary-03" text={`Joined ${joinedAt}`} />
            </div>
          </div>
          {talent.user.invitedBy && (
            <div className="d-flex align-items-center">
              <P2 className="text-primary-04 mr-3" text="Invited by" />
              <TalentProfilePicture
                className="mr-2"
                src={talent.user.invitedBy.profilePictureUrl}
                height={32}
              />
              <P2 bold text={talent.user.invitedBy.name} />
            </div>
          )}
          {currentUserAdmin && talent.user.approvedBy && (
            <div className="d-flex align-items-center mt-3">
              <P2 className="text-primary-04 mr-3" text="Approved by" />
              <TalentProfilePicture
                className="mr-2"
                src={talent.user.approvedBy.profilePictureUrl}
                height={32}
              />
              <P2 bold text={talent.user.approvedBy.name} />
            </div>
          )}
        </div>
        {!mobile && <div className="col-1"></div>}
        {!mobile && (
          <div
            className={cx(
              mobile ? "col-12" : "col-5 p-0",
              "d-flex flex-column align-items-center justify-content-center"
            )}
          >
            {previewMode || !canUpdate ? (
              <TalentProfilePicture
                className="banner-profile"
                src={talent.bannerUrl || TalentBanner}
                straight
              />
            ) : (
              <div className="position-relative">
                {isUploadingBanner ? (
                  <div class="h-100 d-flex justify-content-center align-items-center">
                    <Spinner className="mx-4" width={50} />
                  </div>
                ) : (
                  <>
                    <TalentProfilePicture
                      className="position-relative banner-profile cursor-pointer"
                      src={talent.bannerUrl || TalentBanner}
                      straight
                    />
                    <div
                      className="edit-image banner-profile"
                      style={{ borderRadius: "24px" }}
                    ></div>
                    <label htmlFor="overviewBannerFileInput">
                      <TalentProfilePicture
                        className="position-absolute cursor-pointer"
                        style={{ top: "145px", left: "160px" }}
                        src={CameraButton}
                        height={40}
                      />
                    </label>
                    <input
                      id="overviewBannerFileInput"
                      className="d-none"
                      type="file"
                      accept=".jpg,.png,.jpeg,.gif"
                    ></input>
                    <button
                      className="button-link position-absolute"
                      style={{ top: "145px", left: "210px" }}
                      onClick={deleteBannerImg}
                    >
                      <TalentProfilePicture
                        className="cursor-pointer"
                        src={DeleteButton}
                        height={40}
                      />
                    </button>
                  </>
                )}
              </div>
            )}
          </div>
        )}
      </div>
      <div className="d-flex align-items-center justify-content-between">
        <div>
          <SocialRow profile={talent.profile} />
        </div>
        {!mobile && (
          <div className="d-flex align-items-center">
            {(currentUserAdmin || currentUserModerator) && (
              <>
                {!talent.verified && (
                  <Button
                    className="mr-2"
                    size="big"
                    type="primary-default"
                    text="Verify"
                    onClick={() =>
                      setShowAdminVerificationConfirmationModal(true)
                    }
                  />
                )}
                {talent.user.profileType == "waiting_for_approval" && (
                  <>
                    <Button
                      className="mr-2"
                      size="big"
                      type="primary-default"
                      text="Approve"
                      onClick={() => setShowApprovalConfirmationModal(true)}
                    />
                    <Button
                      onClick={() => setShowRejectModal(true)}
                      size="big"
                      type="white-subtle"
                      className="mr-7"
                    >
                      Reject
                    </Button>
                  </>
                )}
                {!isCurrentUserImpersonated && (
                  <Button
                    className="mr-2"
                    type="white-outline"
                    size="big"
                    text="Impersonate"
                    onClick={() => impersonateUser()}
                  />
                )}
              </>
            )}
            {previewMode ? (
              <Button
                type="white-outline"
                text="Back to edit profile"
                onClick={() => setPreviewMode(false)}
              />
            ) : (
              <>
                {canUpdate ? (
                  <>
                    {!talent.verified && (
                      <Button
                        className="mr-2"
                        type="primary-default"
                        size="big"
                        onClick={() =>
                          setShowPersonaVerificationConfirmationModal(true)
                        }
                        disabled={
                          !talent.user.profileCompleted ||
                          talent.withPersonaId ||
                          withPersonaRequest.requests_counter >
                            railsContext.withPersonaVerificationsLimit
                        }
                      >
                        <div className="d-flex align-items-center">
                          Verify
                          <Tooltip
                            body={verifyTooltipBody()}
                            popOverAccessibilityId={"verify_tooltip"}
                            placement="top"
                          >
                            <Help
                              className="cursor-pointer ml-2"
                              color={lightTextPrimary03}
                            />
                          </Tooltip>
                        </div>
                      </Button>
                    )}
                    <Button
                      className="mr-2"
                      type="primary-default"
                      size="big"
                      text="Edit"
                      onClick={() => setEditMode(true)}
                    />
                    {talent.talentToken.contractId && (
                      <Button
                        className="mr-2"
                        type="primary-default"
                        size="big"
                        text={`Buy ${talent.talentToken.ticker}`}
                        onClick={() => setShowStakeModal(true)}
                      />
                    )}
                    <Button
                      className="mr-2"
                      type="white-outline"
                      size="big"
                      text="Preview"
                      onClick={() => setPreviewMode(true)}
                    />
                  </>
                ) : (
                  <>
                    <a
                      href={`/messages?user=${talent.user.id}`}
                      className="button-link"
                    >
                      <Button
                        className="mr-2"
                        type="white-outline"
                        size="big-icon"
                        onClick={() => null}
                      >
                        <Envelope
                          className="h-100"
                          color="currentColor"
                          size={16}
                          viewBox="0 0 24 24"
                        />
                      </Button>
                    </a>
                    {showFollowButton() && (
                      <Button
                        className="mr-2"
                        type="white-outline"
                        size="big"
                        text={talent.isFollowing ? "Unfollow" : "Follow"}
                        onClick={() => updateFollow()}
                      />
                    )}
                    {talent.talentToken.contractId && (
                      <Button
                        type="primary-default"
                        size="big"
                        text="Support"
                        onClick={() => setShowStakeModal(true)}
                      />
                    )}
                  </>
                )}
              </>
            )}
          </div>
        )}
      </div>
      <StakeModal
        show={showStakeModal}
        setShow={setShowStakeModal}
        tokenAddress={talent.talentToken.contractId}
        tokenId={talent.talentToken.id}
        userId={currentUserId}
        talentUserId={talent.userId}
        tokenChainId={talent.talentToken.chainId}
        talentName={talent.user.displayName || talent.user.username}
        ticker={talent.talentToken.ticker}
        talentIsFromCurrentUser={canUpdate}
        railsContext={railsContext}
      />
      <AdminVerificationConfirmationModal
        show={showAdminVerificationConfirmationModal}
        setShow={setShowAdminVerificationConfirmationModal}
        hide={() => setShowAdminVerificationConfirmationModal(false)}
        talent={talent}
        setTalent={setTalent}
      />
      <PersonaVerificationConfirmationModal
        show={showPersonaVerificationConfirmationModal}
        setShow={setShowPersonaVerificationConfirmationModal}
        hide={() => setShowPersonaVerificationConfirmationModal(false)}
        talent={talent}
        setTalent={setTalent}
        railsContext={railsContext}
      />
      <ApprovalConfirmationModal
        show={showApprovalConfirmationModal}
        setShow={setShowApprovalConfirmationModal}
        hide={() => setShowApprovalConfirmationModal(false)}
        talent={talent}
        setTalent={setTalent}
      />
      <RejectTalentModal
        show={showRejectModal}
        setShow={setShowRejectModal}
        mobile={mobile}
        mode={mode()}
        talent={talent}
        setTalent={setTalent}
      />
      {editMode && (
        <EditOverviewModal
          show={editMode}
          hide={() => setEditMode(false)}
          talent={talent}
          setTalent={setTalent}
        />
      )}
    </div>
  );
};

export default Overview;
