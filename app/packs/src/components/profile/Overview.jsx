import React, { useState, useEffect } from "react";
import dayjs from "dayjs";

import { ethers } from "ethers";
import { patch, getAuthToken } from "src/utils/requests";
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
import { Globe, Calendar, Envelope } from "src/components/icons";
import { lightTextPrimary04 } from "src/utils/colors";

import { formatNumberWithSymbol, verifiedIcon } from "src/utils/viewHelpers";
import EditOverviewModal from "src/components/profile/edit/EditOverviewModal";

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
  railsContext,
  changeSection,
  canUpdate,
  previewMode,
  setPreviewMode,
}) => {
  const joinedAt = dayjs(talent.user.createdAt).format("MMMM YYYY");

  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();
  const [showStakeModal, setShowStakeModal] = useState(false);
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

  const approveUser = async () => {
    const params = {
      user: {
        id: talent.user.id,
        profile_type: "approved",
      },
    };

    const response = await patch(`/api/v1/talent/${talent.id}`, params).catch(
      () => {
        return false;
      }
    );

    if (response && !response.error) {
      setTalent((prev) => ({
        ...prev,
        user: { ...prev.user, profileType: "approved" },
      }));

      toast.success(
        <ToastBody heading="Success!" body={"User approved successfully."} />,
        { autoClose: 1500 }
      );

      return true;
    }
  };

  const verifyTalent = async () => {
    const params = {
      talent: {
        verified: true,
      },
      user: {
        id: talent.user.id,
      },
    };

    const response = await patch(`/api/v1/talent/${talent.id}`, params).catch(
      () => {
        return false;
      }
    );

    if (response && !response.error) {
      setTalent((prev) => ({
        ...prev,
        verified: true,
      }));

      toast.success(
        <ToastBody heading="Success!" body={"User verified successfully."} />,
        { autoClose: 1500 }
      );
      return true;
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
                  </div>
                  <div
                    className="position-relative"
                    style={{ width: "120px", height: "120px" }}
                  >
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
                </div>
              )}
            </>
          )}
          <div className="d-flex align-items-center mb-1">
            <H4 className="medium mr-2 mb-0" text={talent.user.name} />
            {talent.token.contractId && (
              <P2 className="medium mr-2" text={`$${talent.token.ticker}`} />
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
                        <Button
                          className="mr-2"
                          type="primary-default"
                          text="Edit"
                          onClick={() => setEditMode(true)}
                        />
                        {talent.token.contractId && (
                          <Button
                            className="mr-2"
                            type="primary-default"
                            text={`Buy ${talent.token.ticker}`}
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
                        {talent.token.contractId && (
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
              {currentUserAdmin && (
                <div className="d-flex mb-4">
                  {talent.user.profileType == "waiting_for_approval" && (
                    <Button
                      className="mr-2"
                      type="white-outline"
                      size="big"
                      text={"Approve"}
                      onClick={() => approveUser(true)}
                    />
                  )}
                  {!talent.verified && (
                    <Button
                      type="primary-default"
                      size="big"
                      text="Verify"
                      onClick={() => verifyTalent()}
                    />
                  )}
                </div>
              )}
            </>
          )}
          <H5
            className="text-primary-01 mb-4"
            text={`--E ${talent.headline || ""}`}
          />
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
        </div>
        {!mobile && <div className="col-1"></div>}
        {!mobile && (
          <div
            className={cx(
              mobile ? "col-12" : "col-5 p-0",
              "d-flex flex-column align-items-end justify-content-center"
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
              </div>
            )}
          </div>
        )}
      </div>
      <div className="d-flex align-items-center justify-content-between">
        <div></div>
        {!mobile && (
          <div className="d-flex align-items-center">
            {currentUserAdmin && (
              <>
                {!talent.verified && (
                  <Button
                    className="mr-2"
                    size="big"
                    type="primary-default"
                    text="Verify"
                    onClick={() => verifyTalent()}
                  />
                )}
                {talent.user.profileType == "waiting_for_approval" && (
                  <Button
                    className="mr-7"
                    size="big"
                    type="white-outline"
                    text="Approve"
                    onClick={() => approveUser(true)}
                  />
                )}
              </>
            )}
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
                    <Button
                      className="mr-2"
                      type="primary-default"
                      size="big"
                      text="Edit"
                      onClick={() => setEditMode(true)}
                    />
                    {talent.token.contractId && (
                      <Button
                        className="mr-2"
                        type="primary-default"
                        size="big"
                        text={`Buy ${talent.token.ticker}`}
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
                    {talent.token.contractId && (
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
        tokenAddress={talent.token.contractId}
        tokenId={talent.token.id}
        userId={currentUserId}
        talentUserId={talent.userId}
        tokenChainId={talent.token.chainId}
        talentName={talent.user.displayName || talent.user.username}
        ticker={talent.token.ticker}
        talentIsFromCurrentUser={canUpdate}
        railsContext={railsContext}
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
