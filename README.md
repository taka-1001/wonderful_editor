# README

## タイトル
### Wonderful Editor
『Qiita風記事作成アプリ』
<img width="1440" alt="スクリーンショット 2022-01-07 21 59 15" src="https://user-images.githubusercontent.com/76923959/148547725-86e05728-ac6a-4506-9f7d-822db0b00363.png">


## 概要
記事を記録、共有するためのアプリ

## URL・テストアカウント
- ポートフォリオURL　: https://wonderful-editor-takahashi.herokuapp.com/
- アカウント : ゲスト
- email : gest@example.com
- password : gestgest

## 制作意図
「実務を見据えたスキルを学習」を意識して制作しました。 転職前に、「試行錯誤する力」「わからないことを調べる力」「適切な質問ができる力」という自走力を磨くために注力してきました。 具体的には「学習段階では知らない概念や言葉が含まれているような指示をもとに、アプリを作る経験」がそれにあたります。基礎的な学習はやりましたが実務で知らないことがでてきた時にどうやって問題解決できるか、このポートフォリオ作成を通してその練習をしました。 なので、このポートフォリオは私が実際に作って世に出したいというようなアプリではありません。そう言ったアプリは実務を通してスキルアップを図りながら作った方がより深い学習にもなると考えているからです。 ここまでやってきたのはあくまでも「「実務を見据えた学習」」であり、今回のポートフォリオもその一環です。

## 使用技術
- Ruby 2.7.2
- Ruby on Rails 6.0.4.1
- Postgres
- Docker/Docker-compose
- Rspec

## 機能一覧
- 記事一覧機能(トップページ)
- マイページ（自分が書いた記事の一覧）
![ホーム画面](https://user-images.githubusercontent.com/76923959/148556496-96440b21-241b-481b-9bd5-534c31e91409.gif)
- ユーザー登録・サインイン/サインアウト
![ログイン](https://user-images.githubusercontent.com/76923959/148556633-c575915e-ae51-48e5-b0bc-0f5fce3d637d.gif)
- 記事CRUD (一覧以外)
- 記事の下書き機能
![投稿](https://user-images.githubusercontent.com/76923959/148557498-5863eddf-42f6-4a9b-8ffe-f6ae8fbf10d8.gif)

## テスト
- Rspce
  - 単体テスト（Model）
  - 結合テスト（Request）

## ER図
<img width="446" alt="ER図" src="https://user-images.githubusercontent.com/76923959/148557880-ba209041-53ac-45ed-ad33-b3409941bec1.png">
