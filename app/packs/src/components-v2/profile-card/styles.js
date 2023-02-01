import styled from "styled-components";
import { H4, H3 } from "src/components/design_system/typography";
import UserTags from "src/components/talent/UserTags";
import { margins, paddings } from "../shared-styles";

export const Container = styled.section`
  display: flex;
  justify-content: space-between;
  ${margins.mt24}

  @media (max-width: 991px) {
    ${paddings.p0_24}
    flex-direction: column;
  }
`;

export const InfoColumn = styled.div`
  display: flex;
  flex-direction: column;
`;

export const DataRow = styled.div`
  display: flex;
  align-items: center;
`;

export const NameLabel = styled(H4)`
  margin-bottom: 4px;
`;

export const HeadlinePiece = styled(H3)`
  margin-bottom: 0;
`;

export const StyledUserTag = styled(UserTags)`
  margin-top: -8px;
`;

export const HeadlineContainer = styled.div`
  ${margins.mt24}
  max-width: 667px;
  display: flex;
  flex-wrap: wrap;
`;

export const TagsContainer = styled.div`
  ${margins.mt24}
  ${margins.mb16}
`;

export const TalentDetails = styled.div`
  ${margins.mb24}
  display: flex;
  flex-wrap: wrap;
`;

export const TalentUserDetails = styled.div`
  ${margins.mb24}
  display: flex;
  align-items: center;


  @media (max-width: 991px) {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
`;

export const TalentUserDetailsItem = styled.div`
  ${margins.mr32}
  display: flex;
  align-items: center;
`;

export const VerifiedIcon = styled.img`
  width: 22px;
  height: 22px;
`;

export const InvitedByContainer = styled.div`
  display: flex;
  align-items: center;
`;

export const ApprovedByContainer = styled.div`
  ${margins.mb24}
  display: flex;
  align-items: center;
`;

export const ActionArea = styled.div`
  display: flex;
  align-self: flex-start;
  margin-top: -44px;

  @media (max-width: 991px) {
    ${margins.mt24}
  }
`;
