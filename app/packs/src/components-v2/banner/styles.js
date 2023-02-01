import styled from "styled-components";
import TalentProfilePicture from "src/components/talent/TalentProfilePicture";
import { margins } from "../shared-styles";

export const Container = styled.div`
    width: 100%;
    height: 290px;
    position: absolute;
    max-width: ${({ width }) => width > 1160 ? "1160px" : `calc(${width}px - 80px)`};

    @media (max-width: 991px) {
        max-width: calc(${({ width }) => width}px - 30px);
        height: 82px;
    }
`;

export const EditImagePositioner = styled.div`
    display: flex;
    justify-content: flex-end;
    align-items: flex-end;
    padding-right: 16px;
    gap: 8px;
    border-radius: 8px;
`;

export const SpinnerContainer = styled.div`
    position: absolute;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1;
`;

export const StyledLabel = styled.label`
    ${margins.mb24}

    @media (max-width: 991px) {
        ${margins.m8}
    }
`;

export const StyledButton = styled.label`
    ${margins.mb24}

    @media (max-width: 991px) {
        ${margins.mb8}
    }
`;

export const ProfilePicture = styled(TalentProfilePicture)`
    width: 100%;
    height: 100%;
    border-radius: 8px;
`;
