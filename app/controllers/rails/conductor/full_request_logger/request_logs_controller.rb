module Rails
  class Conductor::FullRequestLogger::RequestLogsController < ActionController::Base
    before_action :authenticate

    layout "rails/conductor"

    def index
      @logs = FullRequestLogger::Recorder.instance.retrive_list(page: params[:page] || 1, query: params[:query])
    end

    def create
      redirect_to rails_conductor_request_log_url(params[:id])
    end

    def show
      if @log = FullRequestLogger::Recorder.instance.retrieve(params[:id])
        respond_to do |format|
          format.html
          format.text { send_data @log.body, disposition: :attachment, filename: "#{params[:id]}.log" }
        end
      else
        redirect_to rails_conductor_request_logs_url, alert: "Request not found!"
      end
    end

    private

      def authenticate
        if credentials = FullRequestLogger.credentials
          authenticate_or_request_with_http_basic do |given_name, given_password|
            ActiveSupport::SecurityUtils.secure_compare(given_name, credentials[:name]) &
              ActiveSupport::SecurityUtils.secure_compare(given_password, credentials[:password])
          end
        end
      end
  end
end
