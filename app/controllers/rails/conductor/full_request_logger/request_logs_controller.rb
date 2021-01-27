module Rails
  class Conductor::FullRequestLogger::RequestLogsController < ActionController::Base
    before_action :authenticate

    layout "rails/conductor"

    def index
      @logs = FullRequestLogger::Recorder.instance.retrive_list(cursor: params[:cursor] || 0, query: params[:query])
    end

    def create
      redirect_to rails_conductor_request_log_url(params[:id])
    end

    def show
      if @logs = FullRequestLogger::Recorder.instance.retrieve(params[:id])
        respond_to do |format|
          format.html
          format.text { send_data @logs, disposition: :attachment, filename: "#{params[:id]}.log" }
        end
      else
        redirect_to rails_conductor_request_logs_url, alert: "Request not found!"
      end
    end

    private
      def authenticate
        if credentials = FullRequestLogger.credentials
          http_basic_authenticate_or_request_with credentials
        end
      end
  end
end
