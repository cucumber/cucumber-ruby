RSpec.shared_context 'an HTTP server accepting file requests' do
  subject(:http_server) do
    Class.new do
      def initialize
        @read_io, @write_io = IO.pipe
      end

      def webrick_options
        @webrick_options ||= default_options
      end

      private

      def default_options
        {
          Port: 0,
          Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
          AccessLog: [],
          StartCallback: proc do
            @write_io.write(1) # write "1", signal a server start message
            @write_io.close
          end
        }
      end
    end
  end

  let(:putreport_returned_location) { URI('/s3').to_s }
  let(:success_banner) do
    [
      'View your Cucumber Report at:',
      'https://reports.cucumber.io/reports/<some-random-uid>'
    ].join("\n")
  end
  let(:failure_banner) { 'Oh noooo, something went horribly wrong :(' }

  after do
    @server&.shutdown
  end

  def start_server
    uri = URI('http://localhost')
    @received_body_io = StringIO.new
    @received_headers = []
    @request_count = 0

    read_io, write_io = IO.pipe
    webrick_options = {
      Port: 0,
      Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
      AccessLog: [],
      StartCallback: proc do
        write_io.write(1) # write "1", signal a server start message
        write_io.close
      end
    }

    @server = WEBrick::HTTPServer.new(webrick_options)
    mount_s3_endpoint
    mount_404_endpoint
    mount_401_endpoint
    mount_report_endpoint
    mount_redirect_endpoint

    Thread.new { @server.start }
    read_io.read(1) # read a byte for the server start signal
    read_io.close

    "http://localhost:#{@server.config[:Port]}"
  end

  private

  def mount_s3_endpoint
    @server.mount_proc '/s3' do |req, res|
      @request_count += 1
      IO.copy_stream(req.body_reader, @received_body_io)
      @received_headers << req.header
      if req['authorization']
        res.status = 400
        res.body = 'Do not send Authorization header to S3'
      end
    end
  end

  def mount_404_endpoint
    @server.mount_proc '/404' do |req, res|
      @request_count += 1
      @received_headers << req.header
      res.status = 404
      res.header['Content-Type'] = 'text/plain;charset=utf-8'
      res.body = failure_banner
    end
  end

  def mount_401_endpoint
    @server.mount_proc '/401' do |req, res|
      @request_count += 1
      @received_headers << req.header
      res.status = 401
      res.header['Content-Type'] = 'text/plain;charset=utf-8'
      res.body = failure_banner
    end
  end

  def mount_report_endpoint
    @server.mount_proc '/putreport' do |req, res|
      @request_count += 1
      IO.copy_stream(req.body_reader, @received_body_io)
      @received_headers << req.header

      if req.request_method == 'GET'
        res.status = 202 # Accepted
        res.header['location'] = putreport_returned_location if putreport_returned_location
        res.header['Content-Type'] = 'text/plain;charset=utf-8'
        res.body = success_banner
      else
        res.set_redirect(
          WEBrick::HTTPStatus::TemporaryRedirect,
          '/s3'
        )
      end
    end
  end

  def mount_redirect_endpoint
    @server.mount_proc '/loop_redirect' do |req, res|
      @request_count += 1
      @received_headers << req.header
      res.set_redirect(
        WEBrick::HTTPStatus::TemporaryRedirect,
        '/loop_redirect'
      )
    end
  end
end
