# This proxy is to allow an Iframe to display content from gov.uk, which is a different domain, into this application.
module Proxies
  class IframeAllowingProxy < Rack::Proxy
    PROXY_BASE_PATH = '/iframe-proxy/'.freeze

    def rewrite_env(env)
      env['HTTP_HOST'] = 'www.gov.uk:443'
      env['SERVER_NAME'] = 'www.gov.uk'
      env['SERVER_PORT'] = 443
      env['SCRIPT_NAME'] = ''
      env['REQUEST_PATH'] = env['REQUEST_URI'] = env['PATH_INFO']
      env['rack.url_scheme'] = 'https'

      # Ensure the target returns an uncompressed body so that the response can easily be rewritten
      env.delete('HTTP_ACCEPT_ENCODING')
      env
    end

    # Links from gov.uk are rewritten to point to the proxy
    def rewrite_response(triplet)
      status, headers, body = triplet

      result = []
      if headers['content-type'].any? { |header| header.include?('text/html') }
        document = Nokogiri::HTML(body.to_s)

        document.css("a").each do |link|
          rewrite_relative_link!(link)
          open_link_in_new_tab!(link)
        end

        result = [document.to_html]
      else
        result = body
      end

      [status, headers.tap { |h| h['x-frame-options'] = 'ALLOWALL' }, result]
    end

    def rewrite_relative_link!(link)
      url = link['href']
      matches = %r{^/(?<path>.*)}.match(url)
      return unless matches
      link['href'] = "https://www.gov.uk/#{matches[:path]}"
    end

    def open_link_in_new_tab!(link)
      return if link['href'].start_with?('#')
      link['target'] = "_blank"
      link['rel'] = [link['rel'], "noopener noreferrer"].join
    end
  end
end
