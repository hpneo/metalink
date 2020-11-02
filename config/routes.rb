Rails.application.routes.draw do
  get "/", to: "metalink#analyze"
  get "/screenshot", to: "metalink#screenshot"
end
