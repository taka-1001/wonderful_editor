require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /api/v1/articles" do
    subject { get(api_v1_articles_path) }

    context "3つの記事を作成するとき" do
      let!(:article1) { create(:article, updated_at: 1.day.ago) }
      let!(:article2) { create(:article, updated_at: 2.day.ago) }
      let!(:article3) { create(:article) }

      it "記事一覧を取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
        expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
