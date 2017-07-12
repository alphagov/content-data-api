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
        body.each { |body_part|
          result << body_part.gsub(%r{href=["'](https://(www\.)?gov\.uk)?/([^'"]*)["']}, %[href="#{Proxies::IframeAllowingProxy::PROXY_BASE_PATH}\\3"])
        }
      else
        result = body
      end

      [status, headers.tap { |h| h['x-frame-options'] = 'ALLOWALL' }, result]
    end
  end
end
