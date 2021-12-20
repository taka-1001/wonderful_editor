require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:headers) { current_user.create_new_auth_token }
  let(:current_user) { create(:user) }

  describe "GET api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    context "記事を作成するとき" do
      let!(:article1) { create(:article, :draft, user: current_user) }
      let!(:article2) { create(:article, :draft, user: current_user) }
      let!(:article3) { create(:article, :draft) }

      it "下書き状態の記事一覧を取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(res.length).to eq 2
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET api/v1/articles/drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "指定した id の記事が存在して" do
      let(:article_id) { article.id }

      context "対象の記事が下書き状態のとき" do
        let(:article) { create(:article, :draft, user: current_user) }
        # rubocop:disable RSpec/ExampleLength
        it "その記事の詳細を取得できる" do
          # rubocop:enable RSpec/ExampleLength
          subject
          res = JSON.parse(response.body)

          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["status"]).to eq article.status
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"].keys).to eq ["id", "name", "email"]
          expect(response).to have_http_status(:ok)
        end
      end

      context "対象の記事が他のユーザーが書いた下書きのとき" do
        let(:article) { create(:article, :draft) }

        it "記事が取得できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
