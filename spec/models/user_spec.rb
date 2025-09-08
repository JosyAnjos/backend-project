require 'rails_helper'

describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'associations' do
    it { should have_one(:cart) }
  end

  describe 'callbacks' do
    it 'generates an authentication_token before creation' do
      user = create(:user)
      expect(user.authentication_token).to be_present
    end
  end
end
