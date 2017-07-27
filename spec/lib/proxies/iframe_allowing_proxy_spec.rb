RSpec.describe Proxies::IframeAllowingProxy do
  before :each do
    @proxy = Proxies::IframeAllowingProxy.new
    @status = {}
    @headers = {}
  end

  describe '#rewrite_response' do
    context 'the page contains html' do
      before :each do
        @headers['content-type'] = ['text/html; charset=utf-8']
      end
      it 'prepends base url to all absolute URLs - href' do
        body = ['<tag>href="/absolute/path"</tag>']
        expect(@proxy.rewrite_response([@status, @headers, body])[-1]).to eq(['<tag>href="/iframe-proxy/absolute/path"</tag>'])
      end
      it 'prepends base url to all absolute URLs - different quotes' do
        body = ['<tag>href=\'/absolute/path\'</tag>']
        expect(@proxy.rewrite_response([@status, @headers, body])[-1]).to eq(['<tag>href="/iframe-proxy/absolute/path"</tag>'])
      end
      it 'replaces gov.uk to an absolute path and prepends base url' do
        body = ['<tag>href="https://gov.uk/absolute/path"</tag>']
        expect(@proxy.rewrite_response([@status, @headers, body])[-1]).to eq(['<tag>href="/iframe-proxy/absolute/path"</tag>'])
      end
      it 'replaces www.gov.uk to an absolute path and prepends base url' do
        body = ['<tag>href="https://www.gov.uk/absolute/path"</tag>']
        expect(@proxy.rewrite_response([@status, @headers, body])[-1]).to eq(['<tag>href="/iframe-proxy/absolute/path"</tag>'])
      end
      it 'does not rewrite urls from other domains' do
        body = ['<link href="https://assets.publishing.service.gov.uk/static/>']
        expect(@proxy.rewrite_response([@status, @headers, body])[-1]).to eq(body)
      end
    end

    context 'the page contains a pdf' do
      before :each do
        @headers['content-type'] = ['application/x-pdf']
      end
      it 'does not rewrite urls' do
        body = ['<tag>href="/absolute/path"</tag>']
        expect(@proxy.rewrite_response([@status, @headers, body])[-1]).to eq(['<tag>href="/absolute/path"</tag>'])
      end
    end
  end
end
