import React from "react";
import { Avatar } from "src/components-v2/shared-styles/avatar";
import { Container, DataItem, DataRow, DataTitle, Username, ClickableDataRow } from "./styles";

export const UserSupportPage = ({ user, userData, supportings, supporteds, totalRewards }) => {
  return (
    <Container>
      <Avatar src={userData.profilePictureUrl} userOrTalentId={user.id} size={120} />
      <Username>{userData.name}</Username>
      <DataRow>
        <DataTitle>Created at: </DataTitle>
        <DataItem>{new Date(user.created_at).toLocaleString()}</DataItem>
      </DataRow>
      <DataRow>
        <DataTitle>Account confirmed: </DataTitle>
        <DataItem>{new Date(user.email_confirmed_at).toLocaleString()}</DataItem>
      </DataRow>
      <DataRow>
        <DataTitle>Email: </DataTitle>
        <DataItem>{user.email}</DataItem>
      </DataRow>
      <DataRow>
        <DataTitle>Wallet: </DataTitle>
        <DataItem>{`${user.wallet_id}`}</DataItem>
      </DataRow>
      <DataRow>
        <DataTitle>Total Rewards: </DataTitle>
        <DataItem>
          {`${totalRewards}`} <b>TAL</b>
        </DataItem>
      </DataRow>
      <DataRow>
        <DataTitle>Portfolio: </DataTitle>
        {!supportings.length && <DataItem>N/A</DataItem>}
      </DataRow>
      {!!supportings.length &&
        supportings.map((transaction, index) => (
          <ClickableDataRow key={transaction.id} hasMarginLeft href={`/support/user/${supporteds[index].id}`}>
            <DataItem>
              <b>
                <u>username</u>
              </b>
              : {supporteds[index].username}
            </DataItem>
            <DataItem>
              <b>
                <u>id</u>
              </b>
              : {supporteds[index].id}
            </DataItem>
            <DataItem>
              <b>
                <u>amount</u>
              </b>
              : {transaction.amount}
            </DataItem>
          </ClickableDataRow>
        ))}
    </Container>
  );
};

export default UserSupportPage;
