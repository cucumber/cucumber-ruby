class URLReporter
  def report(url)
    puts "Message file located at: #{url}"
  end
end

describe URLReporter do
  subject {URLReporter.new}

  context '#report' do
    it 'does nothing when the URL is not cucumber message store' do
      allow($stdout).to receive(:puts)
      subject.report('http://example.com')
      expect($stdout).not_to have_received(:puts)
    end
  end
end
