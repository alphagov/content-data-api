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

      context 'body contains an <a> tag with an absolute URL' do
        before :each do
          @response_body = proxied_body('<a href="/absolute/path"></a>')
        end

        it 'prepends the URL with GOV.UK' do
          expect(@response_body).to include('href="https://www.gov.uk/absolute/path"')
        end

        it 'opens the URL in a new tab' do
          expect(@response_body).to include('target="_blank"')
          expect(@response_body).to include('rel="noopener noreferrer"')
        end
      end

      context 'body contains an <a> tag with a full URL' do
        before :each do
          @response_body = proxied_body('<a href="https://assets.publishing.service.gov.uk/static/"></a>')
        end

        it 'does not rewrite the URL' do
          expect(@response_body).to include('href="https://assets.publishing.service.gov.uk/static/"')
        end

        it 'opens the URL in a new tab' do
          expect(@response_body).to include('target="_blank"')
          expect(@response_body).to include('rel="noopener noreferrer"')
        end
      end

      context 'body contains an <a> tag with an anchor' do
        before :each do
          @response_body = proxied_body('<a href="#content"></a>')
        end

        it 'does not rewrite the URL' do
          expect(@response_body).to include('href="#content"')
        end

        it 'does not open the URL in a new tab' do
          expect(@response_body).to_not include('target="_blank"')
        end
      end

      def proxied_body(original_body)
        response = @proxy.rewrite_response([@status, @headers, original_body])
        response[-1][0]
      end
    end
  end
end
