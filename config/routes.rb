TestHub::Application.routes.draw do

  resources :devices, :only => [:create] do
    post '' => :update, on: :member, as: ''
  end

  get  'scep' => 'scep#get_ca_caps', constraints: -> (request) { request.params['operation'] == 'GetCACaps' }
  get  'scep' => 'scep#get_ca_cert', constraints: -> (request) { request.params['operation'] == 'GetCACert' }
  post 'scep' => 'scep#pki_operation'

  root :to => 'pages#index'

end
