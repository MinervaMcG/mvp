import React, { useState, useEffect } from "react";
import { toast } from "react-toastify";
import { get } from "src/utils/requests";

import {
  P1,
  P3,
  H3,
  H4,
  H5,
  P2,
} from "src/components/design_system/typography";
import ThemedButton from "src/components/design_system/button";
import TalentProfilePicture from "src/components/talent/TalentProfilePicture";

import { ToastBody } from "src/components/design_system/toasts";
import { useWindowDimensionsHook } from "src/utils/window";
import { useTheme } from "src/contexts/ThemeContext";

import { lightTextPrimary01, darkTextPrimary01 } from "src/utils/colors.js";

import EditPerkModal from "src/components/profile/edit/EditPerkModal";
import CreatePerkModal from "src/components/profile/create/CreatePerkModal";

import cx from "classnames";

const Perks = ({ talent, canUpdate }) => {
  const [perks, setPerks] = useState([]);
  const [editShow, setEditShow] = useState(false);
  const [createShow, setCreateShow] = useState(false);
  const [editingPerk, setEditingPerk] = useState({});
  const { mobile } = useWindowDimensionsHook();
  const { mode } = useTheme();
  const token = talent.token;
  const user = talent.user;
  const userId = user.id;

  useEffect(() => {
    get(`/api/v1/users/${userId}/profile/perks`).then((response) => {
      if (response.error) {
        toast.error(<ToastBody heading="Error!" body={response.error} />);
        console.log(response.error);
      } else {
        setPerks(response.perks);
      }
    });
  }, [userId]);

  const removePerk = (deletedPerk) => {
    const previousPerks = perks;

    const perkIndex = previousPerks.findIndex(
      (perk) => perk.id === deletedPerk.id
    );

    const newPerks = [
      ...previousPerks.slice(0, perkIndex),
      ...previousPerks.slice(perkIndex + 1),
    ];

    setPerks(newPerks);
  };

  const appendPerk = (newPerk) => {
    setPerks((prev) => [...prev, newPerk]);
  };

  const mergePerk = (updatedPerk) => {
    const previousPerks = perks;
    const perkIndex = previousPerks.findIndex(
      (perk) => perk.id === updatedPerk.id
    );

    const newPerks = [
      ...previousPerks.slice(0, perkIndex),
      {
        ...previousPerks[perkIndex],
        ...updatedPerk,
      },
      ...previousPerks.slice(perkIndex + 1),
    ];

    setPerks(newPerks);
  };

  if (perks.length == 0 && !canUpdate) {
    return <></>;
  }

  const startEditing = (perk) => {
    setEditingPerk(perk);
    setEditShow(true);
  };

  return (
    <>
      {canUpdate && editShow && (
        <EditPerkModal
          talentId={talent.id}
          token={token}
          perk={editingPerk}
          mergePerk={mergePerk}
          removePerk={removePerk}
          show={editShow && canUpdate}
          closeModal={setEditShow}
          mobile={mobile}
          mode={mode}
        />
      )}
      {canUpdate && createShow && (
        <CreatePerkModal
          talentId={talent.id}
          token={token}
          show={createShow && canUpdate}
          appendPerk={appendPerk}
          closeModal={setCreateShow}
          mobile={mobile}
          mode={mode}
        />
      )}
      <section className="d-flex flex-column align-items-center my-7">
        <div className="container">
          <div
            className={cx(
              "d-flex w-100 mb-3 position-relative",
              mobile && "flex-column"
            )}
          >
            <H3 className="w-100 text-center mb-0">{`$${token.ticker}`}</H3>
            {perks.length != 0 && canUpdate && (
              <ThemedButton
                type="primary-default"
                onClick={() => setCreateShow(true)}
                className={cx(
                  mobile ? "mx-auto mt-3" : "ml-auto position-absolute"
                )}
                style={{ width: "190px", right: 0 }}
              >
                + Add new Perk
              </ThemedButton>
            )}
          </div>
          <P1 className="text-center pb-3">
            {`Perks that ${token.ticker} holders can claim and use whenever they want!`}
          </P1>
          {perks.length == 0 && canUpdate && (
            <div className="mt-7">
              <H5
                bold
                text={"You don't have any Perks."}
                className="text-primary-01 text-center mb-2"
              />
              <P2
                text={
                  "Now that $XPM is launched, create some utility by giving benefits for your supporters."
                }
                className="text-primary-03 text-center"
              />
              <div className="d-flex flex-column justify-content-center my-5">
                <ThemedButton
                  onClick={() => setCreateShow(true)}
                  type="primary-default"
                  className="mx-auto"
                >
                  Add Perks
                </ThemedButton>
              </div>
            </div>
          )}
          <div className="row d-flex flex-row justify-content-center mb-3">
            {perks.map((perk) => (
              <div
                className="col-12 col-md-4 mb-4"
                key={`perk_list_${perk.id}`}
              >
                <div className="card perk-card p-2">
                  <div className="header d-flex flex-column justify-content-between p-3">
                    <div className="d-flex align-items-center">
                      <TalentProfilePicture
                        src={user.profilePictureUrl}
                        height={24}
                      />
                      <P2
                        text={`$${token.ticker}`}
                        className="ml-2 text-uppercase"
                        bold
                        style={{
                          color:
                            mode == "light"
                              ? darkTextPrimary01
                              : lightTextPrimary01,
                        }}
                      />
                    </div>
                    <H4 bold text={perk.title} />
                  </div>
                  <div className="footer d-flex flex-column justify-content-between p-3">
                    <div>
                      <P3 text={"Title"} className="text-primary-04" />
                      <P2 text={perk.title} bold className="text-primary-01" />
                    </div>
                    <div className="position-relative">
                      <P3 text={"Hold Amount"} className="text-primary-04" />
                      <P2
                        text={`${perk.price} $${token.ticker}`}
                        bold
                        className="text-primary-01"
                      />
                      {canUpdate && (
                        <ThemedButton
                          onClick={() => startEditing(perk)}
                          type="primary-default"
                          className="position-absolute edit-perk-button"
                          style={{ right: 0, top: 0 }}
                        >
                          Edit
                        </ThemedButton>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  );
};

export default Perks;
