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

  describe "GET /api/v1/article/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在するとき" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }

      it "その記事の詳細を取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "指定した id の記事が存在しないとき" do
      let(:article_id) { 10000 }

      it "エラーする" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /api/v1/articles" do
    subject { post(api_v1_articles_path, params: params) }

    context "ログインユーザーが適切なパラメーターを送信したとき" do
      let(:params) { { article: attributes_for(:article) } }
      let(:current_user) { create(:user) }
      # rubocop:disable RSpec/AnyInstance
      before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }
      # rubocop:enable RSpec/AnyInstance

      it "記事のレコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインユーザーがいないとき" do
      let(:params) { { article: attributes_for(:article) } }

      it "エラーする" do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end
end
