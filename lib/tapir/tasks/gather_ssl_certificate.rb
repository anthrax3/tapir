
require 'socket'
require 'openssl'

def name
  "gather_ssl_certificate"
end

def pretty_name
  "Gather SSL Certificate"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task allows you to gather an SSL Certificate."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::WebApplication ]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
end

def setup(entity, options={})
  super(entity, options)
end

## Default method, subclasses must override this
def run
  super
  
  hostname = @entity.host.name
  #port = "#{@entity.name.split(":").last}" || 443
  port = 443

  begin
    Timeout.timeout(20) do
      # Create a socket and connect
      tcp_client = TCPSocket.new hostname, port
      ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
      
      # Grab the cert
      ssl_client.connect

      # Parse the cert
      cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)

      # Check the subjectAltName property, and if we have names, here, parse them.
      cert.extensions.each do |ext|
        if ext.oid =~ /subjectAltName/

          alt_names = ext.value.split(",").collect do |x|
            x.gsub(/DNS:/,"").strip
          end

          alt_names.each do |alt_name|
            create_entity Entities::DnsRecord, { :name => alt_name }
          end

        end
      end

      # Close the sockets
      ssl_client.sysclose
      tcp_client.close

      # Create an SSL Certificate entity
      create_entity Entities::SslCert, { :name => cert.subject,
                                         :text => cert.to_text }
    end
  rescue Timeout::Error
    @task_logger.log "Timed out"
  rescue OpenSSL::SSL::SSLError => e
    @task_logger.error "Caught an error: #{e}"
  rescue Errno::ECONNRESET => e 
    @task_logger.error "Caught an error: #{e}"
  rescue RuntimeError => e 
    @task_logger.error "Caught an error: #{e}"
  end
  
end

def cleanup
  super
end
