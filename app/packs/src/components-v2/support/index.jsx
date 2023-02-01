import React, { useMemo } from "react";
import { Input } from "src/components-v2/shared-styles/input";
import { Avatar } from "src/components-v2/shared-styles/avatar";
import { useSupportToolUtils } from "./hooks/use-support-tool-utils";
import { Container, ListContainer, ProfileContainer } from "./styles";

export const Support = () => {
  const utils = useSupportToolUtils();
  const usersList = useMemo(
    () =>
      utils.users.map(user => (
        <ProfileContainer href={`/support/user/${user.id}`} key={user.id}>
          <Avatar src={user.profilePictureUrl} userOrTalentId={user.id} />
          <div>
            {user.id} - {user.username}
          </div>
        </ProfileContainer>
      )),
    [utils.users]
  );
  return (
    <Container>
      <Input onChangeCallback={utils.updateSearchData} />
      <ListContainer>{usersList}</ListContainer>
    </Container>
  );
};

export default Support;
