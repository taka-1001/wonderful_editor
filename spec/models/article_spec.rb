require "rails_helper"

RSpec.describe Article, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  context "title, body が作成される時" do
    let(:article) { build(:article) }
    it "記事が作成される" do
      expect(article).to be_valid
    end
  end

  context "title がない時" do
    let(:article) { build(:article, title: nil) }
    it "エラーする" do
      expect(article).not_to be_valid
    end
  end
end
