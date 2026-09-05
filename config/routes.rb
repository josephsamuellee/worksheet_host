Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "worksheets#index"

  resources :worksheets, only: [ :index ] do
    resources :responses, controller: "worksheet_responses", only: [ :create ]
  end

  resources :worksheet_responses, only: [ :show, :update ] do
    member do
      patch :complete
    end
    resource :export, only: [ :show ], controller: "exports"
  end
end
