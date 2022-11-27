import React, { useState, useEffect } from "react";

import { patch, getAuthToken } from "src/utils/requests";
import { snakeCaseObject, camelCaseObject } from "src/utils/transformObjects";

import Uppy from "@uppy/core";
import AwsS3Multipart from "@uppy/aws-s3-multipart";

import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import CameraButton from "images/camera-button.png";
import DeleteButton from "images/delete-button.png";
import AboutImage from "images/open-to.gif";
import { H4, P1 } from "src/components/design_system/typography";
import { useWindowDimensionsHook } from "src/utils/window";
import UserTags from "src/components/talent/UserTags";
import Button from "src/components/design_system/button";
import { Spinner } from "src/components/icons";
import EditAboutwModal from "src/components/profile/edit/EditAboutModal";

import cx from "classnames";

const About = ({ className, talent, setTalent, canUpdate, previewMode }) => {
  const { mobile } = useWindowDimensionsHook();
  const [isUploading, setIsUploading] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [aboutBannerFileInput, setAboutBannerFileInput] = useState(null);

  const imageSrc = talent.careerGoal.imageUrl || AboutImage;

  const uppyBanner = new Uppy({
    meta: { type: "avatar" },
    restrictions: {
      maxFileSize: 5120000,
      allowedFileTypes: [".jpg", ".png", ".jpeg", ".gif"],
    },
    autoProceed: true,
  });

  uppyBanner.use(AwsS3Multipart, {
    limit: 4,
    companionUrl: "/",
    companionHeaders: {
      "X-CSRF-Token": getAuthToken(),
    },
  });

  aboutBannerFileInput?.addEventListener("change", (event) => {
    setIsUploading(true);
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
        setIsUploading(false);
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
    const response = await patch(
      `/api/v1/talent/${talent.id}/career_goals/${talent.careerGoal.id}`,
      {
        talent: {
          ...snakeCaseObject(updatedTalent),
        },
        career_goal: {
          ...snakeCaseObject(updatedTalent.careerGoal),
        },
      }
    );

    if (response) {
      setTalent((prev) => ({
        ...prev,
        careerGoal: {
          ...prev.careerGoal,
          ...camelCaseObject(response),
        },
      }));
    }
  };

  const deleteBannerImg = () => {
    saveProfile({
      ...talent,
      careerGoal: {
        ...talent.careerGoal,
        imageUrl: null,
        imageData: null,
      },
    });
  };

  useEffect(() => {
    uppyBanner.on("restriction-failed", () => {
      uppyBanner.reset();
    });
    uppyBanner.on("upload-success", (file, response) => {
      setIsUploading(false);
      saveProfile({
        ...talent,
        careerGoal: {
          ...talent.careerGoal,
          imageUrl: response.uploadURL,
          imageData: {
            id: response.uploadURL.match(/\/cache\/([^\?]+)/)[1], // extract key without prefix
            storage: "cache",
            metadata: {
              size: file.size,
              filename: file.name,
              mime_type: file.type,
            },
          },
        },
      });
    });
    uppyBanner.on("upload", () => {});
  }, [uppyBanner]);

  useEffect(() => {
    setAboutBannerFileInput(document.getElementById("aboutBannerFileInput"));
  }, []);

  return (
    <div className={cx(className, mobile ? "" : "d-flex")}>
      <div
        className={cx(
          mobile ? "col-12 d-flex justify-content-center" : "col-6"
        )}
      >
        {previewMode || !canUpdate ? (
          <TalentProfilePicture
            className="mb-3"
            src={imageSrc}
            height={mobile ? 230 : 350}
            width={mobile ? 328 : 469}
            straight
            style={{ borderRadius: "24px" }}
          />
        ) : (
          <div className="h-100 position-relative mb-3">
            { isUploading ? (
              <div class="h-100 d-flex justify-content-center align-items-center">
                <Spinner
                  className="mx-4"
                  width={50}
                />
              </div>
            ) : (
              <>
                <TalentProfilePicture
                className="position-relative cursor-pointer"
                style={{ borderRadius: "24px" }}
                src={imageSrc}
                height={mobile ? 230 : 350}
                width={mobile ? 328 : 469}
                straight
              />
              <div
                className="edit-image"
                style={{
                  borderRadius: "24px",
                  height: mobile ? "230px" : "350px",
                  width: mobile ? "328px" : "469px",
                }}
              ></div>
              <label htmlFor="aboutBannerFileInput">
                <TalentProfilePicture
                  className="position-absolute cursor-pointer"
                  style={{
                    top: mobile ? "100px" : "155px",
                    left: mobile ? "110px" : "185px",
                  }}
                  src={CameraButton}
                  height={40}
                />
              </label>
              <input
                id="aboutBannerFileInput"
                className="d-none"
                type="file"
                accept=".jpg,.png,.jpeg,.gif"
              ></input>
              <button
                className="button-link position-absolute"
                style={{
                  top: mobile ? "100px" : "155px",
                  left: mobile ? "165px" : "240px",
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
        )}
      </div>
      <div
        className={cx(
          mobile ? "col-12" : "col-6",
          "d-flex flex-column justify-content-center"
        )}
      >
        <div>
          <div className="mb-4 d-flex align-items-center">
            <H4 className="mr-4 mb-0" text="I'm open to" />
            {canUpdate && (
              <Button
                type="primary-default"
                size="big"
                text="Edit"
                onClick={() => setEditMode(true)}
              />
            )}
          </div>
          <UserTags
            tags={talent.careerGoal.careerNeeds.map((need) => need.title)}
            className="mr-2 mb-4"
            clickable={false}
            talent_id={"show-about"}
          />
        </div>
        <P1 text={talent.careerGoal.pitch} />
      </div>
      {editMode && (
        <EditAboutwModal
          show={editMode}
          hide={() => setEditMode(false)}
          talent={talent}
          setTalent={setTalent}
        />
      )}
    </div>
  );
};

export default About;
