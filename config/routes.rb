TestHub::Application.routes.draw do

  resources :devices, :only => [:create] do
    post '' => :update, on: :member, as: ''
  end

  root :to => 'pages#index'

end
