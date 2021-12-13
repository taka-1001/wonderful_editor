require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "email, password が正しいとき" do
      let(:params) { { email: user.email, password: user.password } }
      let(:user) { create(:user) }
      it "ログインできる" do
        subject
        header = response.header
        expect(header["uid"]).to be_present
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "email が正しくないとき" do
      let(:params) { { email: "test@example.cpm", password: user.password } }
      let(:user) { create(:user) }
      # rubocop:disable RSpec/ExampleLength
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["success"]).to be_falsey
        expect(response).to have_http_status(:unauthorized)
        expect(header["uid"]).to be_blank
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end

    context "password が正しくないとき" do
      let(:params) { { email: user.email, password: "password" } }
      let(:user) { create(:user) }
      it "ログインできない" do
        # rubocop:enable RSpec/ExampleLength
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["success"]).to be_falsey
        expect(response).to have_http_status(:unauthorized)
        expect(header["uid"]).to be_blank
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end
  end

  describe "DELETE /api/v1/auth/sing_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ユーザーがログインしているとき" do
      let(:user) { create(:user) }
      let!(:headers) { user.create_new_auth_token }
      it "ログアウトできる" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to be_truthy
        expect(user.reload.tokens).to be_blank
        expect(response).to have_http_status(:ok)
      end
    end

    context "ユーザーのヘッダー情報がないとき" do
      let(:user) { create(:user) }
      it "エラーする" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to include "User was not found or was not logged in."
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
