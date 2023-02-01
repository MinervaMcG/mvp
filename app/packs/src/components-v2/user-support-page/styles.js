import styled, { css } from "styled-components";
import { colors, margins } from "../shared-styles";

export const Container = styled.section`
  max-width: 1160px;
  display: flex;
  flex-direction: column;

  gap: 16px;
`;

export const Username = styled.h3``;

export const DataRow = styled.div`
  display: flex;
  gap: 16px;
  ${({ hasMarginLeft }) => css`
    ${hasMarginLeft && margins.ml24}
  `}
`;

export const ClickableDataRow = styled.a`
  display: flex;
  gap: 16px;
  text-decoration: none;
  color: ${colors.black};
  ${({ hasMarginLeft }) => css`
    ${hasMarginLeft && margins.ml24}
  `}

  &:hover {
    text-decoration: none;
    color: ${colors.lightTextPrimary03};
  }
`;

export const DataTitle = styled.span`
  font-weight: 700;
`;

export const DataItem = styled.span``;
