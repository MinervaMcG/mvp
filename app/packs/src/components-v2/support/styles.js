import styled from "styled-components";
import { colors, paddings } from "../shared-styles";

export const Container = styled.section`
  max-width: 1160px;
  display: flex;
  flex-direction: column;

  gap: 16px;
`;

export const ListContainer = styled.div`
  display: flex;
  flex-wrap: wrap;
`;

export const ProfileContainer = styled.a`
  flex-basis: 360px;
  display: flex;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  transition-duration: 0.5s;
  border-radius: 8px;
  text-decoration: none;
  color: ${colors.black};
  ${paddings.p16}

  &:hover {
    text-decoration: none;
    color: ${colors.lightTextPrimary03};
  }
`;
