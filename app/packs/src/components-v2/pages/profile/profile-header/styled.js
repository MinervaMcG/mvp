import { Typography, mobileStyles } from "@talentprotocol/design-system";
import styled, { css } from "styled-components";

export const SpinnerContainer = styled.section`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  margin: 0 16px;
  padding-top: 16px;
  width: 100%;
`;

export const Container = styled.section`
  display: flex;
  flex-direction: column;
  padding-top: 16px;
  gap: 8px;

  ${mobileStyles(css`
    margin: 0 16px;
  `)}
`;

export const TopRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
`;

export const Name = styled(Typography)`
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 220px;
`;

export const Actions = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 8px;
`;

export const UserInfo = styled.div`
  display: flex;
  align-items: center;
  gap: 4px;
`;

export const TagContainer = styled.div`
  display: flex;
`;

export const LocationContainer = styled.div`
  padding-top: 8px;
  display: flex;
  gap: 4px;
  align-items: center;
`;

export const MembersContainer = styled.div`
  display: flex;
  gap: 4px;
  padding: 8px 0 16px;
  align-items: center;
`;

export const DesktopActions = styled.div`
  display: flex;
  justify-content: flex-start;
  padding-top: 6px;
  gap: 8px;
`;
