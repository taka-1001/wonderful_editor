require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  let(:headers) { current_user.create_new_auth_token }
  let(:current_user) { create(:user) }

  describe "GET api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    context "複数の記事が存在するとき" do
      let!(:article1) { create(:article, :published, user: current_user, updated_at: 1.day.ago) }
      let!(:article2) { create(:article, :published, user: current_user, updated_at: 2.day.ago) }
      let!(:article3) { create(:article, :published, user: current_user) }

      before do
        create(:article, :draft, user: current_user)
        create(:article, :published)
      end

      it "自分の公開記事を更新順に取得できる" do
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
