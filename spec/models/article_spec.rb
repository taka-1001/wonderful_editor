require "rails_helper"

RSpec.describe Article, type: :model do
  context "title, body が作成されるとき" do
    let(:article) { build(:article) }
    it "下書き状態のが作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "status が下書き状態のとき" do
    let(:article) { build(:article, :draft) }
    it "記事を下書き状態で作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "status が公開状態のとき" do
    let(:article) { build(:article, :published) }
    it "記事を公開状態で作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "published"
    end
  end
end
