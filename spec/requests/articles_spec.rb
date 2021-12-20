require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /api/v1/articles" do
    subject { get(api_v1_articles_path) }

    context "3つの記事を作成するとき" do
      let!(:article1) { create(:article, :published, updated_at: 1.day.ago) }
      let!(:article2) { create(:article, :published, updated_at: 2.day.ago) }
      let!(:article3) { create(:article, :published) }

      before { create(:article, :draft) }

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

    context "指定した id の記事が存在して" do
      let(:article_id) { article.id }

      context "対象の記事が公開状態のとき" do
        let(:article) { create(:article, :published) }

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

      context "指定した id の記事が下書き状態のとき" do
        let(:article) { create(:article, :draft) }

        it "記事が取得できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
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
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    context "ログインしているユーザーが" do
      let(:headers) { current_user.create_new_auth_token }
      let(:current_user) { create(:user) }

      context "下書き状態で記事を作成するとき" do
        let(:params) { { article: attributes_for(:article, :draft) } }

        it "下書き記事を作成できる" do
          expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
          res = JSON.parse(response.body)
          expect(res["title"]).to eq params[:article][:title]
          expect(res["body"]).to eq params[:article][:body]
          expect(response).to have_http_status(:ok)
        end
      end

      context "公開状態で記事を作成するとき" do
        let(:params) { { article: attributes_for(:article, :published) } }

        it "公開記事を作成できる" do
          expect { subject }.to change { Article.count }.by(1)
          res = JSON.parse(response.body)
          expect(res["status"]).to eq params[:article][:status]
          expect(response).to have_http_status(:ok)
        end
      end

      context "ない値で記事を作成するとき" do
        let(:params) { { article: attributes_for(:article, status: "private") } }

        it "記事を作成できない" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    context "ログインユーザーがいないとき" do
      let(:params) { { article: attributes_for(:article) } }

      it "記事を作成できない" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/v1/article/:id" do
    subject { patch(api_v1_article_path(article_id), params: params, headers: headers) }

    let(:article_id) { article.id }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "ログインユーザーが下書き記事を更新しようとしたとき" do
      let(:params) { { article: attributes_for(:article, :published) } }
      let!(:article) { create(:article, :draft, user: current_user) }

      it "下書き記事を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status].to_s)
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインユーザーが公開記事を更新しようとしたとき" do
      let(:params) { { article: attributes_for(:article, :draft) } }
      let!(:article) { create(:article, :published, user: current_user) }

      it "公開記事を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status].to_s)
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインユーザーがない値で記事を更新しようとしたとき" do
      let(:params) { { article: attributes_for(:article, status: "private") } }
      let(:article) { create(:article, user: current_user) }

      it "記事の更新ができない" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context "ログインユーザーでない人が記事を更新しようとしたとき" do
      # rubocop:enable RSpec/MultipleMemoizedHelpers
      let(:other_user) { create(:user) }
      let(:params) { { article: attributes_for(:article) } }
      let(:article) { create(:article, user: other_user) }

      it "記事の更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        change { Article.count }.by(0)
      end
    end
  end

  describe "DELETE /api/v1/article/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "ログインユーザーが記事のレコードを削除しようとしたとき" do
      let(:article_id) { article.id }
      let!(:article) { create(:article, user: current_user) }

      it "記事を削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "ログインユーザー以外のユーザーが記事のレコードを削除しようとしたとき" do
      let(:other_user) { create(:user) }
      let(:article_id) { article.id }
      let!(:article) { create(:article, user: other_user) }

      it "記事を削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
