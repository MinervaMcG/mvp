import React, { useMemo } from "react";
import { ethers } from "ethers";
import dayjs from "dayjs";
import SocialRow from "src/components/profile/SocialRow";
import customParseFormat from "dayjs/plugin/customParseFormat";
import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import { formatNumberWithSymbol, verifiedIcon } from "src/utils/viewHelpers";
import { Globe, Calendar } from "src/components/icons";
import { P2 } from "src/components/design_system/typography";
import { useTheme } from "src/contexts/ThemeContext";
import Button from "src/components/design_system/button";
import { lightTextPrimary04 } from "src/utils/colors";
import {
  Container,
  InfoColumn,
  DataRow,
  NameLabel,
  HeadlinePiece,
  StyledUserTag,
  VerifiedIcon,
  ActionArea,
  TagsContainer,
  TalentDetails,
  TalentUserDetails,
  HeadlineContainer,
  TalentUserDetailsItem,
  InvitedByContainer,
  ApprovedByContainer,
} from "./styles";

dayjs.extend(customParseFormat);

export const ProfileCard = ({
  talent,
  changeSection,
  currentUserAdmin,
  talentTokenPrice,
  mobile,
  children,
}) => {
  const { mode } = useTheme();
  const joinedAt = useMemo(() => {
    return dayjs(talent.user.createdAt).format("MMMM YYYY");
  }, [talent.user.createdAt]);
  const Headline = useMemo(() => {
    if (!talent.profile.headline) return <></>;
    const headlineArray = talent.profile.headline?.split(" ");
    if (talent.profile.highlightedHeadlineWordsIndex)
      return (
        <>
          <HeadlinePiece className="text-primary-01 mr-1" text="--E" />
          {headlineArray.map((word, index) => {
            if (talent.profile.highlightedHeadlineWordsIndex.includes(index))
              return <HeadlinePiece className="text-primary mr-1" text={word} />;
            return <HeadlinePiece className="text-primary-01 mr-1" text={word} />;
          })}
        </>
      );
    return (
      <HeadlinePiece className="text-primary-01" text={`--E ${talent.profile.headline}`} />
    );
  }, [talent.profile.headline]);
  return (
    <Container>
      <InfoColumn>
        <DataRow>
          <NameLabel className="medium mr-2" text={talent.user.name} />
          {talent.verified && <VerifiedIcon src={verifiedIcon(mode())} />}
        </DataRow>
        <DataRow>
          {talent.talentToken.contractId && (
            <P2
              className="medium mr-2"
              text={`$${talent.talentToken.ticker}`}
            />
          )}
          <P2 className="text-primary-03" text={talent.occupation} />
        </DataRow>
        {mobile && <ActionArea>{children}</ActionArea>}
        <HeadlineContainer>{Headline}</HeadlineContainer>
        <TagsContainer>
          <StyledUserTag
            tags={talent.tags.map((tag) => tag.description)}
            className="mr-2"
          />
        </TagsContainer>
        <TalentDetails>
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
        </TalentDetails>
        <TalentUserDetails>
          <TalentUserDetailsItem>
            <Globe className="mr-2" size={16} color={lightTextPrimary04} />
            <P2 className="text-primary-03" text={talent.profile.location} />
          </TalentUserDetailsItem>
          <TalentUserDetailsItem>
            <Calendar className="mr-2" size={16} color={lightTextPrimary04} />
            <P2 className="text-primary-03" text={`Joined ${joinedAt}`} />
          </TalentUserDetailsItem>
          {talent.user.invitedBy && (
            <InvitedByContainer>
              <P2 className="text-primary-04 mr-3" text="Invited by" />
              <TalentProfilePicture
                className="mr-2"
                src={talent.user.profilePictureUrl}
                height={32}
              />
              <P2 bold text={talent.user.invitedBy.name} />
            </InvitedByContainer>
          )}
          {currentUserAdmin && talent.user.approvedBy && (
            <ApprovedByContainer>
              <P2 className="text-primary-04 mr-3" text="Approved by" />
              <TalentProfilePicture
                className="mr-2"
                src={talent.user.approvedBy.profilePictureUrl}
                height={32}
              />
              <P2 bold text={talent.user.approvedBy.name} />
            </ApprovedByContainer>
          )}
        </TalentUserDetails>
        <SocialRow profile={talent.profile} />
      </InfoColumn>
      {!mobile && <ActionArea>{children}</ActionArea>}
    </Container>
  );
};
