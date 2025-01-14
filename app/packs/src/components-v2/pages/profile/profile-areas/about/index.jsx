import React, { useEffect, useState } from "react";
import { Icon, Spinner, Typography } from "@talentprotocol/design-system";
import { talentsService } from "src/api";
import { Container, Divider, SpinnerContainer, EmptyStateContainer } from "./styled";
import { AboutMe } from "./about-me";
import { CurrentRole } from "./current-role";
import { Tags } from "./tags";
import { OnTheWeb } from "./on-the-web";
import { SupportData } from "./support-data";

const isProfileEmpty = aboutData =>
  !(
    aboutData.about ||
    aboutData.current_position ||
    aboutData.tags.length ||
    aboutData.social_links.some(linkObject => !!linkObject.link)
  );

export const About = ({ currentUser, urlData }) => {
  const [aboutData, setAboutData] = useState(null);
  const [supportData, setSupportData] = useState(null);

  useEffect(() => {
    if (!urlData.profileUsername) return;
    talentsService.getAbout(urlData.profileUsername).then(({ data }) => {
      setAboutData(data.talent);
    });
  }, []);

  useEffect(() => {
    if (!urlData.profileUsername) return;
    talentsService.getSupportData(urlData.profileUsername).then(({ data }) => {
      setSupportData(data.talent);
    });
  }, []);

  return !aboutData ? (
    <SpinnerContainer>
      <Spinner color="primary" size={48} />
    </SpinnerContainer>
  ) : (
    <Container>
      {isProfileEmpty(aboutData) ? (
        <EmptyStateContainer>
          <Icon name="binoculars" size={64} color="primary04" />
          <Typography specs={{ type: "regular", variant: "p1" }} color="primary04">
            Currently a blank slate, but soon to be filled with adventures, thoughts, and all things.
          </Typography>
        </EmptyStateContainer>
      ) : (
        <>
          {aboutData.about && <AboutMe pitch={aboutData.about} />}
          <CurrentRole
            position={aboutData.current_position}
            username={urlData.profileUsername}
            isOwner={urlData?.profileUsername === currentUser?.username}
          />
          {!!aboutData.tags.length && <Tags tags={aboutData.tags} />}
          <OnTheWeb links={aboutData.social_links} />
        </>
      )}
      <Divider />
      <SupportData {...supportData} />
    </Container>
  );
};
