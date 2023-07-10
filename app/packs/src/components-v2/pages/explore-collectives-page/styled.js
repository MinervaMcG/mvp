import { mobileStyles } from "@talentprotocol/design-system";
import styled, { css } from "styled-components";

export const CardsContainer = styled.div`
  display: flex;
  gap: 24px;
  justify-content: space-around;

  ${mobileStyles(css`
    flex-direction: column;
    align-items: center;
    justify-content: center;
  `)}
`;

export const Container = styled.div`
  padding-bottom: 40px;

  ${mobileStyles(css`
    padding: 1.5rem;
  `)}
`;

export const EmptyStateContainer = styled.div`
  display: flex;
  justify-content: center;
  margin-top: 48px;
`;

export const Header = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: center;
  margin-bottom: 59px;
  padding-top: 24px;

  ${mobileStyles(css`
    margin-bottom: 40px;
  `)}
`;

export const LoadMoreButtonContainer = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 32px;
`;