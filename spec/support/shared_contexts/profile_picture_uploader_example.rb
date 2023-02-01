RSpec.shared_examples "a profile picture uploader" do
  it "persists the profile picture to the user's talent" do
    subject

    aggregate_failures do
      expect(Down).to have_received(:open).with("profile_picture_url").at_least(:once)
      expect(talent).to have_received(:profile_picture=).with(chunked_io)
    end
  end
end
