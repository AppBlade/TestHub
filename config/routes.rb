TestHub::Application.routes.draw do

  resources :devices, :only => [:create] do
    post '' => :update, on: :member, as: ''
  end

  match 'scep' => 'scep#index', via: [:get, :post]

  root :to => 'pages#index'

end
