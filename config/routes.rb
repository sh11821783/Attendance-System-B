Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new' # ログインページ
  post   '/login', to: 'sessions#create' # セッション作成（ログイン）
  delete '/logout', to: 'sessions#destroy' # セッション削除（ログアウト）
  # createやdestroyには対応するビューが必要ないため、
  # ここでは指定せずにSessionsコントローラに直接追加
  
  resources :users do
    # memberブロックをリソースブロックに追加する
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
    end
    # onlyオプションで指定することで、updateアクション以外のルーティングを制限。
    # 勤怠データは、アップデートのみ。
    resources :attendances, only: :update # 
  end
end