TestHub::Application.routes.draw do

  resources :devices, :only => [:create]
  post 'devices/:id' => 'devices#update', as: :device

  resources :repositories, :only => [:new, :create]

  get  'scep' => 'scep#get_ca_caps', constraints: -> (request) { request.params['operation'] == 'GetCACaps' }
  get  'scep' => 'scep#get_ca_cert', constraints: -> (request) { request.params['operation'] == 'GetCACert' }
  post 'scep' => 'scep#pki_operation'

  root :to => 'pages#index'

  post 'oauth/:client' => 'oauth#start',    as: :oauth_start
  get  'oauth/:client' => 'oauth#callback', as: :oauth_callback

end
