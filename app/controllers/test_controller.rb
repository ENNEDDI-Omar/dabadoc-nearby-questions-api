# app/controllers/test_controller.rb
class TestController < ApplicationController
  def index
    begin
      result = Mongoid.default_client.command(ping: 1)
      render json: { status: "Connected to MongoDB", result: result }
    rescue => e
      render json: { status: "Error connecting to MongoDB", error: e.message }, status: 500
    end
  end
end