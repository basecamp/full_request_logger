module Rails
  class Conductor::FullRequestLogger::RequestLogsController < ActionController::Base
    layout "rails/conductor"

    def show
      if @logs = FullRequestLogger::Recorder.instance.retrieve(params[:id])
        respond_to do |format|
          format.html
          format.text { send_data @logs, disposition: :attachment, filename: "#{params[:id]}.log" }
        end
      else
        head :not_found
      end
    end
  end
end
