# frozen_string_literal: true

Rails.application.routes.draw do
  scope "rails/conductor/full_request_logger/", module: "rails/conductor/full_request_logger" do
    resources :request_logs, only: :show, as: :rails_conductor_request_logs
  end
end
