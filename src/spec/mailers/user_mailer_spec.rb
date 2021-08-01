require "rails_helper"

describe UserMailer do
  
  describe "account_activation" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.account_activation(user) }

    before do
      user.activation_token = User.new_token
      mail.deliver_now
    end

    describe "when send account_activation email" do
      it { expect(mail.subject).to eq('Account activation') }
      it { expect(mail.from.first).to eq('noreply@example.com') }
      it { expect(mail.to.first).to eq(user.email) }
      it { expect(mail.body.encoded).to have_content(user.name) }
      it { expect(mail.body.encoded).to have_link("Activate", href: edit_account_activation_url(user.activation_token, email: user.email)) }
    end
  end
  
  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.password_reset(user) }
    
    before do
      user.reset_token = User.new_token
      mail.deliver_now
    end
    
    describe "when send password_reset email" do
      it { expect(mail.subject).to eq('Password reset') }
      it { expect(mail.from.first).to eq('noreply@example.com') }
      it { expect(mail.to.first).to eq(user.email) }
      it { expect(mail.body.encoded).to have_link("Reset password", href: edit_password_reset_url(user.reset_token, email: user.email)) }
    end
  end

end
