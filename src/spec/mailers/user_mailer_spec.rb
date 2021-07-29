require "rails_helper"

describe UserMailer do
  
  describe "account_activation" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.account_activation(user) }

    before do
      mail.deliver_now
      # user.activation_token = User.new_token
    end

    describe "when send email" do
      it { expect(mail.subject).to eq('Account activation') }
      it { expect(mail.from.first).to eq('noreply@example.com') }
      it { expect(mail.to.first).to eq(user.email) }
      it { expect(mail.body.encoded).to have_content(user.name) }
      it { expect(mail.body.encoded).to have_link("Activate", href: edit_account_activation_url(user.activation_token, email: user.email)) }
    end


    # it "renders the headers" do
    #   expect(mail.subject).to eq("Account activation")
    #   expect(mail.to).to eq(["to@example.org"])
    #   expect(mail.from).to eq(["from@example.com"])
    # end

    # it "renders the body" do
    #   expect(mail.body.encoded).to match("Hi")
    # end
  end

  # describe "password_reset" do
  #   let(:mail) { UserMailer.password_reset }

  #   it "renders the headers" do
  #     expect(mail.subject).to eq("Password reset")
  #     expect(mail.to).to eq(["to@example.org"])
  #     expect(mail.from).to eq(["from@example.com"])
  #   end

  #   it "renders the body" do
  #     expect(mail.body.encoded).to match("Hi")
  #   end
  # end

end
