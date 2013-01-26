require 'openmbta2'
require 'test_sinatra'

Openmbta2::Application.routes.draw do

  mount(TestSinatra, :at => "sinatra")
  match '/routes/:transport_type' => 'routes#index'
  match '/trips' => 'trips#index'
  match '/alerts' => 'alerts#index'
  resources :tweets
  match '/alerts/:guid' => 'alerts#show'
  match '/help/:target_controller/:transport_type' => 'help#show'
  match '/about/:action' => 'about#index'
  match '/support/:action' => 'support#index'
  match '/mobile' => 'main#index'
  match '/trips/realtime' => 'main#index'
  match '/main' => 'main#index'

  match '/research' => 'research#index'

  match '/' => 'home#index'
  match '/:controller(/:action(/:id))'

end
