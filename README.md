StarChatBrowser
====

StarChatBrowser とは StarChat (https://github.com/hajimehoshi/star-chat) を見るのが楽になるかもしれないMacOSX 向けアプリケーションです。

全然できてません。

機能
----
* ステータスバー（画面右上にアイコンがならんでいるやつ）から StarChat を呼び出すことができる。（WebView で表示しているだけ）
* 自分が参加しているチャンネルの更新を見て Growl で通知する。

未実装
----
* サーバが指定できない （そのうちちゃんとやる）

開発者向け
----
CocoaPods を使っているのでビルドする前に以下のコマンドを叩きましょう。CocoaPods が入っていなかったらまずはそのインストールからはじめましょう。

    > pod install StarChatBrowser.xcodeproj
    > open StarChatBrowser.xcworkspace 

プロジェクトを開くのは xcworkspace の方です。