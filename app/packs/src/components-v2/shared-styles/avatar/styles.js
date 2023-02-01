import styled, { css } from "styled-components";

export const StyledImage = styled.img`
  width: 50px;
  height: 50px;
  border-radius: 50px;
  ${({ size }) => css`
    width: ${size}px;
    height: ${size}px;
    border-radius: ${size}px;
  `}
`;
