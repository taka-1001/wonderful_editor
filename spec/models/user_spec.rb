require "rails_helper"

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  context " name, email, password を指定している時 " do
    let(:user) { build(:user) }
    it " ユーザーが作られる " do
      expect(user).to be_valid
    end
  end

  context "name を指定されていない場合" do
    let(:user) { build(:user, name: nil) }
    it "エラーする" do
      expect(user).not_to be_valid
      # binding.pry
    end
  end
end
